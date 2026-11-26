import { getApiResult, type PageResult } from '@/lib/http'

/** 订单（生成器产物） */
export interface BizOrder {
  id: number
  title?: string | null
  status?: number | null
  amount?: number | null
  signedAt?: string | null
  remark?: string | null
  createBy?: string | null
  updateBy?: string | null
  /** 后端响应层把 createBy/updateBy 的 ID 翻译成的展示名（姓名优先，回退账号）；查不到对应用户时无此字段 */
  createByName?: string
  updateByName?: string
  createdAt: string
  updatedAt: string
  /** 后端按字段权限移除的敏感字段名（如 amount），前端只展示掩码，不回填表单 */
  maskedFields?: string[]
}

export type BizOrderWritePayload = Partial<Omit<BizOrder, 'id' | 'createBy' | 'updateBy' | 'createByName' | 'updateByName' | 'createdAt' | 'updatedAt' | 'maskedFields'>>

export function fetchBizOrders(params: { page?: number; pageSize?: number; keyword?: string; sortBy?: string; sortOrder?: 'asc' | 'desc' } = {}) {
  const qs = new URLSearchParams()
  Object.entries(params).forEach(([key, value]) => {
    if (value !== undefined && value !== '') qs.set(key, String(value))
  })
  return getApiResult<PageResult<BizOrder>>(`/backend-api/v1/biz_orders?${qs.toString()}`)
}

export function createBizOrder(payload: BizOrderWritePayload) {
  return getApiResult<BizOrder>('/backend-api/v1/biz_orders', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  })
}

export function updateBizOrder(id: number, payload: BizOrderWritePayload) {
  return getApiResult<BizOrder>(`/backend-api/v1/biz_orders/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  })
}

export function deleteBizOrder(id: number) {
  return getApiResult<unknown>(`/backend-api/v1/biz_orders/${id}`, { method: 'DELETE' })
}
