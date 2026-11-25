import { formatDateTime } from './date.util'

describe('date.util', () => {
  describe('formatDateTime', () => {
    it('输出 YYYY-MM-DD HH:mm:ss 并补零', () => {
      expect(formatDateTime(new Date(2026, 10, 4, 9, 5, 3))).toBe('2026-11-04 09:05:03')
    })

    it('空值返回空串，非法日期原样返回', () => {
      expect(formatDateTime(null)).toBe('')
      expect(formatDateTime(undefined)).toBe('')
      expect(formatDateTime('')).toBe('')
      expect(formatDateTime('not-a-date')).toBe('not-a-date')
    })
  })
})
