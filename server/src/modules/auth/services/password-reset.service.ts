import { createHash, randomInt } from 'node:crypto'

import { Injectable, Logger } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'

import { BizErrorCode } from '../../../common/enums/biz-error-code.enum'
import { BizException } from '../../../common/exceptions/biz.exception'
import { MailerService } from '../../../shared/mailer/mailer.service'
import { RedisService } from '../../../shared/redis/redis.service'
import { SystemConfigService } from '../../system/config/system-config.service'
import { UserEntity } from '../../user/entities/user.entity'
import { UserService } from '../../user/user.service'

/** 验证码在存储里的形态（不存明文，防 Redis 被读走直接用） */
interface StoredCode {
  /** sha256(验证码 + 用户 id) */
  hash: string
  /** 已试错次数，达到上限直接作废 */
  tries: number
}

/** 同一账号两次发码的最小间隔（秒），防"点着玩" */
const COOLDOWN_SECONDS = 60
/** 一个验证码最多试错几次 */
const MAX_TRIES = 5
const KEY_PREFIX = 'pwd-reset:'
const COOLDOWN_PREFIX = 'pwd-reset-cd:'
/** 独立试错计数 key（原子 INCR，避免并发读-改-写丢失更新） */
const TRY_PREFIX = 'pwd-reset-try:'

/**
 * 忘记密码（邮件验证码）
 *
 * 流程：`POST /v1/auth/password/forgot` 发码 → 用户收邮件拿到 6 位码 →
 *      `POST /v1/auth/password/reset-by-code` 用「账号 + 码 + 新密码」重置。
 *
 * 两个安全取舍：
 * 1. **不做账号枚举**：无论账号是否存在、是否绑了邮箱、是否在冷却期，接口都返回同样的
 *    `{ sent: true, ttlMinutes }`。否则拿它就能当"账号是否存在"的探测器。
 * 2. **先验码再验密码强度，只有两者都过才消费码**：否则密码不合规时码已被烧掉，
 *    用户得重新申请，属于纯折腾。
 *
 * Redis 未启用时降级到进程内 Map（单实例可用，多实例会"发的码在 A 实例、校验打到 B 实例"，
 * 所以生产必须开 Redis）。
 */
@Injectable()
export class PasswordResetService {
  private readonly logger = new Logger(PasswordResetService.name)
  /** Redis 不可用时的兜底存储 */
  private readonly memory = new Map<string, { value: string; expireAt: number }>()

  constructor(
    @InjectRepository(UserEntity)
    private readonly users: Repository<UserEntity>,
    private readonly userService: UserService,
    private readonly mailer: MailerService,
    private readonly redis: RedisService,
    private readonly config: SystemConfigService
  ) {}

  /** 发验证码。返回值刻意不区分「账号不存在 / 没邮箱 / 冷却中」，只给一个统一口径 */
  async request(account: string, ip?: string): Promise<{ sent: true; ttlMinutes: number }> {
    const ttlMinutes = Math.max(1, await this.config.getNumber('mail.resetCode.ttlMinutes', 5))
    const key = (account ?? '').trim()
    if (!key) return { sent: true, ttlMinutes }

    const user = await this.findByAccount(key)
    // 一律返回 sent:true；下面每种"其实没发"的情况只写日志
    if (!user) {
      this.logger.warn(`申请重置密码：账号不存在（${this.mask(key)}）`)
      return { sent: true, ttlMinutes }
    }
    if (!user.email) {
      this.logger.warn(`申请重置密码：账号未绑定邮箱（userId=${user.id}）`)
      return { sent: true, ttlMinutes }
    }
    if (await this.getRaw(COOLDOWN_PREFIX + user.id)) {
      this.logger.warn(`申请重置密码：冷却期内重复申请（userId=${user.id}）`)
      return { sent: true, ttlMinutes }
    }

    const code = randomInt(0, 1_000_000).toString().padStart(6, '0')
    await this.setRaw(KEY_PREFIX + user.id, JSON.stringify({ hash: this.digest(code, user.id), tries: 0 } satisfies StoredCode), ttlMinutes * 60)
    // 新码作废旧码的试错计数（否则上一轮试错会拖累本轮）
    await this.clearTry(user.id)
    await this.setRaw(COOLDOWN_PREFIX + user.id, '1', COOLDOWN_SECONDS)

    const result = await this.mailer.sendResetCode(user.email, { realname: user.realname, code, ttlMinutes, ip })
    if (!result.ok) this.logger.error(`重置密码验证码发送失败（userId=${user.id}）：${result.error ?? '未知原因'}`)
    return { sent: true, ttlMinutes }
  }

  /** 用验证码重置密码 */
  async reset(account: string, code: string, newPassword: string): Promise<{ ok: true }> {
    const user = await this.findByAccount((account ?? '').trim())
    const invalid = new BizException(BizErrorCode.PARAM_INVALID, '验证码错误或已过期')

    // 账号不存在时也走"验证码错误"，避免枚举
    if (!user) throw invalid

    const key = KEY_PREFIX + user.id
    const raw = await this.getRaw(key)
    if (!raw) throw invalid

    let stored: StoredCode
    try {
      stored = JSON.parse(raw) as StoredCode
    } catch {
      await this.delRaw(key)
      throw invalid
    }

    if (stored.hash !== this.digest((code ?? '').trim(), user.id)) {
      // 试错计数用独立 key 原子 INCR：并发错误也不丢失更新；达到上限即作废验证码
      const tries = await this.bumpTry(user.id)
      if (tries >= MAX_TRIES) {
        await this.delRaw(key)
        this.logger.warn(`重置密码：验证码试错达到上限，已作废（userId=${user.id}）`)
      }
      throw invalid
    }

    // 码对了才验密码强度：强度不合规时保留码，用户可以换个密码再来
    await this.userService.assertPassword(newPassword, user.username)

    await this.delRaw(key)
    await this.userService.updatePasswordOnly(user.id, newPassword)
    // 重置成功 = 旧密码可能已泄露：全量下线 + 用户级吊销标记，
    // 不然攻击者手里的旧 refreshToken 还能继续换新令牌（forgot 链路接管账号的最后一环）
    await this.userService.forceOffline(user.id)
    this.logger.log(`重置密码成功（userId=${user.id}），已下线该账号全部会话`)
    return { ok: true }
  }

  /** 按账号或邮箱查（只认未删除的账号） */
  private async findByAccount(account: string): Promise<UserEntity | null> {
    if (!account) return null
    return this.users.findOne({
      where: [
        { username: account, delFlag: 0 },
        { email: account, delFlag: 0 }
      ]
    })
  }

  private digest(code: string, userId: string): string {
    return createHash('sha256').update(`${code}:${userId}`).digest('hex')
  }

  /** 日志里不写完整账号/邮箱 */
  private mask(value: string): string {
    if (value.length <= 2) return '**'
    return `${value.slice(0, 2)}${'*'.repeat(Math.min(6, value.length - 2))}`
  }

  private async getRaw(key: string): Promise<string | null> {
    const client = this.redis.client
    if (client) {
      try {
        return await client.get(key)
      } catch (error) {
        this.logger.warn(`Redis 读取失败，降级到内存：${error instanceof Error ? error.message : String(error)}`)
      }
    }
    const hit = this.memory.get(key)
    if (!hit) return null
    if (hit.expireAt <= Date.now()) {
      this.memory.delete(key)
      return null
    }
    return hit.value
  }

  private async setRaw(key: string, value: string, ttlSeconds: number): Promise<void> {
    const client = this.redis.client
    if (client) {
      try {
        await client.set(key, value, 'EX', ttlSeconds)
        return
      } catch (error) {
        this.logger.warn(`Redis 写入失败，降级到内存：${error instanceof Error ? error.message : String(error)}`)
      }
    }
    this.memory.set(key, { value, expireAt: Date.now() + ttlSeconds * 1000 })
  }

  /**
   * 试错 +1（原子）：Redis INCR + 首次 EXPIRE；失败降级到内存计数。
   * 与验证码主体分离，避免并发「读 JSON → 改 tries → 写回」丢失更新。
   */
  private async bumpTry(userId: string): Promise<number> {
    const key = TRY_PREFIX + userId
    const client = this.redis.client
    if (client) {
      try {
        const n = await client.incr(key)
        if (n === 1) await client.expire(key, 10 * 60)
        return n
      } catch {
        // 落到内存分支
      }
    }
    const hit = this.memory.get(key)
    const n = hit ? Number(hit.value || '0') + 1 : 1
    this.memory.set(key, { value: String(n), expireAt: Date.now() + 10 * 60 * 1000 })
    return n
  }

  /** 发新码时清除旧试错计数 */
  private async clearTry(userId: string): Promise<void> {
    const key = TRY_PREFIX + userId
    const client = this.redis.client
    if (client) {
      try {
        await client.del(key)
      } catch {
        // 内存里也删一遍
      }
    }
    this.memory.delete(key)
  }

  private async delRaw(key: string): Promise<void> {
    const client = this.redis.client
    if (client) {
      try {
        await client.del(key)
      } catch {
        // 忽略：内存里也删一遍即可
      }
    }
    this.memory.delete(key)
  }
}
