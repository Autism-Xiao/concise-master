/**
 * 标签页 LRU 模型（纯函数，不依赖 React）
 *
 * 原实现按「打开顺序」淘汰最早的非固定标签（FIFO）：一个天天用的页面可能因为
 * 打开得早就先被关掉，而很久没看的页面反而留着。这里改成按最近访问时间淘汰。
 */
export interface LruTab {
  path: string
  pinned?: boolean
  /** 最近访问时间戳；缺省视为 0（历史持久化数据） */
  lastActive?: number
}

/** 访问已有标签：刷新 lastActive，其余字段不变 */
export function touchTab<T extends LruTab>(tabs: T[], path: string, now = Date.now()): T[] {
  if (!tabs.some(tab => tab.path === path)) return tabs
  return tabs.map(tab => (tab.path === path ? { ...tab, lastActive: now } : tab))
}

/** 淘汰一个可关闭的标签：优先最久未访问，固定标签与当前标签受保护 */
export function evictLru<T extends LruTab>(tabs: T[], keepPath?: string, max = 12): T[] {
  if (tabs.length <= max) return tabs
  let next = [...tabs]
  while (next.length > max) {
    let victim = -1
    let oldest = Number.POSITIVE_INFINITY
    next.forEach((tab, index) => {
      if (tab.pinned || tab.path === keepPath) return
      const active = tab.lastActive ?? 0
      if (active < oldest) {
        oldest = active
        victim = index
      }
    })
    // 全是固定/当前标签：放弃淘汰，避免把用户正在看的页面关掉
    if (victim === -1) break
    next.splice(victim, 1)
  }
  return next
}

/** 打开新标签并按需淘汰；已在列表里则视为一次访问 */
export function insertTabLru<T extends LruTab>(tabs: T[], path: string, now = Date.now(), max = 12): T[] {
  if (tabs.some(tab => tab.path === path)) return touchTab(tabs, path, now)
  return evictLru([...tabs, { path, lastActive: now } as T], path, max)
}
