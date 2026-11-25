import { toast } from 'sonner'
import { userMessageOf } from '@/lib/api-error'

/**
 * 错误提示统一出口
 *
 * 过去 126 处写成 `err instanceof Error ? err.message : '操作失败'`：
 * ApiError 的中文文案被绕过，原生英文错误（Failed to fetch / TypeError）直接糊到界面上。
 * 这里强制参数是 unknown，并交给 userMessageOf 做中文兜底；新增调用只走这个函数。
 */
export function toastError(error: unknown, fallback = '操作失败，请稍后再试'): void {
  toast.error(userMessageOf(error, fallback))
}
