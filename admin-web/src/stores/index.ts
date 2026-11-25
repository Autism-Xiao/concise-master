import { configureStore } from '@reduxjs/toolkit'
import { useDispatch, useSelector } from 'react-redux'

import authReducer, {
  AUTH_STORAGE_KEYS,
  initialAuthState,
  type AuthState
} from './auth-slice'
import featuresReducer, { FEATURES_STORAGE_KEY, type FeaturesState } from './features-slice'

/**
 * 全局数据缓存 store（模块级单例）
 *
 * 设计要点：
 * 1. store 是唯一内存数据源。lib/auth.ts、lib/features.ts 这些同步门面内部只读 store，
 *    所以路由守卫、http 层、各 api 在非 React 环境也能同步拿到最新值。
 * 2. localStorage / sessionStorage 退化为持久化底层，由订阅在 dispatch 后同步落盘，
 *    写操作返回时存储空间已经是最新值——外部直接读 localStorage 的旧代码也不会读到过期数据。
 * 3. 水合在模块加载时完成，首帧组件读到的就是已登录状态，不需要等 useEffect。
 */

/** 存储不可用时（隐私模式、沙箱测试）静默降级为内存态 */
function storageOf(kind: 'local' | 'session'): Storage | undefined {
  try {
    return kind === 'local' ? localStorage : sessionStorage
  } catch {
    return undefined
  }
}

function read(storage: Storage | undefined, key: string): string | null {
  try {
    return storage?.getItem(key) ?? null
  } catch {
    return null
  }
}

function write(storage: Storage | undefined, key: string, value: string | null): void {
  try {
    if (!storage) return
    if (value === null) storage.removeItem(key)
    else storage.setItem(key, value)
  } catch {
    /* 存储满/隐私模式：只影响下次冷启动的水合，本次会话内存态不受影响 */
  }
}

function parseJson<T>(raw: string | null, fallback: T): T {
  if (!raw) return fallback
  try {
    return JSON.parse(raw) as T
  } catch {
    return fallback
  }
}

/* ---------- 水合：从存储恢复 initial state ---------- */

function hydrateAuth(): AuthState {
  const ls = storageOf('local')
  const ss = storageOf('session')
  const tenantRaw = read(ls, AUTH_STORAGE_KEYS.tenantId)
  const tenantValue = tenantRaw ? Number(tenantRaw) : NaN
  const permissions = parseJson<unknown>(read(ls, AUTH_STORAGE_KEYS.permissions), [])

  return {
    authenticated: read(ls, AUTH_STORAGE_KEYS.authenticated) === 'true',
    username: read(ls, AUTH_STORAGE_KEYS.username) || initialAuthState.username,
    displayName: read(ls, AUTH_STORAGE_KEYS.displayName) || '',
    avatar: read(ls, AUTH_STORAGE_KEYS.avatar) || '',
    roleCode: read(ls, AUTH_STORAGE_KEYS.roleCode) || initialAuthState.roleCode,
    accessToken: read(ls, AUTH_STORAGE_KEYS.accessToken) || '',
    refreshToken: read(ls, AUTH_STORAGE_KEYS.refreshToken) || '',
    permissions: Array.isArray(permissions) ? (permissions as string[]) : [],
    menuTree: parseJson<unknown>(read(ls, AUTH_STORAGE_KEYS.menuTree), null),
    tenantId: Number.isFinite(tenantValue) && tenantValue > 0 ? tenantValue : null,
    mustChangePassword: read(ss, AUTH_STORAGE_KEYS.mustChangePassword) === '1'
  }
}

function hydrateFeatures(): FeaturesState {
  const raw = read(storageOf('session'), FEATURES_STORAGE_KEY)
  if (!raw) return { flags: null }
  const flags = parseJson<unknown>(raw, null)
  return flags && typeof flags === 'object' && !Array.isArray(flags)
    ? { flags: flags as Record<string, boolean> }
    : { flags: null }
}

/* ---------- 持久化：state 变化后同步落盘 ---------- */

function persistAuth(auth: AuthState): void {
  const ls = storageOf('local')
  const ss = storageOf('session')
  const keys = AUTH_STORAGE_KEYS

  write(ls, keys.authenticated, auth.authenticated ? 'true' : null)
  write(ls, keys.username, auth.username || null)
  write(ls, keys.displayName, auth.displayName || null)
  write(ls, keys.avatar, auth.avatar || null)
  write(ls, keys.roleCode, auth.roleCode || null)
  write(ls, keys.accessToken, auth.accessToken || null)
  write(ls, keys.refreshToken, auth.refreshToken || null)
  write(ls, keys.permissions, JSON.stringify(auth.permissions))
  write(ls, keys.menuTree, auth.menuTree === null ? null : JSON.stringify(auth.menuTree))
  write(ls, keys.tenantId, auth.tenantId !== null && auth.tenantId > 0 ? String(auth.tenantId) : null)
  write(ss, keys.mustChangePassword, auth.mustChangePassword ? '1' : null)
}

function persistFeatures(features: FeaturesState): void {
  write(
    storageOf('session'),
    FEATURES_STORAGE_KEY,
    features.flags === null ? null : JSON.stringify(features.flags)
  )
}

/* ---------- store ---------- */

export const store = configureStore({
  reducer: {
    auth: authReducer,
    features: featuresReducer
  },
  preloadedState: {
    auth: hydrateAuth(),
    features: hydrateFeatures()
  }
})

// 引用对比：只有对应 slice 真的变了才落盘（RTK reducer 未改动时返回同一引用）
let lastAuth = store.getState().auth
let lastFeatures = store.getState().features
store.subscribe(() => {
  const state = store.getState()
  if (state.auth !== lastAuth) {
    lastAuth = state.auth
    persistAuth(state.auth)
  }
  if (state.features !== lastFeatures) {
    lastFeatures = state.features
    persistFeatures(state.features)
  }
})

export type RootState = ReturnType<typeof store.getState>
export type AppDispatch = typeof store.dispatch

/** typed hooks：组件里用它们替代裸 useDispatch / useSelector */
export const useAppDispatch = useDispatch.withTypes<AppDispatch>()
export const useAppSelector = useSelector.withTypes<RootState>()
