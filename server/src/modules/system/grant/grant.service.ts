import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { randomUUID } from 'node:crypto'
import { DataSource, In, Repository } from 'typeorm'

import { TenantContext } from '../../../shared/tenant/tenant.context'
import { selectRulesByAction, type DataAction, type PolicyActor, type ResolvedRule } from '../../../shared/permission/data-policy.util'
import { DataRuleEntity } from './entities/data-rule.entity'
import { GrantEntity } from './entities/grant.entity'

/** 主体上下文：从登录用户（req.user / UserEntity）里提取，供 grants 匹配 */
export interface GrantSubject extends PolicyActor {
  deptIds: string[]
  roleIds: string[]
  positionIds: string[]
}

/** 授权行可接受的主体类型 */
export const SUBJECT_TYPES = ['user', 'dept', 'position', 'role'] as const
export type SubjectType = (typeof SUBJECT_TYPES)[number]

interface CacheEntry {
  value: GrantEntity[]
  expiresAt: number
}

/**
 * 例外授权 + 数据规则服务
 *
 * 职责边界：
 * - 授权（sys_grant）：谁能额外拿到哪个权限点，可选绑定一条数据规则、可选过期时间；
 * - 规则（sys_data_rule）：一个资源上「哪些行可见」的可复用描述，由 data-policy.util 翻译成 SQL。
 *
 * 缓存策略与 AuthUserCache 同口径：进程内 30s，写路径（授权/规则变更）立刻清空。
 * 授权是低频写、高频读的数据，且 PermsGuard 在每个请求上都会用到，不缓存会成为热路径。
 */
@Injectable()
export class GrantService {
  private static readonly TTL_MS = 30_000
  private readonly cache = new Map<string, CacheEntry>()
  /** 用户岗位 ID 的短缓存：resolveSubject 在每个鉴权请求上都会跑，不能每次都查 sys_user_post */
  private readonly positionCache = new Map<string, { value: string[]; expiresAt: number }>()

  constructor(
    @InjectRepository(GrantEntity) private readonly grantRepo: Repository<GrantEntity>,
    @InjectRepository(DataRuleEntity) private readonly ruleRepo: Repository<DataRuleEntity>,
    private readonly dataSource: DataSource
  ) {}

  /* ============================ 判定侧 ============================ */

  /**
   * 从登录用户对象解析主体上下文
   *
   * deptIds 来自 sys_user.depart_ids（逗号分隔的历史字段），roleIds 来自 roles，
   * positionIds 需要查 sys_user_post —— 只在有 position 主体授权时才有意义，
   * 这里一并查出并随 grants 一起缓存，避免每个请求多一次查询。
   */
  async resolveSubject(user: {
    id: string
    departIds?: string | null
    roles?: Array<{ id?: string }> | null
  }): Promise<GrantSubject> {
    const deptIds = String(user.departIds ?? '')
      .split(',')
      .map(value => value.trim())
      .filter(Boolean)
    const roleIds = (user.roles ?? []).map(role => role.id).filter((id): id is string => !!id)
    const positionIds = await this.loadPositionIds(user.id)
    return { id: user.id, deptIds, roleIds, positionIds }
  }

  /** 该用户命中的有效授权（已过滤停用/软删/过期/租户） */
  async loadGrants(subject: GrantSubject, tenantId: number | null): Promise<GrantEntity[]> {
    const key = `${tenantId ?? 'platform'}:${subject.id}`
    const cached = this.cache.get(key)
    if (cached && cached.expiresAt > Date.now()) {
      return cached.value
    }

    const qb = this.grantRepo
      .createQueryBuilder('g')
      .where('g.status = :status', { status: 1 })
      .andWhere('g.del_flag = :delFlag', { delFlag: 0 })
      // 过期行直接排除：不做定时清理，判定时忽略即可（expire_at 为空 = 永久）
      .andWhere('(g.expire_at IS NULL OR g.expire_at > :now)', { now: new Date() })

    if (tenantId !== null) {
      // 平台共享授权（tenant_id=0）对所有租户生效；租户自己的授权只在本租户生效
      qb.andWhere('(g.tenant_id = 0 OR g.tenant_id = :tenantId)', { tenantId })
    }

    // 主体匹配：user 直授 ∪ dept ∪ role ∪ position，四路 OR
    const ors: string[] = ['(g.subject_type = :subjectUser AND g.subject_id = :userId)']
    const params: Record<string, unknown> = { subjectUser: 'user', userId: subject.id }
    if (subject.deptIds.length > 0) {
      ors.push('(g.subject_type = :subjectDept AND g.subject_id IN (:...deptIds))')
      params.subjectDept = 'dept'
      params.deptIds = subject.deptIds
    }
    if (subject.roleIds.length > 0) {
      ors.push('(g.subject_type = :subjectRole AND g.subject_id IN (:...roleIds))')
      params.subjectRole = 'role'
      params.roleIds = subject.roleIds
    }
    if (subject.positionIds.length > 0) {
      ors.push('(g.subject_type = :subjectPosition AND g.subject_id IN (:...positionIds))')
      params.subjectPosition = 'position'
      params.positionIds = subject.positionIds
    }
    qb.andWhere(`(${ors.join(' OR ')})`, params)

    const grants = await qb.getMany()
    this.setCache(key, grants)
    return grants
  }

  /**
   * 授权带来的功能权限码（perms 字符串），与角色权限取并集后交给 PermsGuard
   *
   * 这里刻意只返回 perms 字符串而不是权限点对象：守卫和 /auth/permissions 都按
   * 「权限码集合」工作，返回同构数据可以让调用方零改动地合并两路来源。
   */
  async getGrantedPerms(subject: GrantSubject, tenantId: number | null): Promise<string[]> {
    const grants = await this.loadGrants(subject, tenantId)
    if (grants.length === 0) return []

    const permissionIds = [...new Set(grants.filter(g => g.ruleEffect !== 'deny').map(g => g.permissionId).filter(Boolean))]
    if (permissionIds.length === 0) return []

    const rows = await this.dataSource
      .createQueryBuilder()
      .select('p.perms', 'perms')
      .from('sys_permission', 'p')
      .where('p.id IN (:...permissionIds)', { permissionIds })
      .andWhere("p.status = '1'")
      .andWhere('p.del_flag = 0')
      .getRawMany<{ perms: string | null }>()

    return [...new Set(rows.map(row => row.perms).filter((perm): perm is string => !!perm))]
  }

  /**
   * 该用户在某资源、某动作上命中的数据规则（已按优先级升序）
   *
   * 只有绑定了 rule_id 的授权才算数；没有任何规则时返回空数组，
   * 业务层据此回退旧的 data_scope 逻辑（存量行为不变）。
   *
   * 动作解析：精确匹配（read/write/delete）优先；没有精确规则才回退 all 通用规则。
   * 这样存量的 all 规则行为完全不变，而底座已经具备「看本部门、只改自己」的表达力。
   */
  async getRules(
    subject: GrantSubject,
    resource: string,
    tenantId: number | null,
    action: DataAction = 'all'
  ): Promise<ResolvedRule[]> {
    const grants = await this.loadGrants(subject, tenantId)
    const ruleIds = [...new Set(grants.map(grant => grant.ruleId).filter((id): id is string => !!id))]
    if (ruleIds.length === 0) return []

    const rules = await this.ruleRepo.find({
      where: { id: In(ruleIds), resource, status: 1, delFlag: 0 },
      order: { priority: 'ASC' }
    })
    // 一次查出该资源的全部规则，再按动作筛选：精确匹配优先，未命中回退 all。
    const effective = selectRulesByAction(rules, action)

    return effective.map(rule => ({
      id: rule.id,
      ruleField: rule.ruleField,
      ruleOperator: rule.ruleOperator,
      ruleValue: rule.ruleValue,
      ruleEffect: rule.ruleEffect
    }))
  }

  /**
   * 业务查询用的便捷入口：从 req.user 直接解析主体并取规则
   *
   * 业务 service 不持有 position/role 的完整上下文，交给这里补齐，
   * 避免每个模块重复写一遍 resolveSubject。
   */
  async getRulesForUser(
    user: { id: string; departIds?: string | null; roles?: Array<{ id?: string }> | null },
    resource: string,
    action: DataAction = 'all'
  ): Promise<ResolvedRule[]> {
    const subject = await this.resolveSubject(user)
    return this.getRules(subject, resource, TenantContext.filterTenantId(), action)
  }

  /* ============================ 授权管理 ============================ */

  async listGrants(filter: { subjectType?: string; subjectId?: string; permissionId?: string }): Promise<GrantEntity[]> {
    const qb = this.grantRepo.createQueryBuilder('g').where('g.del_flag = 0')
    this.applyTenant(qb)
    if (filter.subjectType) qb.andWhere('g.subject_type = :subjectType', { subjectType: filter.subjectType })
    if (filter.subjectId) qb.andWhere('g.subject_id = :subjectId', { subjectId: filter.subjectId })
    if (filter.permissionId) qb.andWhere('g.permission_id = :permissionId', { permissionId: filter.permissionId })
    return qb.orderBy('g.create_time', 'DESC').getMany()
  }

  async createGrant(
    dto: {
      subjectType: string
      subjectId: string
      permissionId: string
      ruleId?: string | null
      expireAt?: string | null
      reason?: string | null
    },
    operatorId?: string
  ): Promise<GrantEntity> {
    this.assertSubjectType(dto.subjectType)
    // 同一主体 + 权限点只允许一条有效授权，避免重复行让审计看不出「到底给了几次」
    const existing = await this.grantRepo.findOne({
      where: {
        subjectType: dto.subjectType,
        subjectId: dto.subjectId,
        permissionId: dto.permissionId,
        tenantId: this.writeTenantId(),
        delFlag: 0
      }
    })
    if (existing) {
      throw new BadRequestException('该主体已有此权限点的授权，请直接修改现有授权')
    }

    const entity = this.grantRepo.create({
      id: randomUUID().replace(/-/g, ''),
      tenantId: this.writeTenantId(),
      subjectType: dto.subjectType,
      subjectId: dto.subjectId,
      permissionId: dto.permissionId,
      ruleId: dto.ruleId ?? null,
      ruleEffect: 'allow',
      expireAt: dto.expireAt ? new Date(dto.expireAt) : null,
      reason: dto.reason ?? null,
      status: 1,
      delFlag: 0,
      grantBy: operatorId,
      createTime: new Date()
    })
    const saved = await this.grantRepo.save(entity)
    this.clearCache()
    return saved
  }

  async updateGrant(
    id: string,
    dto: { ruleId?: string | null; expireAt?: string | null; reason?: string | null; status?: number },
    operatorId?: string
  ): Promise<GrantEntity> {
    const grant = await this.grantRepo.findOne({ where: { id, delFlag: 0 } })
    if (!grant) throw new NotFoundException('授权不存在')
    if (dto.ruleId !== undefined) grant.ruleId = dto.ruleId
    if (dto.expireAt !== undefined) grant.expireAt = dto.expireAt ? new Date(dto.expireAt) : null
    if (dto.reason !== undefined) grant.reason = dto.reason
    if (dto.status !== undefined) grant.status = dto.status
    grant.updateTime = new Date()
    if (operatorId) grant.grantBy = operatorId
    const saved = await this.grantRepo.save(grant)
    this.clearCache()
    return saved
  }

  /** 软删：保留行用于审计（谁在什么时候给谁开过、为什么收回） */
  async removeGrant(id: string): Promise<void> {
    const grant = await this.grantRepo.findOne({ where: { id, delFlag: 0 } })
    if (!grant) throw new NotFoundException('授权不存在')
    grant.delFlag = 1
    grant.updateTime = new Date()
    await this.grantRepo.save(grant)
    this.clearCache()
  }

  /* ============================ 规则管理 ============================ */

  async listRules(resource?: string): Promise<DataRuleEntity[]> {
    const qb = this.ruleRepo.createQueryBuilder('r').where('r.del_flag = 0')
    this.applyTenant(qb)
    if (resource) qb.andWhere('r.resource = :resource', { resource })
    return qb.orderBy('r.priority', 'ASC').addOrderBy('r.create_time', 'DESC').getMany()
  }

  async createRule(
    dto: {
      name: string
      resource: string
      action?: string
      ruleField: string
      ruleOperator: string
      ruleValue?: string | null
      ruleEffect?: string
      priority?: number
    },
    operatorId?: string
  ): Promise<DataRuleEntity> {
    const entity = this.ruleRepo.create({
      id: randomUUID().replace(/-/g, ''),
      tenantId: this.writeTenantId(),
      name: dto.name,
      resource: dto.resource,
      action: dto.action ?? 'all',
      ruleField: dto.ruleField,
      ruleOperator: dto.ruleOperator,
      ruleValue: dto.ruleValue ?? null,
      ruleEffect: dto.ruleEffect === 'deny' ? 'deny' : 'allow',
      priority: dto.priority ?? 100,
      status: 1,
      delFlag: 0,
      createBy: operatorId,
      createTime: new Date()
    })
    const saved = await this.ruleRepo.save(entity)
    this.clearCache()
    return saved
  }

  async updateRule(
    id: string,
    dto: {
      name?: string
      action?: string
      ruleField?: string
      ruleOperator?: string
      ruleValue?: string | null
      ruleEffect?: string
      priority?: number
      status?: number
    },
    operatorId?: string
  ): Promise<DataRuleEntity> {
    const rule = await this.ruleRepo.findOne({ where: { id, delFlag: 0 } })
    if (!rule) throw new NotFoundException('规则不存在')
    if (dto.name !== undefined) rule.name = dto.name
    if (dto.action !== undefined) rule.action = dto.action
    if (dto.ruleField !== undefined) rule.ruleField = dto.ruleField
    if (dto.ruleOperator !== undefined) rule.ruleOperator = dto.ruleOperator
    if (dto.ruleValue !== undefined) rule.ruleValue = dto.ruleValue
    if (dto.ruleEffect !== undefined) rule.ruleEffect = dto.ruleEffect === 'deny' ? 'deny' : 'allow'
    if (dto.priority !== undefined) rule.priority = dto.priority
    if (dto.status !== undefined) rule.status = dto.status
    rule.updateBy = operatorId
    rule.updateTime = new Date()
    const saved = await this.ruleRepo.save(rule)
    this.clearCache()
    return saved
  }

  async removeRule(id: string): Promise<void> {
    const rule = await this.ruleRepo.findOne({ where: { id, delFlag: 0 } })
    if (!rule) throw new NotFoundException('规则不存在')
    // 被授权引用时不允许直接删，否则授权会静默退化成 data_scope 兜底（可见范围突然变化）
    const used = await this.grantRepo.count({ where: { ruleId: id, delFlag: 0 } })
    if (used > 0) {
      throw new BadRequestException(`该规则仍被 ${used} 条授权引用，请先解除绑定`)
    }
    rule.delFlag = 1
    rule.updateTime = new Date()
    await this.ruleRepo.save(rule)
    this.clearCache()
  }

  /* ============================ 内部 ============================ */

  /** 当前写入租户：平台视角（null）落 0，与项目其他表的租户语义一致 */
  private writeTenantId(): number {
    return TenantContext.filterTenantId() ?? 0
  }

  /** 列表查询的租户收窄：平台共享（0）+ 当前租户 */
  private applyTenant(qb: { andWhere: (sql: string, params?: object) => unknown }): void {
    const tenantId = TenantContext.filterTenantId()
    if (tenantId === null) return
    qb.andWhere('(tenant_id = 0 OR tenant_id = :tenantId)', { tenantId })
  }

  private assertSubjectType(type: string): void {
    if (!(SUBJECT_TYPES as readonly string[]).includes(type)) {
      throw new BadRequestException(`不支持的主体类型：${type}`)
    }
  }

  private async loadPositionIds(userId: string): Promise<string[]> {
    const cached = this.positionCache.get(userId)
    if (cached && cached.expiresAt > Date.now()) return cached.value

    const rows = await this.dataSource
      .createQueryBuilder()
      .select('up.post_id', 'postId')
      .from('sys_user_post', 'up')
      .where('up.user_id = :userId', { userId })
      .getRawMany<{ postId: string }>()
    const value = rows.map(row => row.postId).filter(Boolean)
    if (this.positionCache.size > 2000) {
      const now = Date.now()
      for (const [key, entry] of this.positionCache) {
        if (entry.expiresAt <= now) this.positionCache.delete(key)
      }
    }
    this.positionCache.set(userId, { value, expiresAt: Date.now() + GrantService.TTL_MS })
    return value
  }

  private setCache(key: string, value: GrantEntity[]): void {
    if (this.cache.size > 2000) {
      const now = Date.now()
      for (const [entryKey, entry] of this.cache) {
        if (entry.expiresAt <= now) this.cache.delete(entryKey)
      }
    }
    this.cache.set(key, { value, expiresAt: Date.now() + GrantService.TTL_MS })
  }

  /** 授权/规则变化后清空：量小，直接全清，避免漏键导致降权不即时 */
  clearCache(): void {
    this.cache.clear()
  }
}
