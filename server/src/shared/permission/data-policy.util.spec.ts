import type { SelectQueryBuilder } from 'typeorm'

import { applyPolicyScope, selectRulesByAction, SUPPORTED_OPERATORS, type ResolvedRule } from './data-policy.util'

/**
 * 数据规则翻译层的单元测试
 *
 * 这一层是「窄口径 ABAC」唯一接触 SQL 的地方，必须锁住三件事：
 * 1. 字段白名单：库里的脏字符串不能进入 SQL；
 * 2. 值参数化：规则值一律走参数，不拼接；
 * 3. allow/deny 的组合语义（OR / AND NOT）。
 */

interface Captured {
  where: Array<{ sql: string; params?: Record<string, unknown> }>
  parameters: Record<string, unknown>[]
}

function createQb(): { qb: SelectQueryBuilder<Record<string, unknown>>; captured: Captured } {
  const captured: Captured = { where: [], parameters: [] }
  const qb = {
    andWhere(sql: string, params?: Record<string, unknown>) {
      captured.where.push({ sql, params })
      return qb
    },
    setParameters(params: Record<string, unknown>) {
      captured.parameters.push(params)
      return qb
    }
  }
  return { qb: qb as unknown as SelectQueryBuilder<Record<string, unknown>>, captured }
}

const actor = { id: 'user-1', deptIds: ['dept-1', 'dept-2'] }
const fields = ['id', 'title', 'status', 'amount', 'createBy', 'tenantId']

function rule(partial: Partial<ResolvedRule>): ResolvedRule {
  return { id: 'r1', ruleField: 'createBy', ruleOperator: 'eq', ruleValue: '$user.id', ruleEffect: 'allow', ...partial }
}

describe('applyPolicyScope', () => {
  it('没有规则时返回 false，交给调用方回退 data_scope', () => {
    const { qb, captured } = createQb()
    expect(applyPolicyScope(qb, 'bizOrder', [], actor, fields)).toBe(false)
    expect(captured.where).toHaveLength(0)
  })

  it('self 之外的单值运算符：SQL 参数化，值不进 SQL 字符串', () => {
    const { qb, captured } = createQb()
    const applied = applyPolicyScope(
      qb,
      'bizOrder',
      [rule({ ruleField: 'amount', ruleOperator: 'gt', ruleValue: '10000' })],
      actor,
      fields
    )
    expect(applied).toBe(true)
    expect(captured.where[0].sql).toBe('(bizOrder.amount > :__rule_p1)')
    expect(captured.where[0].sql).not.toContain('10000')
    expect(captured.parameters[0]).toEqual({ __rule_p1: '10000' })
  })

  it('多条 allow 规则用 OR 连接', () => {
    const { qb, captured } = createQb()
    applyPolicyScope(
      qb,
      'bizOrder',
      [rule({ ruleOperator: 'self' }), rule({ id: 'r2', ruleField: 'status', ruleOperator: 'eq', ruleValue: '1' })],
      actor,
      fields
    )
    expect(captured.where[0].sql).toBe('(bizOrder.createBy = :__rule_p1 OR bizOrder.status = :__rule_p2)')
  })

  it('deny 规则用 AND NOT 追加，优先级高于 allow', () => {
    const { qb, captured } = createQb()
    applyPolicyScope(
      qb,
      'bizOrder',
      [rule({ ruleOperator: 'self' }), rule({ id: 'r2', ruleField: 'status', ruleOperator: 'eq', ruleValue: '9', ruleEffect: 'deny' })],
      actor,
      fields
    )
    expect(captured.where[0].sql).toBe('(bizOrder.createBy = :__rule_p1)')
    expect(captured.where[1].sql).toBe('NOT (bizOrder.status = :__rule_p2)')
  })

  it('in 运算符把逗号分隔值转成数组参数', () => {
    const { qb, captured } = createQb()
    applyPolicyScope(
      qb,
      'bizOrder',
      [rule({ ruleField: 'status', ruleOperator: 'in', ruleValue: '1,2,3' })],
      actor,
      fields
    )
    expect(captured.where[0].sql).toBe('(bizOrder.status IN (:...__rule_p1))')
    expect(captured.parameters[0]).toEqual({ __rule_p1: ['1', '2', '3'] })
  })

  it('dept 运算符用 EXISTS 反查归属部门，不要求业务表有 dept_id', () => {
    const { qb, captured } = createQb()
    applyPolicyScope(qb, 'bizOrder', [rule({ ruleOperator: 'dept' })], actor, fields)
    expect(captured.where[0].sql).toContain('EXISTS (SELECT 1 FROM sys_user_depart')
    expect(captured.where[0].sql).toContain('IN (:...__rule_p1)')
    expect(captured.parameters[0]).toEqual({ __rule_p1: ['dept-1', 'dept-2'] })
  })

  it('字段不在白名单时规则被丢弃', () => {
    const { qb, captured } = createQb()
    const applied = applyPolicyScope(
      qb,
      'bizOrder',
      [rule({ ruleField: 'secret_column', ruleOperator: 'eq', ruleValue: 'x' })],
      actor,
      fields
    )
    expect(applied).toBe(true)
    expect(captured.where[0].sql).toBe('1 = 0')
  })

  it('字段名带注入特征时被正则拦截', () => {
    const { qb, captured } = createQb()
    applyPolicyScope(
      qb,
      'bizOrder',
      [rule({ ruleField: 'id) OR 1=1 --', ruleOperator: 'eq', ruleValue: 'x' })],
      actor,
      [...fields, 'id) OR 1=1 --']
    )
    expect(captured.where[0].sql).toBe('1 = 0')
  })

  it('不支持的运算符被忽略', () => {
    const { qb, captured } = createQb()
    applyPolicyScope(qb, 'bizOrder', [rule({ ruleOperator: 'regexp' as never })], actor, fields)
    expect(captured.where[0].sql).toBe('1 = 0')
  })

  it('只支持白名单里的运算符', () => {
    expect([...SUPPORTED_OPERATORS]).toEqual([
      'eq',
      'ne',
      'gt',
      'gte',
      'lt',
      'lte',
      'in',
      'not_in',
      'like',
      'self',
      'dept'
    ])
  })
})

describe('动作维度：selectRulesByAction', () => {
  const r = (action?: string) => ({ id: action ?? 'all', action })

  it('存量规则（all）在 read / write / delete 下都命中，行为不变', () => {
    const rules = [r('all')]
    expect(selectRulesByAction(rules, 'read')).toHaveLength(1)
    expect(selectRulesByAction(rules, 'write')).toHaveLength(1)
    expect(selectRulesByAction(rules, 'delete')).toHaveLength(1)
  })

  it('动作字段缺失时按 all 处理', () => {
    expect(selectRulesByAction([r()], 'write')).toHaveLength(1)
  })

  it('精确规则优先，读走宽范围、写走窄范围', () => {
    const rules = [r('all'), r('read'), r('write')]
    expect(selectRulesByAction(rules, 'read')[0].id).toBe('read')
    expect(selectRulesByAction(rules, 'write')[0].id).toBe('write')
    expect(selectRulesByAction(rules, 'delete')[0].id).toBe('all')
  })

  it('没有写规则时回退 all，不会误用 read 规则', () => {
    const rules = [r('all'), r('read')]
    expect(selectRulesByAction(rules, 'write')[0].id).toBe('all')
    expect(selectRulesByAction(rules, 'read')[0].id).toBe('read')
  })

  it('只配了 write 规则时，读仍走 all', () => {
    const rules = [r('all'), r('write')]
    expect(selectRulesByAction(rules, 'read')[0].id).toBe('all')
    expect(selectRulesByAction(rules, 'write')[0].id).toBe('write')
  })
})
