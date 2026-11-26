#!/usr/bin/env node
/**
 * 窄口径 ABAC 冒烟：授权行 + 数据规则 → 权限汇总 / 规则解析
 *
 * 不依赖登录（避免脚本里出现账号密码），直接引导 Nest 应用上下文调用 Service：
 *   1. 建一条「订单全部可见」规则（id >= 0 恒真）
 *   2. 给小王授权 biz_order:list 并绑定该规则；再授权 supplier:list / supplier:update
 *   3. 调 AuthService.getPermissions 验证权限码与菜单树里出现了订单/供应商
 *   4. 调 GrantService.getRulesForUser 验证规则能被业务查询取到
 *
 * 用法：node scripts/smoke-grant.mjs
 * 幂等：重复执行不会重复建授权（已存在则复用）。
 */
import 'dotenv/config'

const { NestFactory } = await import('@nestjs/core')
const { AppModule } = await import('../dist/app.module.js')
const { GrantService } = await import('../dist/modules/system/grant/grant.service.js')
const { AuthService } = await import('../dist/modules/auth/services/auth.service.js')

const XIAOWANG_ID = '0c8c4eeb19abc6c501b59287ba5ae9e4'
const PERM_ORDER_LIST = 'menu_biz_order'
const PERM_SUPPLIER_LIST = 'menu_supplier'
const PERM_SUPPLIER_UPDATE = 'menu_supplier_edit'

const app = await NestFactory.createApplicationContext(AppModule, { logger: ['error', 'warn'] })
try {
  const grantService = app.get(GrantService)
  const authService = app.get(AuthService)

  // 1. 规则：订单全部可见（id >= 0 恒真，等价「不过滤」）
  const existingRules = await grantService.listRules('biz_order')
  let rule = existingRules.find(item => item.name === '订单全部可见')
  if (!rule) {
    rule = await grantService.createRule(
      {
        name: '订单全部可见',
        resource: 'biz_order',
        ruleField: 'id',
        ruleOperator: 'gte',
        ruleValue: '0',
        ruleEffect: 'allow'
      },
      'smoke'
    )
    console.log(`+ 规则已创建：${rule.name}（${rule.id}）`)
  } else {
    console.log(`= 规则已存在：${rule.name}（${rule.id}）`)
  }

  // 2. 授权：小王 → 订单查看（绑定规则）；供应商查看 + 编辑
  const grants = await grantService.listGrants({ subjectType: 'user', subjectId: XIAOWANG_ID })
  const ensureGrant = async (permissionId, ruleId, reason) => {
    if (grants.some(item => item.permissionId === permissionId && item.delFlag === 0)) {
      console.log(`= 授权已存在：${permissionId}`)
      return
    }
    await grantService.createGrant(
      { subjectType: 'user', subjectId: XIAOWANG_ID, permissionId, ruleId, reason },
      'smoke'
    )
    console.log(`+ 授权已创建：${permissionId}`)
  }
  await ensureGrant(PERM_ORDER_LIST, rule.id, '研发部跨部门只读订单')
  await ensureGrant(PERM_SUPPLIER_LIST, null, '研发部查看供应商')
  await ensureGrant(PERM_SUPPLIER_UPDATE, null, '研发部维护供应商')

  // 3. 权限汇总
  const permissions = await authService.getPermissions(XIAOWANG_ID)
  const menuNames = (permissions.menus ?? []).flatMap(function flat(menu) {
    return [menu.name, ...(menu.children ?? []).flatMap(flat)]
  })
  console.log('\n[权限码]', permissions.permissions.join(', '))
  console.log('[菜单]', menuNames.filter(Boolean).join(' / '))

  const checks = [
    ['订单查看权限码', permissions.permissions.includes('biz_order:list')],
    ['供应商查看权限码', permissions.permissions.includes('supplier:list')],
    ['供应商编辑权限码', permissions.permissions.includes('supplier:update')],
    ['订单新增权限码（应无）', !permissions.permissions.includes('biz_order:add')],
    ['订单删除权限码（应无）', !permissions.permissions.includes('biz_order:delete')],
    ['订单管理菜单', menuNames.includes('订单管理')],
    ['供应商管理菜单', menuNames.includes('供应商管理')],
    ['客户管理菜单（原有）', menuNames.includes('客户管理')]
  ]

  let failed = 0
  for (const [label, ok] of checks) {
    console.log(`${ok ? '✓' : '✗'} ${label}`)
    if (!ok) failed += 1
  }

  // 4. 规则解析
  const rules = await grantService.getRulesForUser({ id: XIAOWANG_ID, departIds: null, roles: [] }, 'biz_order')
  console.log('\n[订单规则]', rules.map(item => `${item.ruleField} ${item.ruleOperator} ${item.ruleValue}`).join(' | ') || '（无）')
  if (rules.length === 0) failed += 1

  process.exitCode = failed === 0 ? 0 : 1
  console.log(failed === 0 ? '\n全部通过' : `\n${failed} 项不符合预期`)
} finally {
  await app.close()
}
