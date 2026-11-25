/** 格式化为本地时间字符串 YYYY-MM-DD HH:mm:ss（东八区） */
export function formatDateTime(value: Date | string | number | null | undefined): string {
  if (value === null || value === undefined || value === '') {
    return ''
  }
  const date = value instanceof Date ? value : new Date(value)
  if (Number.isNaN(date.getTime())) {
    return String(value)
  }
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
}
