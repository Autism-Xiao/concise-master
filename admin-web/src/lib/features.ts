import { useEffect } from 'react'

import { getApiResult } from '@/lib/http'
import { getSessionEpoch, nextSessionEpoch } from '@/lib/session-epoch'
import { store, useAppSelector } from '@/stores'
import { featuresActions } from '@/stores/features-slice'

/**
 * 特性开关前端消费层（对应后端 GET /v1/features）
 *
 * 后端按「平台行 ∪ 租户覆盖行」返回当前视角的全部生效开关（键不带 feature. 前缀），
 * 前端用它做界面能力的显隐：开关关闭的入口直接不渲染，点了也只会 403 的按钮没有存在意义。
 *
 * 缓存策略：Redux store 为唯一内存源 + sessionStorage 持久化快照。特性开关变更是低频管理动作，
 * 拉取失败时回退快照或空对象（空 = 开关默认关 → 入口隐藏，fail-safe 方向正确）；
 * 租户切换后由 notifyFeaturesReset 清缓存（下一个 hook 挂载时重新拉取）。
 */

const FALLBACK: Record<string, boolean> = {}

/** 开关缓存有效期：过期后下次 useFeature 挂载会后台重拉（低频管理动作，60s 足够新鲜） */
const REFRESH_TTL = 60_000

/** 并发请求去重：不是缓存数据，只是避免同一时刻多个 hook 各发一次请求 */
let inflight: Promise<Record<string, boolean>> | null = null

/** 上次拉取（含失败回退）时间：0 表示从未拉取过（水合快照不算拉取），必然触发一次网络校验 */
let lastFetchAt = 0

/** 拉取当前租户视角的全部开关；并发调用共享同一请求，60s 内的缓存直接复用 */
export function fetchFeatures(): Promise<Record<string, boolean>> {
  const cache = store.getState().features.flags
  if (cache && Date.now() - lastFetchAt < REFRESH_TTL) return Promise.resolve(cache)
  if (!inflight) {
    const epoch = getSessionEpoch()
    const task = getApiResult<Record<string, boolean>>('/backend-api/v1/features')
      .then(flags => {
        lastFetchAt = Date.now()
        // 拉取期间切换租户/账号：旧视角的开关不能写进新会话
        if (epoch !== getSessionEpoch()) return store.getState().features.flags ?? FALLBACK
        const next = flags && typeof flags === 'object' && !Array.isArray(flags) ? flags : { ...FALLBACK }
        store.dispatch(featuresActions.setFlags(next))
        return next
      })
      .catch(() => {
        // 拉取失败回退快照：store 水合时已读入 sessionStorage；连快照都没有就用空对象。
        // 同样记录时间戳：避免后端宕机时每个组件挂载都重试一次注定失败的请求，
        // 60s 后下一个 useFeature 挂载会自动重试恢复
        lastFetchAt = Date.now()
        if (epoch !== getSessionEpoch()) return store.getState().features.flags ?? FALLBACK
        const fallback = store.getState().features.flags ?? FALLBACK
        store.dispatch(featuresActions.setFlags(fallback))
        return fallback
      })
    inflight = task
    void task.finally(() => {
      if (inflight === task) inflight = null
    })
  }
  return inflight
}

/** 租户切换 / 登录登出时调用：开关是租户视角的数据，必须随视角失效 */
export function notifyFeaturesReset(): void {
  // 同时推进代次：在途的 fetchFeatures 结果会被丢弃
  nextSessionEpoch()
  lastFetchAt = 0
  store.dispatch(featuresActions.resetFlags())
}

/**
 * 订阅单个开关：enabled 缺省为 false（后端没返回 = 没开）。
 * 组件里 `const enabled = useFeature('rbac.superviseDept')` 即可用。
 *
 * 每次挂载都走 fetchFeatures()：内部有 60s TTL + 并发去重，实际最多一个请求；
 * 这样后端刚补的开关（或宕机恢复后）最多延迟 60s 自动出现，不用手动退出重登。
 */
export function useFeature(name: string): boolean {
  const flags = useAppSelector(state => state.features.flags)
  useEffect(() => {
    void fetchFeatures()
  }, [name, flags])
  return flags?.[name] ?? false
}
