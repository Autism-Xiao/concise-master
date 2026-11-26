import type { ObjectLiteral, SelectQueryBuilder } from 'typeorm'

/**
 * 数据规则 → QueryBuilder 条件（窄口径 ABAC 的翻译层）
 *
 * 安全约束（务必守住，否则就是 SQL 注入口）：
 * 1. **字段白名单**：rule_field 必须是调用方传入的实体列名集合里的值，
 *    绝不把库里的字符串直接拼进 SQL。白名单由各业务 service 声明（通常是实体列名）。
 * 2. **运算符枚举**：只认 SUPPORTED_OPERATORS 里的值，不支持任意表达式。
 * 3. **值全部参数化**：rule_value 一律走 setParameters，不做字符串拼接；
 *    in / not_in 的数组也走 :...name 展开。
 *
 * 与旧 data_scope 的关系：
 * - 命中规则（至少一条可用规则）→ 用规则生成条件，**不再**应用 data_scope；
 * - 一条规则都没有 → 返回 false，调用方回退 applyOwnerScope（存量行为完全不变）。
 *
 * 效果语义：
 * - allow 规则之间是 **OR**（满足任意一条即可见）；
 * - deny 规则之间是 **AND NOT**（命中任意一条即被排除），deny 优先级高于 allow；
 * - 只有 deny 没有 allow 时，视为「全量减去 deny 部分」。
 */
export interface PolicyActor {
  id: string
  isPlatformAdmin?: number
  /** 用户所属部门（sys_user_depart.dep_id） */
  deptIds?: string[] | null
}

/** 规则的可执行形态（service 从库里查出来后裁剪成这个结构） */
export interface ResolvedRule {
  id: string
  ruleField: string
  ruleOperator: string
  ruleValue?: string | null
  ruleEffect: string
}

/** 支持的运算符：新增时同步补 switch 分支与前端下拉 */
export const SUPPORTED_OPERATORS = ['eq', 'ne', 'gt', 'gte', 'lt', 'lte', 'in', 'not_in', 'like', 'self', 'dept'] as const
export type RuleOperator = (typeof SUPPORTED_OPERATORS)[number]

/** 上下文变量：规则值里可以引用当前用户，避免为每个人写一条规则 */
export const RULE_VARIABLE_USER_ID = '$user.id'
export const RULE_VARIABLE_USER_DEPT_IDS = '$user.deptIds'

const FIELD_PATTERN = /^[A-Za-z_][A-Za-z0-9_]*$/

/**
 * 把规则集合应用到查询上
 *
 * @param qb            已注入租户条件的 QueryBuilder
 * @param alias         主表别名
 * @param rules         命中的规则（已按 priority 升序）
 * @param actor         当前用户
 * @param allowedFields 该资源允许被规则引用的实体列名（白名单）
 * @param ownerColumn   「self / dept」运算符使用的归属列，默认 createBy
 * @returns 是否应用了规则；false 表示调用方应回退旧的 data_scope 逻辑
 */
export function applyPolicyScope<T extends ObjectLiteral>(
  qb: SelectQueryBuilder<T>,
  alias: string,
  rules: ResolvedRule[] | null | undefined,
  actor: PolicyActor,
  allowedFields: string[],
  ownerColumn = 'createBy'
): boolean {
  const list = (rules ?? []).filter(rule => rule && rule.ruleField && rule.ruleOperator)
  if (list.length === 0) return false

  const allowed = new Set(allowedFields)
  const params: Record<string, unknown> = {}
  const state = { seq: 0 }
  const allowSql: string[] = []
  const denySql: string[] = []

  for (const rule of list) {
    const condition = buildCondition(rule, alias, actor, allowed, ownerColumn, params, state)
    if (!condition) continue
    if (rule.ruleEffect === 'deny') {
      denySql.push(condition)
    } else {
      allowSql.push(condition)
    }
  }

  // 规则全被白名单挡掉（脏数据 / 字段改名）：按「无可见数据」处理，宁可少看
  if (allowSql.length === 0 && denySql.length === 0) {
    qb.andWhere('1 = 0')
    return true
  }

  if (allowSql.length > 0) {
    qb.andWhere(`(${allowSql.join(' OR ')})`)
  }
  for (const deny of denySql) {
    qb.andWhere(`NOT (${deny})`)
  }
  if (Object.keys(params).length > 0) {
    qb.setParameters(params)
  }
  return true
}

/** 单条规则 → SQL 片段（参数写入 params）；不合法返回 null */
function buildCondition(
  rule: ResolvedRule,
  alias: string,
  actor: PolicyActor,
  allowedFields: Set<string>,
  ownerColumn: string,
  params: Record<string, unknown>,
  state: { seq: number }
): string | null {
  const operator = String(rule.ruleOperator).toLowerCase()
  if (!(SUPPORTED_OPERATORS as readonly string[]).includes(operator)) return null

  const column = resolveColumn(rule.ruleField, operator, allowedFields, ownerColumn)
  if (!column) return null

  const param = `__rule_p${++state.seq}`
  const target = `${alias}.${column}`
  const rawValue = rule.ruleValue ?? ''

  switch (operator) {
    case 'eq':
    case 'ne':
    case 'gt':
    case 'gte':
    case 'lt':
    case 'lte': {
      const symbol = { eq: '=', ne: '<>', gt: '>', gte: '>=', lt: '<', lte: '<=' }[operator]
      params[param] = resolveScalar(rawValue, actor)
      return `${target} ${symbol} :${param}`
    }
    case 'like':
      params[param] = `%${rawValue}%`
      return `${target} LIKE :${param}`
    case 'in':
    case 'not_in': {
      const values = splitValues(rawValue, actor)
      if (values.length === 0) return null
      params[param] = values
      return `${target} ${operator === 'not_in' ? 'NOT IN' : 'IN'} (:...${param})`
    }
    case 'self':
      params[param] = actor.id
      return `${target} = :${param}`
    case 'dept': {
      // 值留空 / $user.deptIds / $user.id 都表示「当前用户所在部门」；
      // 显式写部门 ID 列表时才按列表过滤
      const useSelfDepts =
        !rawValue.trim() || rawValue.trim() === RULE_VARIABLE_USER_DEPT_IDS || rawValue.trim() === RULE_VARIABLE_USER_ID
      const deptIds = useSelfDepts ? (actor.deptIds ?? []) : splitValues(rawValue, actor)
      if (deptIds.length === 0) return null
      params[param] = deptIds
      // 业务表没有 dept_id，用 EXISTS 反查归属人部门，与 owner-scope 同口径
      return `EXISTS (SELECT 1 FROM sys_user_depart __rule_ud WHERE __rule_ud.user_id = ${target} AND __rule_ud.dep_id IN (:...${param}))`
    }
    default:
      return null
  }
}

/** 字段校验：白名单 + 标识符格式；self/dept 固定落到归属列 */
function resolveColumn(field: string, operator: string, allowed: Set<string>, ownerColumn: string): string | null {
  if (operator === 'self' || operator === 'dept') {
    return allowed.has(ownerColumn) ? ownerColumn : null
  }
  if (!field || !FIELD_PATTERN.test(field)) return null
  return allowed.has(field) ? field : null
}

/** 标量取值：支持 $user.id 变量 */
function resolveScalar(raw: string, actor: PolicyActor): string {
  const value = String(raw ?? '').trim()
  if (value === RULE_VARIABLE_USER_ID) return actor.id
  return value
}

/** 列表取值：支持 $user.deptIds，逗号分隔 */
function splitValues(raw: string, actor: PolicyActor): string[] {
  const value = String(raw ?? '').trim()
  const source = value === RULE_VARIABLE_USER_DEPT_IDS ? (actor.deptIds ?? []).join(',') : value
  return source
    .split(',')
    .map(item => item.trim())
    .filter(Boolean)
}
