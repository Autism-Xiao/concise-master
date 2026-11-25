/**
 * 请求体加密客户端（可选加固，与后端 RequestDecryptMiddleware 对应）
 *
 * 协议 v2（`X-Encrypted: aes-rsa-v2` 信封加密）：
 *   1. RSA-OAEP-SHA256 加密随机 AES-256 会话密钥 → ek；
 *   2. AES-256-GCM 加密 JSON body，data = ciphertext + 16 字节 authTag（base64），
 *      并以 `ts:nonce` 作为 additionalData 绑定进密文（防字段篡改）；
 *   3. POST { ek, iv, data, ts, nonce } + 请求头 X-Encrypted。
 *
 * ts（毫秒时间戳，±120s 时效）与 nonce（16 字节随机数，服务端一次性消费）
 * 用于防重放：v1 协议没有这两个字段，抓包可在时效内原样重放整包密文。
 *
 * 启用条件：后端 ENCRYPT_ENABLED=true 且登录前拉到过公钥（sessionStorage 缓存）。
 * 都不满足时零行为变化 —— 请求加密是纯增强，失败永不阻塞登录（回退明文）。
 *
 * RSA-OAEP(2048) 只能加密 ≤ 190 字节（SHA-256 padding），所以只加密 AES 密钥而不是 body —— 信封加密的用途。
 */

const PUBKEY_CACHE_KEY = 'wb:request-encrypt:pubkey:v1'

/** 向后端要公钥；未启用返回 null。登录页加载时调用一次 */
export async function fetchEncryptPublicKey(): Promise<string | null> {
  try {
    const res = await fetch('/backend-api/v1/auth/encrypt-key')
    const json = (await res.json()) as { result?: { enabled?: boolean; publicKey?: string } }
    const publicKey = json.result?.enabled ? (json.result.publicKey ?? null) : null
    if (publicKey) sessionStorage.setItem(PUBKEY_CACHE_KEY, publicKey)
    else sessionStorage.removeItem(PUBKEY_CACHE_KEY)
    return publicKey
  } catch {
    return null
  }
}

function cachedPublicKey(): string | null {
  try {
    return sessionStorage.getItem(PUBKEY_CACHE_KEY)
  } catch {
    return null
  }
}

/** base64（Node Buffer / WebCrypto 双兼容） */
function toBase64(bytes: Uint8Array): string {
  let binary = ''
  for (const byte of bytes) binary += String.fromCharCode(byte)
  return btoa(binary)
}

function importRsaPublicKey(pem: string): Promise<CryptoKey> {
  const body = pem
    .replace(/-----BEGIN PUBLIC KEY-----/, '')
    .replace(/-----END PUBLIC KEY-----/, '')
    .replace(/\s+/g, '')
  const der = Uint8Array.from(atob(body), ch => ch.charCodeAt(0))
  return crypto.subtle.importKey('spki', der, { name: 'RSA-OAEP', hash: 'SHA-256' }, false, ['encrypt'])
}

/** 信封加密一个 JSON body；任一步失败返回 null（调用方回退明文） */
export async function encryptRequestBody(
  payload: Record<string, unknown>
): Promise<{ ek: string; iv: string; data: string; ts: number; nonce: string } | null> {
  const publicKeyPem = cachedPublicKey()
  if (!publicKeyPem || typeof crypto?.subtle === 'undefined') return null
  try {
    // 1. 会话密钥（AES-256-GCM 一次一密）
    const sessionKey = await crypto.subtle.generateKey({ name: 'AES-GCM', length: 256 }, true, ['encrypt'])
    const iv = crypto.getRandomValues(new Uint8Array(12))
    // 2. 防重放参数：ts 时效窗口 + nonce 一次性；两者以 `ts:nonce` 绑定进 GCM additionalData
    const ts = Date.now()
    const nonce = toBase64(crypto.getRandomValues(new Uint8Array(16)))
    const aad = new TextEncoder().encode(`${ts}:${nonce}`)

    // 3. AES 加密 body；data = ciphertext + authTag
    const plaintext = new TextEncoder().encode(JSON.stringify(payload))
    const encrypted = new Uint8Array(await crypto.subtle.encrypt({ name: 'AES-GCM', iv, additionalData: aad }, sessionKey, plaintext))

    // 4. RSA 加密会话密钥（导出 raw 32 字节）
    const rawSessionKey = new Uint8Array(await crypto.subtle.exportKey('raw', sessionKey))
    const rsaKey = await importRsaPublicKey(publicKeyPem)
    const ek = new Uint8Array(await crypto.subtle.encrypt({ name: 'RSA-OAEP' }, rsaKey, rawSessionKey))

    return { ek: toBase64(ek), iv: toBase64(iv), data: toBase64(encrypted), ts, nonce }
  } catch {
    return null
  }
}

/** 带 X-Encrypted 头；加密失败回退明文 body */
export async function encryptedLoginBody(payload: LoginEncryptPayload): Promise<{ body: string; encrypted: boolean }> {
  const envelope = await encryptRequestBody(payload as unknown as Record<string, unknown>)
  if (envelope) {
    return { body: JSON.stringify(envelope), encrypted: true }
  }
  return { body: JSON.stringify(payload), encrypted: false }
}

export type LoginEncryptPayload = Record<string, unknown> & { username: string; password: string }
