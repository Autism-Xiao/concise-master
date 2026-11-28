import { createFileRoute } from '@tanstack/react-router'
import { GrantPage } from '@/features/system/grant'
import type { GrantSubjectType } from '@/features/system/grant/api'

const SUBJECT_TYPES: GrantSubjectType[] = ['user', 'dept', 'position', 'role']

/**
 * 授权管理：支持从其他页面带 ?subjectType=user&subjectId=xxx 进入，
 * 自动按该主体过滤列表并预填「新增授权」表单（用于用户管理页 jump 配置个人菜单）。
 */
export const Route = createFileRoute('/_authenticated/system/grant')({
  validateSearch: (search: Record<string, unknown>): { subjectType?: GrantSubjectType; subjectId?: string } => ({
    subjectType: SUBJECT_TYPES.includes(search.subjectType as GrantSubjectType) ? (search.subjectType as GrantSubjectType) : undefined,
    subjectId: typeof search.subjectId === 'string' && search.subjectId ? search.subjectId : undefined
  }),
  component: GrantRoute
})

function GrantRoute() {
  const search = Route.useSearch()
  return <GrantPage prefillSubject={search.subjectType && search.subjectId ? { type: search.subjectType, id: search.subjectId } : undefined} />
}
