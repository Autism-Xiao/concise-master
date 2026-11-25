import { batchDeleteRequest, type BatchDeleteResult } from '@/lib/batch-delete'
import { downloadFromApi } from '@/lib/download'
import { getApiResult, type PageResult } from '@/lib/http'

/** 后端 sys_depart（部门），只保留页面需要的字段 */
export interface Dept {
  id: string
  /** 上级部门 id，null 为顶级 */
  parentId: string | null
  departName: string
  /** 英文名（非必填） */
  departNameEn?: string | null
  /** 英文简写（非必填） */
  departNameAbbr?: string | null
  /** 同级排序，越小越靠前 */
  departOrder: number
  /** 部门编码（新建自动生成 A01/A01A01，可手改） */
  orgCode?: string | null
  /** 机构类别：1 公司 / 2 部门 / 4 子公司 */
  orgCategory?: string | null
  description?: string | null
  /** '1' 启用 / '0' 停用 */
  status?: string
  createTime?: string
  updateTime?: string
  /** 创建人姓名（后端按 sys_user.id 翻译，历史账号名原样返回） */
  createByName?: string | null
  /** 更新人姓名 */
  updateByName?: string | null
}

export interface DeptWritePayload {
  departName: string
  /** 英文名（非必填） */
  departNameEn?: string | null
  /** 英文简写（非必填） */
  departNameAbbr?: string | null
  /** null 为顶级部门；换父由后端防环，编码随节点原值保留 */
  parentId?: string | null
  /** 部门编码：新建不传自动生成，编辑可改（重复会被 400 拒） */
  orgCode?: string | null
  /** 机构类别：1 公司 / 2 部门 / 4 子公司 */
  orgCategory?: string | null
  departOrder?: number
  description?: string | null
  status?: string
}

/** 部门类型展示 */
export const orgCategoryMap: Record<string, string> = { '1': '公司', '2': '部门', '4': '子公司' }

/** 部门扁平列表（统一分页结构，全量返回；keyword 模糊匹配名称），前端自行组树 */
export async function fetchDepts(keyword = ''): Promise<Dept[]> {
  const qs = keyword ? `?keyword=${encodeURIComponent(keyword)}` : ''
  const page = await getApiResult<PageResult<Dept>>(`/backend-api/v1/depts${qs}`)
  return page.records
}

/** 创建部门（orgCode 由后端自动生成） */
export function createDept(payload: DeptWritePayload): Promise<Dept> {
  return getApiResult<Dept>('/backend-api/v1/depts', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  })
}

export function updateDept(id: string, payload: DeptWritePayload): Promise<Dept> {
  return getApiResult<Dept>(`/backend-api/v1/depts/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  })
}

/** 软删除；有子部门或挂用户时后端会拒绝 */
export function deleteDept(id: string): Promise<void> {
  return getApiResult<null>(`/backend-api/v1/depts/${id}`, { method: 'DELETE' }).then(() => undefined)
}

/** 批量删除部门：走后端统一接口，逐条结算（有子部门/有用户的会返回失败原因） */
export function deleteDepts(ids: string[]): Promise<BatchDeleteResult> {
  return batchDeleteRequest('depts', ids)
}

/** 导出部门 Excel（带完整路径，keyword 与列表一致） */
export function exportDepts(params: { keyword?: string } = {}): Promise<{ filename: string; blob: Blob }> {
  const qs = params.keyword ? `?keyword=${encodeURIComponent(params.keyword)}` : ''
  return downloadFromApi(`/v1/depts/export${qs}`, 'depts.xlsx')
}
