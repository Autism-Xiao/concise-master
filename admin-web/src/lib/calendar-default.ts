/**
 * 默认日历 ID 缓存（模块级，避免重复 ensure）
 *
 * 单独成文件是为了让会话复位能清掉它：这个 id 属于「账号 + 租户」，
 * 换号或切租户后若沿用旧值，新账号的日程会被写进别人的默认日历。
 */
let defaultCalendarId: number | null = null

export function getDefaultCalendarId(): number | null {
  return defaultCalendarId
}

export function setDefaultCalendarId(id: number): void {
  defaultCalendarId = id
}

export function resetDefaultCalendarId(): void {
  defaultCalendarId = null
}
