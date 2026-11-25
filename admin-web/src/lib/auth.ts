import { clearRememberToken, getRememberToken } from '@/lib/remember-token'
import { resetSessionCaches } from '@/lib/session-reset'
import { store } from '@/stores'
import { authActions } from '@/stores/auth-slice'

/**
 * 认证数据门面
 *
 * 所有函数的签名和语义与迁移前完全一致——调用方（路由守卫、http 层、各 api、组件）
 * 不需要任何改动。底层数据源已从散落的 localStorage 换成 Redux store：
 * - 读：同步读 store（内存），首帧即可用
 * - 写：dispatch action，store 的订阅同步落盘到 localStorage/sessionStorage
 */

/**
 * 登录态变化事件
 *
 * 设置 Provider 挂在 `__root` 上一直不卸载，登录用的是 `navigate()` 而非整页刷新，
 * 所以它感知不到「刚刚登录了」。登录/登出时发一个事件，让它重新拉一次云端设置，
 * 否则换设备登录后要手动刷新一次才能看到自己的主题色。
 */
export const AUTH_CHANGED_EVENT = 'concise:auth-changed'

function notifyAuthChanged(): void {
  window.dispatchEvent(new Event(AUTH_CHANGED_EVENT))
}

export interface LoginAccount {
  username: string
  name: string
  /** 角色 code，对应 roles.json 的 code 字段 */
  role: string
}

export function isAuthenticated(): boolean {
  return store.getState().auth.authenticated
}

export function login(account: LoginAccount): void {
  const previous = store.getState().auth
  // 换号（SSO / 静默续登 / 不经过登出的重登）必须彻底复位，否则上一个账号的
  // 权限、字典、主题、租户视角会跟着带进新会话。调用方在 login() 之后写令牌。
  if (previous.authenticated && previous.username !== account.username) {
    resetSessionCaches('account')
  }
  store.dispatch(authActions.setAccount(account))
  notifyAuthChanged()
}

export function getUsername(): string {
  return store.getState().auth.username
}

export function getName(): string {
  const { displayName, username } = store.getState().auth
  return displayName || username
}

/**
 * 更新本地缓存的显示名（个人资料改完姓名后用）
 *
 * 顺手广播一次登录态变化事件：侧边栏 NavUser 原本只读一次 localStorage，
 * 不广播的话头像旁边的名字要等下次整页刷新才变。
 */
export function setDisplayName(name: string): void {
  store.dispatch(authActions.setDisplayName(name))
  notifyAuthChanged()
}

/* ---------- 头像缓存 ---------- */

export function getAvatar(): string {
  return store.getState().auth.avatar
}

/**
 * 更新本地缓存的头像路径（个人资料页上传/重置后调用）
 *
 * 与 setDisplayName 同理要广播事件：顶栏 ProfileDropdown 原本只读一次 localStorage，
 * 不广播的话头像要等整页刷新才变。
 */
export function setAvatar(url?: string | null): void {
  store.dispatch(authActions.setAvatar(url ?? ''))
  notifyAuthChanged()
}

/**
 * 头像存储路径 → 可访问地址
 *
 * 后端上传接口返回相对路径（/upload/{日期}/{类型}/{文件名}，静态目录挂后端根）：
 * - 空值 → undefined，组件只渲染首字兜底，不去请求不存在的图
 * - 绝对 URL / 以 / 开头 → 原样返回（开发环境 vite 已代理 /upload 到后端，生产由网关/Nginx 转发）
 * - 其余（不带前导斜杠的脏数据）→ 补一个斜杠
 */
export function resolveAvatarUrl(avatar?: string | null): string | undefined {
  const value = (avatar ?? '').trim()
  if (!value) return undefined
  if (/^https?:\/\//i.test(value) || value.startsWith('/')) return value
  return `/${value}`
}

/** 当前用户角色 code（对应 roles.json 的 code 字段），默认超级管理员 */
export function getRoleCode(): string {
  return store.getState().auth.roleCode
}

export function setRoleCode(code: string): void {
  store.dispatch(authActions.setRoleCode(code))
}

/** 退出登录：尽力通知后端把令牌拉黑并删在线会话（失败不阻断），随后清空本地凭证 */
export function logout(): void {
  const { accessToken, refreshToken } = store.getState().auth
  if (accessToken) {
    void fetch('/backend-api/v1/auth/logout', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${accessToken}` },
      body: JSON.stringify({ refreshToken })
    }).catch(() => undefined)
  }
  // 「记住登录」凭证必须随登出吊销并清除：否则下次进登录页会被静默续登回去，
  // 登出就失去了「换人/换账号」的意义（后端幂等，请求失败也不残留本地副本）
  const rememberToken = getRememberToken()
  if (rememberToken) {
    void fetch('/backend-api/v1/auth/remember/revoke', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token: rememberToken })
    }).catch(() => undefined)
  }
  clearRememberToken()

  // 所有会话级缓存（store、权限对账、字典、开关、过期标记、默认日历、本地偏好、
  // 标签页/租户缓存）统一在这里复位，新登录/新租户不会继承旧会话的残留数据
  resetSessionCaches('logout')
  notifyAuthChanged()
}

/** 保存后端下发的令牌 */
export function setTokens(accessToken?: string, refreshToken?: string): void {
  store.dispatch(authActions.setTokens({ accessToken, refreshToken }))
}

export function getAccessToken(): string {
  return store.getState().auth.accessToken
}

export function getRefreshToken(): string {
  return store.getState().auth.refreshToken
}

/* ---------- 登录后权限数据（来自 GET /backend-api/v1/auth/permissions） ---------- */

/** 保存按钮权限编码汇总（超管为 ['*']） */
export function setPermissions(perms: string[]): void {
  store.dispatch(authActions.setPermissions(perms))
}

export function getPermissions(): string[] {
  return store.getState().auth.permissions
}

/** 保存按角色过滤的菜单树（侧边栏可见范围的数据源） */
export function setMenuTree(menus: unknown): void {
  store.dispatch(authActions.setMenuTree(menus))
}

export function getMenuTree<T>(): T | null {
  return store.getState().auth.menuTree as T | null
}

/** 当前租户 ID；null 表示不指定（超管平台视角） */
export function getTenantId(): number | null {
  return store.getState().auth.tenantId
}

/** 切换租户后写入（0 / null 表示回到平台视角，仅超管有效） */
export function setTenantId(tenantId: number | null): void {
  const next = tenantId !== null && tenantId > 0 ? tenantId : null
  if (store.getState().auth.tenantId !== next) {
    // 租户视角变化：按租户缓存的权限/字典/开关/日历全部作废
    resetSessionCaches('tenant')
  }
  store.dispatch(authActions.setTenantId(next))
}

/** 按钮级权限判断：超管（'*'）或精确命中编码 */
export function hasPermission(perm: string): boolean {
  const perms = getPermissions()
  return perms.includes('*') || perms.includes(perm)
}

/* ---------- 强制改密标记（密码过期 / 管理员标记下次登录必须改密） ---------- */

export function setMustChangePassword(flag: boolean): void {
  store.dispatch(authActions.setMustChangePassword(flag))
}

export function needsPasswordChange(): boolean {
  return store.getState().auth.mustChangePassword
}

/** 强制改密成功后调用（也挂在登出时清掉） */
export function clearMustChangePassword(): void {
  store.dispatch(authActions.setMustChangePassword(false))
}
