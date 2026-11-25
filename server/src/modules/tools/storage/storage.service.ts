import { Injectable } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { In, type FindOptionsWhere, Repository } from 'typeorm'

import { getStorageDriver } from '../../../shared/storage'
import { TenantContext } from '../../../shared/tenant/tenant.context'
import { StorageEntity } from './storage.entity'

/**
 * 旧版附件记录服务（tool_storage）
 *
 * 上传流程（upload.service）只用到 save()；查询与删除保留给运维/清理场景，
 * 读删一律带租户条件 —— 记录里存的是公开可访问的 URL，跨租户删错人会直接导致对方头像 404。
 */
@Injectable()
export class StorageService {
  constructor(@InjectRepository(StorageEntity) private readonly storageRepository: Repository<StorageEntity>) {}

  /** 新增一条上传记录 */
  async save(record: StorageEntity): Promise<StorageEntity> {
    return this.storageRepository.save(record)
  }

  /** 按 id 批量取（带租户过滤） */
  async findByIds(ids: number[]): Promise<StorageEntity[]> {
    if (!ids.length) return []
    const where: FindOptionsWhere<StorageEntity> = { id: In(ids) }
    const tenantId = TenantContext.filterTenantId()
    if (tenantId !== null) {
      where.tenantId = tenantId
    }
    return this.storageRepository.find({ where })
  }

  /**
   * 按 id 批量删除记录，并顺手清掉磁盘文件
   *
   * 先删库后删盘：删盘失败只留下孤儿文件（可被清理任务回收），
   * 反过来则会留下「点开就 404」的记录，对用户更糟。
   */
  async removeByIds(ids: number[]): Promise<{ removed: number }> {
    const records = await this.findByIds(ids)
    if (!records.length) return { removed: 0 }

    const result = await this.storageRepository.delete({ id: In(records.map(record => record.id)) })
    const storage = getStorageDriver()
    for (const record of records) {
      // 库里存的是 /upload/2026-11-25/图片/xxx.png 这种访问路径，驱动要的是相对 key
      const key = record.path.replace(/^\/?upload\//, '')
      try {
        await storage.remove(key)
      } catch {
        // 物理文件清理失败不影响业务结果，交给每日清理任务兜底
      }
    }
    return { removed: result.affected ?? records.length }
  }
}
