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
  /** 审计人名字快照：写入时固化当时的名字，改名不影响历史；旧数据可能为空，由后端兜底补全 */
  createByName?: string | null
  updateByName?: string | null
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
