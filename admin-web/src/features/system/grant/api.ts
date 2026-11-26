import { getApiResult } from '@/lib/http'

/** 主体类型：与后端 SUBJECT_TYPES 一致 */
export type GrantSubjectType = 'user' | 'dept' | 'position' | 'role'

export const SUBJECT_TYPE_LABELS: Record<GrantSubjectType, string> = {
  user: '用户',
  dept: '部门',
  position: '岗位',
  role: '角色'
}

/** 后端 sys_grant 实体 */
export interface Grant {
  id: string
  tenantId: number
  subjectType: GrantSubjectType
  subjectId: string
  /** sys_permission.id */
  permissionId: string
  ruleId?: string | null
  /** 'allow' / 'deny'（授权行通常是 allow，deny 只用于规则） */
  ruleEffect?: string
  expireAt?: string | null
  reason?: string | null
  /** 1 正常 / 0 停用 */
  status: number
  grantBy?: string | null
  createTime?: string
  updateTime?: string
}

export interface GrantWritePayload {
  subjectType: GrantSubjectType
  subjectId: string
  permissionId: string
  ruleId?: string | null
  expireAt?: string | null
  reason?: string | null
}

export interface GrantUpdatePayload {
  ruleId?: string | null
  expireAt?: string | null
  reason?: string | null
  status?: number
}

/** 授权列表（后端返回数组，非分页） */
export function fetchGrants(filter: { subjectType?: string; subjectId?: string; permissionId?: string } = {}): Promise<Grant[]> {
  const qs = new URLSearchParams()
  if (filter.subjectType) qs.set('subjectType', filter.subjectType)
  if (filter.subjectId) qs.set('subjectId', filter.subjectId)
  if (filter.permissionId) qs.set('permissionId', filter.permissionId)
  const query = qs.toString()
  return getApiResult<Grant[]>(`/backend-api/v1/grants${query ? `?${query}` : ''}`)
}

export function createGrant(payload: GrantWritePayload): Promise<Grant> {
  return getApiResult<Grant>('/backend-api/v1/grants', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  })
}

export function updateGrant(id: string, payload: GrantUpdatePayload): Promise<Grant> {
  return getApiResult<Grant>(`/backend-api/v1/grants/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  })
}

/** 删除授权（软删，保留审计） */
export function deleteGrant(id: string): Promise<void> {
  return getApiResult<null>(`/backend-api/v1/grants/${id}`, { method: 'DELETE' }).then(() => undefined)
}
