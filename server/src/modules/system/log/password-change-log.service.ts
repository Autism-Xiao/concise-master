import { Injectable, Logger } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import type { Repository, SelectQueryBuilder } from 'typeorm'

import { Pagination, paginate } from '../../../helper/paginate'
import { TenantContext } from '../../../shared/tenant/tenant.context'
import { randomId32 } from '../../../utils/password.util'
import { PasswordChangeLogEntity } from './entities/password-change-log.entity'

export type PasswordChangeType = 'self' | 'admin_reset' | 'forgot' | 'admin_update'

export interface PasswordChangeInput {
  userId: string
  username: string
  changeType: PasswordChangeType
  operatorId?: string | null
  operatorName?: string | null
  ip?: string | null
  userAgent?: string | null
  remark?: string | null
}

export interface PasswordChangeLogQuery {
  page?: number
  pageSize?: number
  startTime?: string
  endTime?: string
}

/**
 * 密码修改记录服务
 *
 * 设计要点：写记录失败只告警、绝不抛出——审计不能拖垮改密主流程。
 */
@Injectable()
export class PasswordChangeLogService {
  private readonly logger = new Logger(PasswordChangeLogService.name)

  constructor(
    @InjectRepository(PasswordChangeLogEntity)
    private readonly repo: Repository<PasswordChangeLogEntity>
  ) {}

  async record(input: PasswordChangeInput): Promise<void> {
    try {
      await this.repo.insert({
        id: randomId32(),
        tenantId: TenantContext.currentTenantId() ?? 0,
        userId: input.userId,
        username: input.username,
        changeType: input.changeType,
        operatorId: input.operatorId ?? TenantContext.userId() ?? null,
        operatorName: input.operatorName ?? null,
        ip: input.ip?.replace(/^::ffff:/, '') ?? null,
        userAgent: input.userAgent ?? null,
        remark: input.remark ?? null,
        createTime: new Date()
      })
    } catch (error) {
      this.logger.warn(`密码修改记录写入失败：${error instanceof Error ? error.message : String(error)}`)
    }
  }

  async listByUser(userId: string, query: PasswordChangeLogQuery): Promise<Pagination<PasswordChangeLogEntity>> {
    const qb: SelectQueryBuilder<PasswordChangeLogEntity> = this.repo
      .createQueryBuilder('p')
      .where('p.user_id = :userId', { userId })
    this.applyTenant(qb)
    if (query.startTime) qb.andWhere('p.create_time >= :startTime', { startTime: query.startTime })
    if (query.endTime) qb.andWhere('p.create_time <= :endTime', { endTime: query.endTime })
    qb.orderBy('p.create_time', 'DESC').addOrderBy('p.id', 'DESC')
    return paginate(qb, { page: query.page, pageSize: query.pageSize })
  }

  /** 与 sys_log 一致的租户口径：平台视角(null)不过滤，0 只看平台级，>0 只看本租户 */
  private applyTenant(qb: SelectQueryBuilder<PasswordChangeLogEntity>): void {
    const tenantId = TenantContext.filterTenantId()
    if (tenantId === null) return
    if (tenantId === 0) {
      qb.andWhere('1 = 0')
      return
    }
    qb.andWhere('p.tenant_id = :tenantId', { tenantId })
  }
}
