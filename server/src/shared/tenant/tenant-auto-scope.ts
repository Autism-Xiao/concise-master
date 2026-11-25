import { SelectQueryBuilder, type ObjectLiteral } from 'typeorm'

import { tenantCondition } from './tenant-scope.util'

/**
 * 租户过滤兜底（模型层强制）
 *
 * 背景：租户隔离此前完全依赖各 service 手写 `applyTenantScope(qb, alias)`——
 * 漏写一行，查询就跨租户泄漏，且没有任何报错（接口照常 200）。这是应用层纪律，
 * 不是结构性安全。本文件把兜底下沉到 QueryBuilder 执行层：所有走
 * SelectQueryBuilder 的 SELECT，只要主表带 `tenant_id` 列，就在执行前自动注入
 * 与 tenantCondition 完全同语义的过滤条件（租户视角 = 本租户 + 平台共享）。
 *
 * 覆盖范围与已知边界：
 * - 覆盖：qb.getOne/getMany/getOneOrFail/getManyAndCount/getCount/getRawOne/getRawMany，
 *   以及 repository.find()/findOne()（内部走 getMany/getOne）。
 * - 不覆盖：`queryRaw(dataSource, )` / `queryRaw(manager, )` 等原生 SQL（membership/mine 等
 *   关键查询走这里，本来就无需兜底）；嵌入主查询的子查询（createQueryBuilder()
 *   子查询不经执行方法，跨租户子查询仍需手动控制）；UPDATE/DELETE QB 写路径
 *   （写越权由 tenantWriteCondition 手动守，见 tenant-scope.util.ts）。
 *
 * 逃生门：环境变量 `TENANT_AUTO_SCOPE=false` 可整体关闭（灰度/排障用，默认开启）。
 * 单条查询豁免：`qb.skipTenantScope()`——用于刻意跨租户的查询（如平台巡检、
 * 按归属而非当前租户聚合的场景），与 `@IgnoreTenant` 语义的行级豁免对应。
 */

/** 查询级豁免标记：skipTenantScope() 设置 */
const SKIP_TENANT_SCOPE = Symbol('tenant-scope:skip')
/** 注入去重标记：同一 QB 的多个执行入口（getManyAndCount 内部再走 execute*）只注入一次 */
const INJECTED_TENANT_SCOPE = Symbol('tenant-scope:injected')

declare module 'typeorm' {
  interface SelectQueryBuilder<Entity> {
    /** 跳过本次执行的自动租户兜底（链式，只影响当前查询实例） */
    skipTenantScope(): SelectQueryBuilder<Entity>
  }
}

function autoScopeEnabled(): boolean {
  return process.env.TENANT_AUTO_SCOPE !== 'false'
}

/** 主表别名——带 tenant_id 列才返回别名，否则 null（无需过滤） */
function injectableAlias(qb: SelectQueryBuilder<ObjectLiteral>): string | null {
  const mainAlias = qb.expressionMap.mainAlias
  // 别名可能没有 metadata（内部 distinctAlias / 纯 raw 查询场景），Alias.metadata
  // 是「缺失即抛错」的 getter——必须用 hasMetadata 探测，直接访问会把请求炸成 1006
  const alias = mainAlias as unknown as { hasMetadata?: boolean; name?: string; metadata?: { columns: { databaseName: string }[] } } | undefined
  if (!alias || !alias.hasMetadata || !alias.name || !alias.metadata) return null
  const hasTenantColumn = alias.metadata.columns.some(column => column.databaseName === 'tenant_id')
  if (!hasTenantColumn) return null
  return alias.name
}

/** 执行前注入：幂等（INJECTED 标记防重），失败不吞查询（兜底降级为原语义） */
function injectTenantScope(qb: SelectQueryBuilder<ObjectLiteral>): void {
  const self = qb as SelectQueryBuilder<ObjectLiteral> & Record<symbol, unknown>
  if (self[SKIP_TENANT_SCOPE] || self[INJECTED_TENANT_SCOPE]) return
  if (!autoScopeEnabled()) return

  const alias = injectableAlias(qb)
  if (!alias) return

  const condition = tenantCondition(alias)
  if (!condition) return

  self[INJECTED_TENANT_SCOPE] = true
  try {
    qb.andWhere(condition.clause, condition.params)
  } catch {
    // 极端场景（如别名冲突）不应把正常请求炸掉：兜底失败退化为原查询语义，
    // 手写 applyTenantScope 的存量代码此时仍然生效。
    self[INJECTED_TENANT_SCOPE] = false
  }
}

type ExecMethod = (...args: unknown[]) => Promise<unknown>

const PATCHED_METHODS = ['getOne', 'getOneOrFail', 'getMany', 'getManyAndCount', 'getCount', 'getRawOne', 'getRawMany'] as const

/**
 * 全局安装（幂等，可重复调用）。在 TenantContextModule 初始化时执行——
 * 必须晚于 TypeORM DataSource 建立（只是 patch 原型，不依赖注入 DataSource）。
 */
let installed = false
export function installTenantAutoScope(): void {
  if (installed || !autoScopeEnabled()) return
  installed = true

  const prototype = SelectQueryBuilder.prototype as unknown as Record<string, ExecMethod>
  for (const method of PATCHED_METHODS) {
    const original = prototype[method]
    if (typeof original !== 'function') continue
    prototype[method] = function (this: SelectQueryBuilder<ObjectLiteral>, ...args: unknown[]) {
      injectTenantScope(this)
      return original.apply(this, args)
    }
  }

  ;(SelectQueryBuilder.prototype as unknown as Record<string, unknown>).skipTenantScope = function (this: SelectQueryBuilder<ObjectLiteral>) {
    const self = this as SelectQueryBuilder<ObjectLiteral> & Record<symbol, unknown>
    self[SKIP_TENANT_SCOPE] = true
    return this
  }
}
