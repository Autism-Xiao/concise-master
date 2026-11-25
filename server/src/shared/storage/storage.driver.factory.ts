import path from 'node:path'

import { LocalStorageDriver } from './local-storage.driver'
import type { StorageDriver } from './storage.types'

/**
 * 存储驱动工厂：同一套业务代码，落到本地磁盘还是对象存储由 STORAGE_DRIVER 决定
 *
 * 两套根目录，别混用：
 *  - 公开附件（getStorageDriver）：public/upload，由 main.ts 以 /upload/ 前缀静态直出，
 *    只允许放位图/富文本插图，URL 可直接塞进 <img src>；
 *  - 私有文件（storageProvider）：FILE_STORAGE_DIR 或 ./storage/files，内容寻址、不静态托管，
 *    只能经 /api/v1/files/:id/download 鉴权下载。
 *
 * 驱动实例惰性创建并缓存：模块 import 早于 ConfigModule 加载 .env，顶层读环境变量会拿到空值，
 * 根目录必须等到第一次真正用到时再算。
 */

/** 公开附件目录：public/upload（main.ts 的静态托管目录） */
function uploadRoot(): string {
  return path.join(process.cwd(), 'public/upload')
}

/** 私有文件根目录：与 file.service.ts 的 storageRoot() 保持完全一致 */
export function fileStorageRoot(): string {
  return process.env.FILE_STORAGE_DIR?.trim() || path.join(process.cwd(), 'storage/files')
}

let uploadDriver: StorageDriver | undefined
let fileDriver: StorageDriver | undefined

function createDriver(root: string, urlPrefix: string): StorageDriver {
  const name = (process.env.STORAGE_DRIVER ?? 'local').trim().toLowerCase() || 'local'
  if (name === 'local') {
    return new LocalStorageDriver(root, urlPrefix)
  }
  // 不静默降级：配了 oss/s3 却还在写本地盘，线上会出现「文件在 A 实例可见、B 实例 404」
  throw new Error(`不支持的 STORAGE_DRIVER=${name}：当前仅实现 local 驱动，接入对象存储请实现 StorageDriver 后在此注册`)
}

/** 公开附件驱动（头像 / 富文本插图，走 /upload 静态直出） */
export function getStorageDriver(): StorageDriver {
  uploadDriver ??= createDriver(uploadRoot(), '/upload/')
  return uploadDriver
}

/** 私有文件驱动（个人网盘，内容寻址，不对外直出） */
export function storageProvider(): StorageDriver {
  fileDriver ??= createDriver(fileStorageRoot(), '')
  return fileDriver
}
