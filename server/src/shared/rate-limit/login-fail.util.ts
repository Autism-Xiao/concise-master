/**
 * 登录失败计数的 Redis key（账号维度，大小写不敏感）
 *
 * AuthService（登录时计数/校验/清零）与 UserService（管理员解锁）共用，
 * 两处各自拼字符串迟早对不上，抽成唯一出口。
 */
export function loginFailKeyOf(username: string): string {
  return `auth:login:fail:${String(username ?? '')
    .trim()
    .toLowerCase()}`
}

/**
 * 登录失败计数的 IP 维度 key（防「换账号不换 IP」的分布式爆破）
 *
 * 与账号维度互补：账号锁定防定向爆破 + 定向锁定 DoS 仍由管理员解锁兜底；
 * IP 维度让同一出口 IP 不能靠换用户名无限试。NAT/公司出口共享 IP，
 * 阈值必须远高于单账号（见 LOGIN_IP_MAX_FAILS），锁定时长也更短。
 */
export function loginIpFailKeyOf(ip: string): string {
  return `auth:login:fail:ip:${String(ip ?? '').trim()}`
}
