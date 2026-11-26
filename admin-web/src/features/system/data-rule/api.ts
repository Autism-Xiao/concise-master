import { getApiResult } from '@/lib/http'

/** 后端 sys_data_rule 实体 */
export interface DataRule {
  id: string
  tenantId: number
  name: string
  /** 资源标识：biz_order / customer / supplier */
  resource: string
  /** all / read / write / delete */
  action: string
  /** 实体属性名（白名单） */
  ruleField: string
  /** eq/ne/gt/gte/lt/lte/in/not_in/like/self/dept */
  ruleOperator: string
  ruleValue?: string | null
  /** allow / deny */
  ruleEffect: string
  priority: number
  /** 1 正常 / 0 停用 */
  status: number
  createBy?: string | null
  createTime?: string
  updateBy?: string | null
  updateTime?: string
}

export interface DataRuleWritePayload {
  name: string
  resource: string
  action?: string
  ruleField: string
  ruleOperator: string
  ruleValue?: string | null
  ruleEffect?: string
  priority?: number
}

export interface DataRuleUpdatePayload extends Partial<DataRuleWritePayload> {
  status?: number
}

/** 数据规则列表（后端返回数组，非分页） */
export function fetchDataRules(resource?: string): Promise<DataRule[]> {
  const qs = new URLSearchParams()
  if (resource) qs.set('resource', resource)
  const query = qs.toString()
  return getApiResult<DataRule[]>(`/backend-api/v1/data-rules${query ? `?${query}` : ''}`)
}

export function createDataRule(payload: DataRuleWritePayload): Promise<DataRule> {
  return getApiResult<DataRule>('/backend-api/v1/data-rules', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  })
}

export function updateDataRule(id: string, payload: DataRuleUpdatePayload): Promise<DataRule> {
  return getApiResult<DataRule>(`/backend-api/v1/data-rules/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  })
}

/** 删除数据规则（被授权引用时后端会拒绝） */
export function deleteDataRule(id: string): Promise<void> {
  return getApiResult<null>(`/backend-api/v1/data-rules/${id}`, { method: 'DELETE' }).then(() => undefined)
}
