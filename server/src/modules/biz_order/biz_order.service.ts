import { BadRequestException, Injectable } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository, type ObjectLiteral, type SelectQueryBuilder } from 'typeorm'

import { isDuplicateEntryError } from '../../utils/db-error.util'
import { BaseService } from '../../helper/crud/base.service'
import { applySort, paginate, type Pagination } from '../../helper/paginate'
import { TenantContext } from '../../shared/tenant/tenant.context'
import { createTenantQb } from '../../shared/tenant/tenant-qb.factory'
import type { DataAction } from '../../shared/permission/data-policy.util'
import { applyResourceScope, type OwnerScopeActor } from '../../shared/permission/owner-scope.util'
import { GrantService } from '../system/grant/grant.service'
import { CreateBizOrderDto, ListBizOrderDto, UpdateBizOrderDto } from './dto/biz_order.dto'
import { BizOrderEntity } from './entities/biz_order.entity'

/** 可排序字段白名单：前端列 id → 实体属性名（未命中的列点表头也只走默认排序） */
const BIZ_ORDER_SORTABLE: Record<string, string> = {
  title: 'title',
  status: 'status',
  amount: 'amount',
  signedAt: 'signedAt',
  createdAt: 'createdAt'
}

@Injectable()
export class BizOrderService extends BaseService<BizOrderEntity> {
  /** 唯一字段列名；查重必须含软删行（软删行仍占用数据库唯一键，不能过滤 del_flag） */
  private readonly uniqueFields: readonly string[] = []

  private readonly uniqueLabels: Record<string, string> = {
    // 无唯一字段
  }

  constructor(
    @InjectRepository(BizOrderEntity)
    repository: Repository<BizOrderEntity>,
    private readonly grantService: GrantService
  ) {
    super(repository, '订单')
  }

  /** 唯一键查重：excludeId 供更新时排除自身；按租户作用域查（唯一键也是 (tenant_id, 字段)） */
  private async assertUnique(field: string, value: string | number, excludeId?: number): Promise<void> {
    const qb = createTenantQb(this.repository, 't').where('t.' + field + ' = :value', { value })
    if (excludeId !== undefined) qb.andWhere('t.id != :excludeId', { excludeId })
    const exists = await qb.getOne()
    if (exists) throw new BadRequestException(`${this.uniqueLabels[field] ?? field}「${value}」已存在`)
  }

  private async assertAllUnique(dto: object, excludeId?: number): Promise<void> {
    const record = dto as Record<string, unknown>
    for (const field of this.uniqueFields) {
      const value = record[field]
      if (value !== undefined && value !== null && value !== '') {
        await this.assertUnique(field, value as string | number, excludeId)
      }
    }
  }

  /** 可被数据规则引用的字段白名单：直接取实体元数据，字段改名/新增不会漏配 */
  private get policyFields(): string[] {
    return this.repository.metadata.columns.map(column => column.propertyName)
  }

  /**
   * 行级范围：优先数据规则（可表达「订单全部可见」），无规则时回退角色 data_scope。
   * 列表与详情共用这一处，保证「列表看得见 = 详情进得去」。
   */
  protected override async applyRowScope<Q extends ObjectLiteral>(
    qb: SelectQueryBuilder<Q>,
    alias: string,
    actor?: OwnerScopeActor | null,
    ownerColumn = 'createBy',
    action: DataAction = 'read'
  ): Promise<void> {
    const rules = actor ? await this.grantService.getRulesForUser(actor, 'biz_order', action) : []
    applyResourceScope(qb, alias, rules, actor, this.policyFields, ownerColumn)
  }

  /** 分页列表：keyword（模糊） + 精确过滤；数据范围优先走数据规则，无规则时回退角色 data_scope */
  async listByQuery(query: ListBizOrderDto, actor?: OwnerScopeActor | null): Promise<Pagination<BizOrderEntity>> {
    const qb = createTenantQb(this.repository, 'bizOrder').orderBy('bizOrder.id', 'DESC')
    qb.andWhere('bizOrder.delFlag = 0')
    // 规则命中时按规则过滤（支持「订单看全部」这类角色级 data_scope 表达不了的范围）；
    // 没命中则 applyResourceScope 内部回退 applyOwnerScope，存量行为不变
    await this.applyRowScope(qb, 'bizOrder', actor)
    applySort(qb, 'bizOrder', query, BIZ_ORDER_SORTABLE)
    if (query.keyword) {
      qb.andWhere('bizOrder.title LIKE :keyword', { keyword: `%${query.keyword}%` })
    }
    if (query.status !== undefined && query.status !== null) {
      qb.andWhere('bizOrder.status = :status', { status: query.status })
    }
    return paginate(qb, { page: query.page, pageSize: query.pageSize })
  }

  /** 详情：与列表同一套 owner 收窄，列表看不见的订单按 id 也读不到 */
  async findOneScoped(
    id: number,
    actor?: OwnerScopeActor | null,
    ownerColumn = 'createBy',
    action: DataAction = 'read'
  ): Promise<BizOrderEntity> {
    return super.findOneScoped(id, actor, ownerColumn, action)
  }

  /** 新增：唯一键查重 + 落 createBy；并发写兜底捕获 ER_DUP_ENTRY 转 400 */
  async create(dto: CreateBizOrderDto): Promise<BizOrderEntity> {
    await this.assertAllUnique(dto)
    try {
      return await super.create({ ...dto, createBy: TenantContext.userId() })
    } catch (error) {
      if (isDuplicateEntryError(error)) {
        throw new BadRequestException('订单与已有数据冲突（唯一约束），请检查唯一字段是否重复')
      }
      throw error
    }
  }

  /** 修改：唯一键查重（排除自身）+ 落 updateBy */
  async update(id: number, dto: UpdateBizOrderDto, actor?: OwnerScopeActor | null): Promise<BizOrderEntity> {
    await this.assertAllUnique(dto, id)
    try {
      // 行级校验收进基类：action='write'，与列表/详情的 read 规则各自独立解析
      return await super.updateScoped(id, { ...dto, updateBy: TenantContext.userId() }, actor)
    } catch (error) {
      if (isDuplicateEntryError(error)) {
        throw new BadRequestException('订单与已有数据冲突（唯一约束），请检查唯一字段是否重复')
      }
      throw error
    }
  }

  /** 软删除：del_flag 置 1；软删行仍占用唯一键，与查重「含软删占用」配套 */
  async delete(id: number, actor?: OwnerScopeActor | null): Promise<void> {
    // 基类按 action='delete' 做行级校验 + 严格租户写条件，共享行 / 无权行都不可删
    await this.softDeleteScoped(id, { delFlag: 1 }, actor)
  }
}
