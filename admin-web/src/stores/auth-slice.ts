import { createSlice, type PayloadAction } from '@reduxjs/toolkit'

/**
 * 认证态数据缓存（原 lib/auth.ts 里散落的 localStorage key 收敛到这里）
 *
 * 所有字段的持久化 key 与迁移前保持一致，老用户刷新后能无缝读到已登录状态。
 * 这里只描述"数据长什么样、怎么改"，持久化由 stores/index.ts 的订阅统一负责。
 */

export const AUTH_STORAGE_KEYS = {
  authenticated: 'concise-auth',
  username: 'concise-user',
  displayName: 'concise-name',
  avatar: 'concise-avatar',
  roleCode: 'concise-role',
  accessToken: 'concise-token',
  refreshToken: 'concise-refresh-token',
  permissions: 'concise-perms',
  menuTree: 'concise-menus',
  tenantId: 'concise-tenant',
  /** 强制改密标记：会话级，关标签页即失效 */
  mustChangePassword: 'concise-must-change-pwd'
} as const

export interface AuthState {
  authenticated: boolean
  username: string
  displayName: string
  avatar: string
  roleCode: string
  accessToken: string
  refreshToken: string
  permissions: string[]
  /** 后端按角色过滤的菜单树；unknown 是因为它由后端下发、前端只透传 */
  menuTree: unknown
  /** null = 平台视角（不指定租户） */
  tenantId: number | null
  mustChangePassword: boolean
}

export const initialAuthState: AuthState = {
  authenticated: false,
  username: 'admin',
  displayName: '',
  avatar: '',
  roleCode: 'superadmin',
  accessToken: '',
  refreshToken: '',
  permissions: [],
  menuTree: null,
  tenantId: null,
  mustChangePassword: false
}

const authSlice = createSlice({
  name: 'auth',
  initialState: initialAuthState,
  reducers: {
    setAuthenticated(state, action: PayloadAction<boolean>) {
      state.authenticated = action.payload
    },
    /** 登录：一次性写入三项身份信息（对应原 login() 的语义） */
    setAccount(state, action: PayloadAction<{ username: string; name: string; role: string }>) {
      state.authenticated = true
      state.username = action.payload.username
      state.displayName = action.payload.name
      state.roleCode = action.payload.role
    },
    setDisplayName(state, action: PayloadAction<string>) {
      state.displayName = action.payload
    },
    setAvatar(state, action: PayloadAction<string>) {
      state.avatar = action.payload
    },
    setRoleCode(state, action: PayloadAction<string>) {
      state.roleCode = action.payload
    },
    /** 令牌续签/登录下发：只覆盖传入的项，不传的保留（对应原 setTokens） */
    setTokens(state, action: PayloadAction<{ accessToken?: string; refreshToken?: string }>) {
      if (action.payload.accessToken) state.accessToken = action.payload.accessToken
      if (action.payload.refreshToken) state.refreshToken = action.payload.refreshToken
    },
    setPermissions(state, action: PayloadAction<string[]>) {
      state.permissions = action.payload
    },
    setMenuTree(state, action: PayloadAction<unknown>) {
      state.menuTree = action.payload
    },
    setTenantId(state, action: PayloadAction<number | null>) {
      state.tenantId = action.payload !== null && action.payload > 0 ? action.payload : null
    },
    setMustChangePassword(state, action: PayloadAction<boolean>) {
      state.mustChangePassword = action.payload
    },
    /** 登出：一次性复位到初始值（订阅会把所有 key 从存储里清掉） */
    resetAuth() {
      return initialAuthState
    }
  }
})

export const authActions = authSlice.actions
export default authSlice.reducer
