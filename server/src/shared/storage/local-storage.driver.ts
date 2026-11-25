import fs from 'node:fs'
import fsp from 'node:fs/promises'
import path from 'node:path'
import type { Readable } from 'node:stream'

import type { ByteRange, StorageDriver } from './storage.types'

/**
 * 本地磁盘驱动
 *
 * 安全要点：key 可能间接来自用户（例如下载时拼出来的 storageKey），
 * 所以每次落盘前都要做一次「解析后仍在根目录内」的校验 —— 只靠replace('../') 不够，
 * Windows 的盘符、反斜杠、空字节都能绕过字符串过滤，必须走 path.resolve 比对。
 */
export class LocalStorageDriver implements StorageDriver {
  readonly name = 'local'

  constructor(
    private readonly root: string,
    /** 对外 URL 前缀：公开附件传 '/upload/'；私有文件传空串 */
    private readonly urlPrefix = ''
  ) {}

  /** key → 绝对路径；任何越界、绝对路径、空字节的 key 直接拒绝 */
  private resolve(key: string): string {
    const normalized = String(key ?? '').replace(/\\/g, '/')
    if (!normalized || normalized.includes('\0')) {
      throw new Error(`非法的存储 key: ${JSON.stringify(key)}`)
    }
    // 逐段校验：拒绝 ..、拒绝绝对路径（/etc/passwd、C:/...）、拒绝空段（a//b）
    const segments = normalized.split('/')
    if (segments.some(segment => segment === '' || segment === '.' || segment === '..')) {
      throw new Error(`非法的存储 key: ${JSON.stringify(key)}`)
    }

    const rootDir = path.resolve(this.root)
    const target = path.resolve(rootDir, ...segments)
    // 兜底比对：解析后必须仍在根目录内（防盘符/UNC 之类的前缀技巧）
    if (target !== rootDir && !target.startsWith(rootDir + path.sep)) {
      throw new Error(`存储 key 越界: ${JSON.stringify(key)}`)
    }
    return target
  }

  async exists(key: string): Promise<boolean> {
    return (await this.stat(key)) !== null
  }

  async stat(key: string): Promise<{ size: number } | null> {
    try {
      const info = await fsp.stat(this.resolve(key))
      return info.isFile() ? { size: info.size } : null
    } catch (error) {
      if (isMissing(error)) return null
      throw error
    }
  }

  async readHead(key: string, length: number): Promise<Buffer> {
    const target = this.resolve(key)
    const handle = await fsp.open(target, 'r')
    try {
      const buffer = Buffer.alloc(Math.max(length, 0))
      const { bytesRead } = await handle.read(buffer, 0, buffer.length, 0)
      return buffer.subarray(0, bytesRead)
    } finally {
      await handle.close()
    }
  }

  async write(key: string, buffer: Buffer): Promise<void> {
    const target = this.resolve(key)
    await fsp.mkdir(path.dirname(target), { recursive: true })
    // 先写临时文件再 rename：中途失败不会留下半个文件被当成「已存在」而跳过上传
    const temp = `${target}.${process.pid}.${Date.now()}.part`
    try {
      await fsp.writeFile(temp, buffer)
      await fsp.rename(temp, target)
    } catch (error) {
      await fsp.unlink(temp).catch(() => undefined)
      throw error
    }
  }

  async put(key: string, buffer: Buffer): Promise<void> {
    await this.write(key, buffer)
  }

  async saveFromTemp(tempPath: string, key: string): Promise<void> {
    const target = this.resolve(key)
    await fsp.mkdir(path.dirname(target), { recursive: true })
    try {
      // 同盘 rename 是原子的、不拷贝数据；Windows 上目标已存在时 rename 会失败，落进下面的兜底
      await fsp.rename(tempPath, target)
    } catch {
      await fsp.copyFile(tempPath, target)
      await fsp.unlink(tempPath).catch(() => undefined)
    }
  }

  async openStream(key: string, range?: ByteRange): Promise<Readable> {
    const target = this.resolve(key)
    // 先 stat：文件缺失时同步抛给调用方，避免流在响应写出后才 emit error 把进程带崩
    const info = await fsp.stat(target)
    if (!info.isFile()) {
      throw new Error(`不是文件: ${key}`)
    }
    if (range) {
      return fs.createReadStream(target, { start: range.start, end: range.end })
    }
    return fs.createReadStream(target)
  }

  async delete(key: string): Promise<void> {
    try {
      await fsp.unlink(this.resolve(key))
    } catch (error) {
      if (isMissing(error)) return
      throw error
    }
  }

  async remove(key: string): Promise<void> {
    await this.delete(key)
  }

  url(key: string): string {
    const normalized = String(key ?? '').replace(/\\/g, '/').replace(/^\/+/, '')
    if (!this.urlPrefix) return normalized
    const prefix = this.urlPrefix.endsWith('/') ? this.urlPrefix : `${this.urlPrefix}/`
    return `${prefix}${normalized}`
  }
}

/** 文件不存在（含父目录不存在）统一归一化，避免 ENOENT/ENOTDIR 两套分支 */
function isMissing(error: unknown): boolean {
  const code = (error as NodeJS.ErrnoException | undefined)?.code
  return code === 'ENOENT' || code === 'ENOTDIR'
}
