import type { Readable } from 'node:stream'

/** 字节区间（含首含尾），与 HTTP Range 语义一致：0-1023 表示前 1024 字节 */
export interface ByteRange {
  start: number
  end: number
}

/**
 * 存储驱动接口
 *
 * key 是「相对存储根的路径」（如 2026/11/<sha256>.bin），由调用方生成；
 * 驱动负责把 key 安全地映射到物理位置，并拒绝任何逃逸出根目录的 key。
 *
 * 为什么做成接口：本地磁盘只是当前实现。接 OSS / MinIO / S3 时新增一个实现、
 * 在 storage.driver.factory.ts 里注册即可，file / upload 业务代码零改动。
 * 私有文件（网盘）与公开附件（头像、富文本插图）用同一个接口、不同的根目录与 url 前缀：
 * 前者绝不能静态直出，后者必须能被 <img src> 直接加载。
 */
export interface StorageDriver {
  /** 驱动名，用于日志与排障（local / oss / s3 ...） */
  readonly name: string
  /** 物理文件是否存在（用于去重秒传、下载前置校验） */
  exists(key: string): Promise<boolean>
  /** 文件大小；不存在返回 null */
  stat(key: string): Promise<{ size: number } | null>
  /** 只读文件头若干字节：用于按魔数验真类型，避免把整个文件读进内存 */
  readHead(key: string, length: number): Promise<Buffer>
  /** 写入（覆盖） */
  write(key: string, buffer: Buffer): Promise<void>
  /** write 的别名，沿用旧调用点的命名 */
  put(key: string, buffer: Buffer): Promise<void>
  /** 把临时文件移入存储位置（同盘 rename，最省 IO）；跨盘时退化为复制 */
  saveFromTemp(tempPath: string, key: string): Promise<void>
  /** 读流；传 range 时只读该区间（断点续传/206 响应） */
  openStream(key: string, range?: ByteRange): Promise<Readable>
  /** 删除；文件不存在视为成功（幂等） */
  delete(key: string): Promise<void>
  /** delete 的别名，沿用旧调用点的命名 */
  remove(key: string): Promise<void>
  /** 对外的访问路径（公开附件形如 /upload/xxx；私有文件不对外，返回 key） */
  url(key: string): string
}
