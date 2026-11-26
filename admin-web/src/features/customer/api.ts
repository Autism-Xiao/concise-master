import { getApiResult, type PageResult } from '@/lib/http'

/** 客户（生成器产物） */
export interface Customer {
  id: number
  name?: string | null
  contact?: string | null
  phone?: string | null
  level?: number | null
  vip?: number | null
  remark?: string | null
  createBy?: string | null
  updateBy?: string | null
  /** 后端响应层把 createBy/updateBy 的 ID 翻译成的展示名（姓名优先，回退账号）；查不到对应用户时无此字段 */
  createByName?: string
  updateByName?: string
  createdAt: string
  updatedAt: string
  /** 后端按字段权限移除的敏感字段名（如 phone），前端只展示掩码，不回填表单 */
  maskedFields?: string[]
}

export type CustomerWritePayload = Partial<Omit<Customer, 'id' | 'createBy' | 'updateBy' | 'createByName' | 'updateByName' | 'createdAt' | 'updatedAt' | 'maskedFields'>>

export function fetchCustomers(params: { page?: number; pageSize?: number; keyword?: string; sortBy?: string; sortOrder?: 'asc' | 'desc' } = {}) {
  const qs = new URLSearchParams()
  Object.entries(params).forEach(([key, value]) => {
    if (value !== undefined && value !== '') qs.set(key, String(value))
  })
  return getApiResult<PageResult<Customer>>(`/backend-api/v1/customers?${qs.toString()}`)
}

export function createCustomer(payload: CustomerWritePayload) {
  return getApiResult<Customer>('/backend-api/v1/customers', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  })
}

export function updateCustomer(id: number, payload: CustomerWritePayload) {
  return getApiResult<Customer>(`/backend-api/v1/customers/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  })
}

export function deleteCustomer(id: number) {
  return getApiResult<unknown>(`/backend-api/v1/customers/${id}`, { method: 'DELETE' })
}
