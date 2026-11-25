import { BadRequestException, Injectable, Logger, NestMiddleware } from '@nestjs/common'
import crypto from 'node:crypto'
import fs from 'node:fs'
import path from 'node:path'
import { NextFunction, Request, Response } from 'express'

import { RedisService } from '../../shared/redis/redis.service'

/**
 * 请求体加密（可选，AES-256-GCM + RSA-OAEP 信封加密）
 *
 * 设计为「开关默认关」的可选加固：ENCRYPT_ENABLED=true 才生效。
 * 适用于：登录口令等高敏字段在内网抓包/代理日志里不想明文出镜的场景。
 *
 * 协议 v2（信封加密，`X-Encrypted: aes-rsa-v2`）：
 *   客户端：AES-256-GCM 随机密钥加密 JSON body → data(base64)；
 *           RSA 公钥加密 AES 密钥 → ek(base64)；iv(base64)；
 *           ts(毫秒时间戳)；nonce(16 字节随机 base64)；
 *           POST { ek, iv, data, ts, nonce }
 *           —— ts 与 nonce 以 `ts:nonce` 作为 GCM 的 additionalData 绑定进密文，不可篡改。
 *   服务端：校验 ts 时效（±120s）与 nonce 一次性（Redis SET NX，TTL 300s）
 *           → RSA 私钥解出 AES 密钥 → GCM(AAD=ts:nonce) 解密 → 还原 req.body。
 *
 * v2 相比 v1 的差别：v1 无 ts/nonce，抓包者可在时效内原样重放整包密文（登录重放）。
 * v2 通过「时间窗 + nonce 一次性 + AAD 绑定」三重防护杜绝重放；v1 报文一律拒绝（协议不兼容升级）。
 *
 * 密钥管理（优先级）：
 *   1. 环境变量 REQUEST_ENCRYPT_RSA_PRIVATE_KEY / _PUBLIC_KEY（PEM 换行用 \n 转义）；
 *   2. 未配置则首次启动自动生成密钥对落 storage/keys/request-encrypt.json（自洽单机），
 *      生产多实例应显式配置同一对密钥，否则各实例公钥不一致。
 *
 * RSA-OAEP 只能加密 ≤ 245 字节（2048 位），所以只加密 AES 密钥而不加密 body 本体 ——
 * 这正是"信封加密"的用途；body 任意大小。
 */

/** RSA 私钥 + 公钥（PEM）；env 未配时自动生成落盘 */
let keyPair: { publicKeyPem: string; privateKeyPem: string } | null = null
let keyLoaded = false

/** 懒加载密钥对（首次用到才读盘/生成；ENCRYPT_ENABLED=false 时永不触发） */
function loadKeyPair(): { publicKeyPem: string; privateKeyPem: string } {
  if (keyLoaded && keyPair) return keyPair
  keyLoaded = true

  const envPrivate = (process.env.REQUEST_ENCRYPT_RSA_PRIVATE_KEY ?? '').trim()
  const envPublic = (process.env.REQUEST_ENCRYPT_RSA_PUBLIC_KEY ?? '').trim()
  if (envPrivate && envPublic) {
    keyPair = { privateKeyPem: envPrivate.replace(/\\n/g, '\n'), publicKeyPem: envPublic.replace(/\\n/g, '\n') }
    return keyPair
  }

  // 自动生成：文件落 storage/keys/（与文件存储同盘、不在 public 托管范围内）
  const keyFile = path.resolve(process.env.FILE_STORAGE_DIR?.trim() || path.join(process.cwd(), 'storage'), 'keys', 'request-encrypt.json')
  if (fs.existsSync(keyFile)) {
    keyPair = JSON.parse(fs.readFileSync(keyFile, 'utf8')) as { publicKeyPem: string; privateKeyPem: string }
    return keyPair
  }
  const { publicKey, privateKey } = crypto.generateKeyPairSync('rsa', {
    modulusLength: 2048,
    publicKeyEncoding: { type: 'spki', format: 'pem' },
    privateKeyEncoding: { type: 'pkcs8', format: 'pem' }
  })
  keyPair = { publicKeyPem: publicKey.toString(), privateKeyPem: privateKey.toString() }
  fs.mkdirSync(path.dirname(keyFile), { recursive: true })
  fs.writeFileSync(keyFile, JSON.stringify(keyPair, null, 2), { mode: 0o600 })
  return keyPair
}

/** 前端取公钥用（@Public 端点直接调） */
export function requestEncryptPublicKey(): string | null {
  if (!isEnabled()) return null
  return loadKeyPair().publicKeyPem
}

function isEnabled(): boolean {
  return (process.env.ENCRYPT_ENABLED ?? 'false').trim().toLowerCase() === 'true'
}

/** 时间窗（毫秒）：ts 与服务器时钟的最大偏差，超窗直接拒绝 */
const TIMESTAMP_WINDOW_MS = 120 * 1000
/** nonce 防重放记录 TTL（秒）：只需覆盖时间窗（120s），留一倍余量 */
const NONCE_TTL_SECONDS = 300

@Injectable()
export class RequestDecryptMiddleware implements NestMiddleware {
  private readonly logger = new Logger(RequestDecryptMiddleware.name)

  /** Redis 不可用时的进程内 nonce 兜底表（单实例有效；多实例请启用 Redis） */
  private readonly seenNonces = new Map<string, number>()

  constructor(private readonly redis: RedisService) {}

  async use(req: Request, _res: Response, next: NextFunction): Promise<void> {
    if (!isEnabled()) return next()
    const header = String(req.headers['x-encrypted'] ?? '')
    if (!header) return next()
    if (header !== 'aes-rsa-v2') {
      // v1 无防重放能力，升级后一律拒绝（而非静默降级），避免「以为加密了其实没有」
      throw new BadRequestException('加密协议版本不受支持（需要 aes-rsa-v2），请升级前端后再试')
    }

    // 只有 JSON body 才走解密；GET/DELETE 无 body
    const body = req.body as Record<string, unknown> | undefined
    if (!body || typeof body !== 'object') return next()

    const ek = typeof body.ek === 'string' ? body.ek : ''
    const iv = typeof body.iv === 'string' ? body.iv : ''
    const data = typeof body.data === 'string' ? body.data : ''
    const ts = typeof body.ts === 'number' ? body.ts : Number.NaN
    const nonce = typeof body.nonce === 'string' ? body.nonce : ''
    if (!ek || !iv || !data || !Number.isFinite(ts) || !nonce) {
      throw new BadRequestException('加密请求体格式不正确（需要 ek/iv/data/ts/nonce 字段）')
    }
    if (Math.abs(Date.now() - ts) > TIMESTAMP_WINDOW_MS) {
      throw new BadRequestException('加密请求已过期（时钟偏差过大），请刷新页面后重试')
    }

    try {
      // 0. nonce 一次性消费：重放报文在这里被拦（先于任何解密副作用）
      if (!(await this.consumeNonce(nonce))) {
        throw new BadRequestException('加密请求重复提交，已被拒绝')
      }

      // 1. RSA-OAEP 解出 AES 密钥
      const sessionKey = crypto.privateDecrypt(
        { key: loadKeyPair().privateKeyPem, padding: crypto.constants.RSA_PKCS1_OAEP_PADDING, oaepHash: 'sha256' },
        Buffer.from(ek, 'base64')
      )
      // 2. AES-256-GCM 解出 JSON body；约定 data = ciphertext + 16 字节 GCM authTag（与前端 WebCrypto 对齐）
      //    AAD 绑定 ts:nonce：客户端即使篡改这两个字段（不改密文），GCM 校验也会失败
      const decipher = crypto.createDecipheriv('aes-256-gcm', sessionKey, Buffer.from(iv, 'base64'))
      decipher.setAAD(Buffer.from(`${ts}:${nonce}`, 'utf8'))
      const raw = Buffer.from(data, 'base64')
      const ciphertext = raw.subarray(0, raw.length - 16)
      const authTag = raw.subarray(raw.length - 16)
      decipher.setAuthTag(authTag)
      const plain = Buffer.concat([decipher.update(ciphertext), decipher.final()]).toString('utf8')

      const parsed = JSON.parse(plain)
      if (parsed && typeof parsed === 'object') {
        req.body = parsed as Record<string, unknown>
        // 原始密文挂旁路字段：OperLogInterceptor 想记参数时不会把密文当业务数据
        ;(req as Request & { __encryptedOriginal?: string }).__encryptedOriginal = data.slice(0, 64)
      }
      return next()
    } catch (error) {
      if (error instanceof BadRequestException) throw error
      this.logger.warn(`加密请求解密失败：${error instanceof Error ? error.message : String(error)}`)
      throw new BadRequestException('加密请求解密失败：密钥不匹配或数据被篡改')
    }
  }

  /** nonce 一次性消费：Redis SET NX 原子去重；Redis 未启用/故障退化为进程内表（单实例有效） */
  private async consumeNonce(nonce: string): Promise<boolean> {
    const key = `enc:nonce:${nonce}`
    const client = this.redis.enabled ? this.redis.client : null
    if (client) {
      try {
        const ok = await client.set(key, '1', 'EX', NONCE_TTL_SECONDS, 'NX')
        if (ok === 'OK') return true
        // SET NX 未命中 = 该 nonce 已被使用过；进程内也记一笔，双保险
        this.rememberNonce(key)
        return false
      } catch (error) {
        this.logger.warn(`nonce 防重放写 Redis 失败，退化为进程内判定：${(error as Error).message}`)
      }
    }
    return this.rememberNonce(key)
  }

  /** 进程内 nonce 登记（Redis 不可用或 SET NX 未命中时的兜底记录） */
  private rememberNonce(key: string): boolean {
    const now = Date.now()
    if (this.seenNonces.size > 10000) {
      for (const [entryKey, expiresAt] of this.seenNonces) {
        if (expiresAt <= now) this.seenNonces.delete(entryKey)
      }
    }
    if (this.seenNonces.has(key)) return false
    this.seenNonces.set(key, now + NONCE_TTL_SECONDS * 1000)
    return true
  }
}
