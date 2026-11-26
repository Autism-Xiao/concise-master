import { Injectable } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository, type ObjectLiteral, type SelectQueryBuilder } from 'typeorm'

import { BaseService } from '../../helper/crud/base.service'
import { paginate, type Pagination } from '../../helper/paginate'
import { createTenantQb } from '../../shared/tenant/tenant-qb.factory'
import { applyPolicyScope } from '../../shared/permission/data-policy.util'
import type { OwnerScopeActor } from '../../shared/permission/owner-scope.util'
import { GrantService } from '../system/grant/grant.service'
import { SupplierEntity } from './entities/supplier.entity'

@Injectable()
export class SupplierService extends BaseService<SupplierEntity> {
  constructor(
    @InjectRepository(SupplierEntity)
    repository: Repository<SupplierEntity>,
    private readonly grantService: GrantService
  ) {
    super(repository, '供应商')
  }

  /** 可被数据规则引用的字段白名单：直接取实体元数据 */
  private get policyFields(): string[] {
    return this.repository.metadata.columns.map(column => column.propertyName)
  }

  /**
   * 行级范围：供应商表没有 createBy 列，**不走 owner scope 兜底**（否则 SQL 会引用不存在的列），
   * 只应用显式配置的数据规则；没配规则时保持「租户内全部可见」的现状。
   */
  protected override async applyRowScope<Q extends ObjectLiteral>(
    qb: SelectQueryBuilder<Q>,
    alias: string,
    actor?: OwnerScopeActor | null,
    ownerColumn = 'createBy'
  ): Promise<void> {
    if (!actor) return
    if (Number(actor.isPlatformAdmin ?? 0) === 1) return

    const rules = await this.grantService.getRulesForUser(actor, 'supplier')
    const deptIds = String(actor.departIds ?? '')
      .split(',')
      .map(value => value.trim())
      .filter(Boolean)
    applyPolicyScope(qb, alias, rules, { id: actor.id, deptIds }, this.policyFields, ownerColumn)
  }

  /** 分页列表：keyword（模糊） + 精确过滤 */
  async listByQuery(
    query: { page?: number; pageSize?: number; keyword?: string; name?: string },
    actor?: OwnerScopeActor | null
  ): Promise<Pagination<SupplierEntity>> {
    const qb = createTenantQb(this.repository, 'supplier').orderBy('supplier.id', 'DESC')
    qb.andWhere('supplier.delFlag = 0')
    await this.applyRowScope(qb, 'supplier', actor)
    if (query.keyword) {
      qb.andWhere('supplier.name LIKE :keyword', { keyword: `%${query.keyword}%` })
    }
    if (query.name !== undefined && query.name !== null) {
      qb.andWhere('supplier.name = :name', { name: query.name })
    }
    return paginate(qb, { page: query.page, pageSize: query.pageSize })
  }
}
