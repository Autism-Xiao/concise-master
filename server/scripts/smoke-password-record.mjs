#!/usr/bin/env node
/**
 * 密码修改记录 + 操作日志按用户过滤冒烟（不依赖 HTTP 登录）
 *
 * 1. 建测试用户
 * 2. 管理员重置 → 产生 admin_reset 记录
 * 3. 自助改密 → 产生 self 记录
 * 4. 邮箱找回 → 产生 forgot 记录
 * 5. 按用户查询改密记录，核对类型与条数
 * 6. 写一条带 userId 的操作日志，验证按 userId 精确过滤
 * 7. 清理测试数据
 *
 * 用法：node scripts/smoke-password-record.mjs
 */
import 'dotenv/config'

const { NestFactory } = await import('@nestjs/core')
const { AppModule } = await import('../dist/app.module.js')
const { UserService } = await import('../dist/modules/user/user.service.js')
const { PasswordChangeLogService } = await import('../dist/modules/system/log/password-change-log.service.js')
const { LogService } = await import('../dist/modules/system/log/log.service.js')

const app = await NestFactory.createApplicationContext(AppModule, { logger: ['error', 'warn'] })
try {
  const userService = app.get(UserService)
  const pwdLog = app.get(PasswordChangeLogService)
  const logService = app.get(LogService)

  const username = 'smoke_pwdlog_' + Date.now()
  let created
  try {
    created = await userService.create({ username, realname: '改密记录冒烟', status: 1, roleIds: [] }, 'smoke')
    console.log(`1) 测试用户建号成功 id=${created.id}`)

    // 管理员重置（会走 updatePasswordOnly 的 admin_reset 埋点）
    const reset = await userService.resetPassword(created.id, 'AdminReset2026!')
    console.log(`2) 管理员重置完成，临时口令长度=${reset.password.length}`)

    // 自助改密埋点
    await userService.updatePasswordOnly(created.id, 'SelfChange2026!', { changeType: 'self', operatorName: username })
    // 邮箱找回埋点
    await userService.updatePasswordOnly(created.id, 'Forgot2026!', { changeType: 'forgot', remark: '邮箱验证码找回' })

    const records = await pwdLog.listByUser(created.id, { page: 1, pageSize: 20 })
    const rows = records.records ?? []
    const types = rows.map(row => row.changeType)
    console.log(`3) 按用户查到 ${rows.length} 条改密记录，类型=${types.join(',')}`)
    if (rows.length < 3) throw new Error('改密记录条数不足')
    if (!types.includes('admin_reset') || !types.includes('self') || !types.includes('forgot')) {
      throw new Error('改密类型覆盖不全')
    }
    console.log(`4) 账号快照=${rows[0].username}，备注=${rows.find(r => r.changeType === 'forgot')?.remark ?? '-'}`)

    // 操作日志按 userId 过滤：先写一条，再查
    await logService.recordOper({
      userId: created.id,
      username,
      module: '冒烟测试',
      action: '按用户过滤验证',
      operateType: 3,
      ip: '127.0.0.1',
      tenantId: 0,
      status: 0,
      elapsed: 0
    })
    const oper = await logService.listOperLog({ userId: created.id, page: 1, pageSize: 10 })
    const hit = (oper.records ?? []).some(row => row.operateUserId === created.id)
    console.log(`5) 操作日志按 userId 过滤命中=${hit}（共 ${oper.total ?? 0} 条）`)
    if (!hit) throw new Error('操作日志 userId 过滤未命中')

    console.log('\n✅ 全链路通过')
  } finally {
    if (created?.id) {
      // 直接清理测试数据（含改密记录与日志），避免污染
      const ds = userService.repository.manager
      await ds.query('DELETE FROM sys_password_change_log WHERE user_id = $1', [created.id])
      await ds.query('DELETE FROM sys_log WHERE operate_user_id = $1', [created.id])
      await userService.repository.delete(created.id)
      console.log('6) 测试数据已清理')
    }
  }
} finally {
  await app.close()
}
