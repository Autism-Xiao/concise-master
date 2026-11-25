import { reportRecovered } from '@/lib/api-error'
import { resetDefaultCalendarId } from '@/lib/calendar-default'
import { clearDictCache } from '@/lib/dict'
import { notifyFeaturesReset } from '@/lib/features'
import { setLocked } from '@/lib/lock-screen'
import { resetPermissionCache } from '@/lib/permissions'
import { clearLocalSettings } from '@/lib/settings'
import { nextSessionEpoch } from '@/lib/session-epoch'
import { resetSessionExpiredFlag } from '@/lib/session-expired'
import { TABS_STORAGE_KEY, TENANT_INFO_STORAGE_KEY } from '@/lib/storage-keys'
import { store } from '@/stores'
import { authActions } from '@/stores/auth-slice'

export type SessionResetReason = 'logout' | 'account' | 'tenant'

/**
 * 会话级缓存统一复位
 *
 * 历史问题：登出只清了令牌/偏好，权限对账标记、字典缓存、会话过期标记、
 * 默认日历 id 等散落在各模块的变量会跨账号存活；换号走 SSO/静默续登时
 * 甚至完全不经过登出，于是出现「旧账号菜单/开关/设置串到新账号」。
 *
 * 这里收敛所有会话范围的状态，并用 nextSessionEpoch() 让旧请求的结果自动失效。
 * 不直接 import lib/auth.ts，避免与认证门面形成循环依赖。
 */
export function resetSessionCaches(reason: SessionResetReason): void {
  // 代次最先推进：后续所有缓存清理/重置都基于新代次，旧请求 result 不再写入
  nextSessionEpoch()
  resetPermissionCache()
  clearDictCache()
  notifyFeaturesReset()
  reportRecovered()
  resetDefaultCalendarId()

  if (reason === 'tenant') {
    // 界面偏好、标签页、锁屏属于账号而非租户，切视角时保留
    return
  }

  resetSessionExpiredFlag()
  setLocked(false)
  clearLocalSettings()
  localStorage.removeItem(TABS_STORAGE_KEY)
  localStorage.removeItem(TENANT_INFO_STORAGE_KEY)
  // 调用方会先复位再写入新账号/新令牌（登录流程已按此顺序），所以这里可以整体清掉
  store.dispatch(authActions.resetAuth())
}
