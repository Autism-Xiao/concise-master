import { Injectable, Logger } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { In, Repository } from 'typeorm'

import { UserEntity } from '../../modules/user/entities/user.entity'

/**
 * 用户名字典：把用户 ID 批量翻译成展示名（姓名优先，回退账号）。
 *
 * 用途：审计字段 createBy/updateBy 存的是用户 ID，响应层拦截器据此附加
 * createByName/updateByName，前端列表直接显示人名而不是一串 32 位 ID。
 *
 * 缓存说明：进程内 60 秒 TTL。审计展示对实时性要求低，短缓存可避免
 * 列表每条记录都查一次用户表（批量 IN + 缓存去重后通常零查询）。
 * 用户改名后最多 60 秒才刷新，可接受。
 */
@Injectable()
export class UserDictService {
  private readonly logger = new Logger(UserDictService.name)
  private readonly cache = new Map<string, { name: string | null; expireAt: number }>()
  private readonly TTL_MS = 60_000

  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>
  ) {}

  /**
   * 批量查展示名。返回值只含查到的 id（查不到的不返回，调用方保留原值）。
   * 姓名（realname）优先，空则回退账号（username）。
   */
  async getNames(ids: string[]): Promise<Map<string, string>> {
    const result = new Map<string, string>()
    const clean = Array.from(new Set(ids.map(id => String(id ?? '').trim()).filter(Boolean)))
    if (!clean.length) return result

    const now = Date.now()
    const missing: string[] = []
    for (const id of clean) {
      const hit = this.cache.get(id)
      if (hit && hit.expireAt > now) {
        if (hit.name) result.set(id, hit.name)
      } else {
        missing.push(id)
      }
    }
    if (!missing.length) return result

    try {
      // 审计展示用：不过滤软删，历史记录的创建人即使已离职也要能显示名字
      const users = await this.userRepository.find({
        where: { id: In(missing) },
        select: { id: true, username: true, realname: true }
      })
      for (const user of users) {
        const name = user.realname?.trim() || user.username || null
        this.cache.set(user.id, { name, expireAt: Date.now() + this.TTL_MS })
        if (name) result.set(user.id, name)
      }
      // 查不到的也写缓存（null），避免每条记录反复查库
      const found = new Set(users.map(user => user.id))
      for (const id of missing) {
        if (!found.has(id)) this.cache.set(id, { name: null, expireAt: Date.now() + this.TTL_MS })
      }
    } catch (error) {
      this.logger.warn(`用户名字典查询失败：${String(error)}`)
    }
    return result
  }

  /**
   * 实时解析名字（绕过缓存直查库），供**写入审计快照**时使用。
   *
   * 不能用 getNames：那个带 60 秒缓存，用户改名后立即新建记录会写入旧名字，
   * 快照就失去意义。这里直查库并顺手刷新缓存，保证快照是操作当时的真实展示名。
   */
  async resolveName(id?: string | null): Promise<string | null> {
    const clean = String(id ?? '').trim()
    if (!clean) return null
    try {
      const user = await this.userRepository.findOne({
        where: { id: clean },
        select: { id: true, username: true, realname: true }
      })
      const name = user?.realname?.trim() || user?.username || null
      this.cache.set(clean, { name, expireAt: Date.now() + this.TTL_MS })
      return name
    } catch (error) {
      this.logger.warn(`审计快照名字解析失败（id=${clean}）：${String(error)}`)
      return null
    }
  }

  /** 用户改名/删改后清缓存（供用户服务按需调用；不调也会在 60 秒后自然过期） */
  clear(id?: string): void {
    if (id) this.cache.delete(id)
    else this.cache.clear()
  }
}
