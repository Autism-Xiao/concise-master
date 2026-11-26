/**
 * 存储驱动统一接口
 *
 * 上传落盘此前写死本地 public/upload（saveLocalFile/deleteFile），
 * 换对象存储要动业务代码。本接口把「写 / 删 / 取访问路径」三个原语抽出来，
 * 业务只认 key（如 `2026-11-21/图片/xxx.png`），落到哪里由驱动决定。
 *
 * key 约定：不含前导斜杠、不含 `/upload/` 前缀的相对键；URL 拼接由驱动负责
 * （本地驱动是 `/upload/<key>`，云驱动将来是签名 URL / CDN 域名）。
 */
export interface StorageDriver {
  /** 驱动名（诊断日志用）：local / oss / minio / ... */
  readonly name: string

  /** 写入一个对象（全量覆盖语义；目录不存在由驱动自行创建） */
  put(key: string, data: Buffer): Promise<void>

  /** 删除一个对象；对象不存在或删除失败静默（沿用旧 deleteFile 语义，不阻断主流程） */
  remove(key: string): Promise<void>

  /** 数据库记录的相对访问路径（历史数据存的是 `/upload/...`，本地驱动保持该格式不变） */
  url(key: string): string
}
