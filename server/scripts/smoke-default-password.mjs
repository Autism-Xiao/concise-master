#!/usr/bin/env node
/**
 * 默认密码 + 首次登录强制改密冒烟：不依赖 HTTP 登录（避免滑块验证码），
 * 直接引导 Nest 上下文调用 Service 验证整条链路：
 *   1. 建一个「不传密码」的测试用户 → mustChangePassword 应为 1，默认密码可验证通过
 *   2. needsPasswordChange 返回 true
 *   3. 模拟自助改密（updatePasswordOnly + clearPasswordFlags）→ 标记清除
 *   4. 清理测试用户
 *
 * 用法：node scripts/smoke-default-password.mjs
 */
import 'dotenv/config'

const { NestFactory } = await import('@nestjs/core')
const { AppModule } = await import('../dist/app.module.js')
const { UserService } = await import('../dist/modules/user/user.service.js')
const { SystemConfigService } = await import('../dist/modules/system/config/system-config.service.js')

const app = await NestFactory.createApplicationContext(AppModule, { logger: ['error', 'warn'] })
try {
  const userService = app.get(UserService)
  const config = app.get(SystemConfigService)

  const defaultPwd = await config.getString('security.password.default', '')
  console.log(`1) 系统默认密码配置 = ${defaultPwd ? '(已配置, ' + defaultPwd.length + ' 位)' : '(空)'}`)
  if (!defaultPwd) throw new Error('默认密码未配置，无法继续')

  const username = 'smoke_defpwd_' + Date.now()
  let created
  try {
    // 不传密码建号
    created = await userService.create({ username, realname: '默认密码冒烟', status: 1, roleIds: [] }, 'smoke')
    console.log(`2) 建号成功 mustChangePassword=${created.mustChangePassword}（期望 1）`)
    if (created.mustChangePassword !== 1) throw new Error('默认密码建号未强制改密')

    const flags = await userService.needsPasswordChange({ mustChangePassword: created.mustChangePassword, passwordExpireAt: created.passwordExpireAt })
    console.log(`3) needsPasswordChange=${flags}（期望 true）`)
    if (!flags) throw new Error('needsPasswordChange 应为 true')

    // 验证默认密码确实是入库的那个（能 hash 校验通过）
    const withPwd = await userService.findOneWithPassword(created.id)
    const verified = await userService.verifyPassword(withPwd, defaultPwd)
    console.log(`4) 默认密码 ${verified ? '匹配' : '不匹配'} 入库密码（期望 匹配）`)
    if (!verified) throw new Error('默认密码与入库密码不符')

    // 模拟自助改密收口
    await userService.updatePasswordOnly(created.id, 'NewP@ss2026')
    await userService.clearPasswordFlags(created.id)
    const after = await userService.needsPasswordChange({ mustChangePassword: 0, passwordExpireAt: null })
    console.log(`5) 改密并清标记后 needsPasswordChange=${after}（期望 false）`)
    if (after) throw new Error('改密后标记未清除')
    console.log('\n✅ 全链路通过')
  } finally {
    if (created?.id) {
      await userService.repository.delete(created.id)
      console.log(`清理测试用户 ${username}`)
    }
  }
} finally {
  await app.close()
}
