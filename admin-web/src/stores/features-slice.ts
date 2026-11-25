import { createSlice, type PayloadAction } from '@reduxjs/toolkit'

/**
 * 特性开关缓存（原 lib/features.ts 的模块级 cache）
 *
 * flags = null 表示当前视角还没拉取过；{} 表示已拉取但没有开任何开关。
 * 两者必须区分：null 会让 useFeature 触发一次拉取，{} 直接用空结果（fail-safe 关闭入口）。
 */

export const FEATURES_STORAGE_KEY = 'concise-features'

export interface FeaturesState {
  flags: Record<string, boolean> | null
}

const initialFeaturesState: FeaturesState = { flags: null }

const featuresSlice = createSlice({
  name: 'features',
  initialState: initialFeaturesState,
  reducers: {
    setFlags(state, action: PayloadAction<Record<string, boolean>>) {
      state.flags = action.payload
    },
    /** 租户切换/登录登出时调用：开关是租户视角数据，必须随视角失效 */
    resetFlags() {
      return initialFeaturesState
    }
  }
})

export const featuresActions = featuresSlice.actions
export default featuresSlice.reducer
