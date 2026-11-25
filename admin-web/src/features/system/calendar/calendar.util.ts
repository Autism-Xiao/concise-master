// 日历纯函数：提醒状态与文案、日期 key、月视图格子生成（与 React 无关）
import type { CalendarEvent } from './api'

/** 日程的提醒状态：没有提醒 / 待触发 / 已触发过 */
export type RemindState = 'none' | 'pending' | 'fired'

export function remindStateOf(ev: CalendarEvent): RemindState {
  if (!ev.remindAt) return 'none'
  // 后端存的是 tinyint，可能是 0/1 也可能是布尔值，按真值判断即可
  return ev.isReminded ? 'fired' : 'pending'
}

/** ISO → '11-10 08:45'（按用户本地时区展示） */
export function formatRemindAt(iso?: string | null): string {
  if (!iso) return ''
  const d = new Date(iso)
  if (Number.isNaN(d.getTime())) return ''
  const pad = (n: number) => `${n}`.padStart(2, '0')
  return `${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}

/** 距离提醒触发还剩多久（「待提醒」面板的倒计时文案） */
export function formatCountdown(iso?: string | null): { text: string; urgent: boolean; overdue: boolean } {
  if (!iso) return { text: '', urgent: false, overdue: false }
  const target = new Date(iso).getTime()
  if (Number.isNaN(target)) return { text: '', urgent: false, overdue: false }
  const diff = target - Date.now()
  // 已过提醒点但还没被巡逻补发：调度器每 3 分钟兜底一次，这里如实显示
  if (diff <= 0) return { text: '已到点，等待推送', urgent: true, overdue: true }
  const minutes = Math.ceil(diff / 60000)
  if (minutes < 60) return { text: `还剩 ${minutes} 分钟`, urgent: true, overdue: false }
  const hours = Math.floor(minutes / 60)
  if (hours < 24) {
    const rest = minutes % 60
    return { text: rest ? `还剩 ${hours} 小时 ${rest} 分` : `还剩 ${hours} 小时`, urgent: false, overdue: false }
  }
  return { text: `还剩 ${Math.floor(hours / 24)} 天`, urgent: false, overdue: false }
}

export interface DayCell {
  /** YYYY-MM-DD */
  key: string
  day: number
  inMonth: boolean
  isToday: boolean
}

export function toKey(d: Date): string {
  return `${d.getFullYear()}-${`${d.getMonth() + 1}`.padStart(2, '0')}-${`${d.getDate()}`.padStart(2, '0')}`
}

/** 生成 42 格（6 周）月视图，周一开头 */
export function buildMonth(year: number, month: number): DayCell[] {
  const today = toKey(new Date())
  const first = new Date(year, month, 1)
  // getDay: 0=周日 → 转为周一开头的偏移
  const offset = (first.getDay() + 6) % 7
  const start = new Date(year, month, 1 - offset)
  return Array.from({ length: 42 }, (_, i) => {
    const d = new Date(start.getFullYear(), start.getMonth(), start.getDate() + i)
    return { key: toKey(d), day: d.getDate(), inMonth: d.getMonth() === month, isToday: toKey(d) === today }
  })
}
