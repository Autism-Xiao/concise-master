import { useCallback, useEffect, useMemo, useState } from 'react'
import { useNavigate } from '@tanstack/react-router'
import { Pencil, Plus, Trash2, X } from 'lucide-react'
import { toast } from 'sonner'
import type { ColumnDef } from '@tanstack/react-table'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Skeleton } from '@/components/ui/skeleton'
import { RefreshButton } from '@/components/ui/refresh-button'
import { StatusBadge } from '@/components/status-badge'
import { ConfirmDialog } from '@/components/confirm-dialog'
import { DataTable, DataTableColumnHeader, DataTablePagination, DataTableViewOptions, useDataTable } from '@/components/data-table'
import { hasPermission } from '@/lib/auth'
import { toastError } from '@/lib/toast-error'
import { withOperationLog } from '@/features/system/log/api'
import { fetchDepts } from '@/features/system/dept/api'
import { fetchPosts } from '@/features/system/post/api'
import { fetchRoleOptions } from '@/features/system/role/api'
import { fetchMenus } from '@/features/system/menu/api'
import { fetchDataRules } from '@/features/system/data-rule/api'
import { lookupUsers } from '@/features/users/api'
import {
  createGrant,
  deleteGrant,
  fetchGrants,
  SUBJECT_TYPE_LABELS,
  updateGrant,
  type Grant,
  type GrantSubjectType,
  type GrantWritePayload
} from './api'
import { GrantFormDialog } from './components/grant-form-dialog'

const columnLabels: Record<string, string> = {
  subjectType: '主体类型',
  subjectName: '授权主体',
  permissionName: '权限点',
  ruleName: '数据规则',
  expireAt: '过期时间',
  status: '状态',
  reason: '理由',
  createTime: '创建时间'
}

type NameMap = Record<string, string>

export interface GrantPageProps {
  /** 从其他页跳转过来时预填的主体（如用户管理 → 配置个人菜单） */
  prefillSubject?: { type: GrantSubjectType; id: string }
}

export function GrantPage({ prefillSubject }: GrantPageProps) {
  const navigate = useNavigate()
  const [list, setList] = useState<Grant[] | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [booted, setBooted] = useState(false)
  const [subjectFilter, setSubjectFilter] = useState('all')
  const [formOpen, setFormOpen] = useState(false)
  const [editing, setEditing] = useState<Grant | null>(null)
  const [deleting, setDeleting] = useState<Grant | null>(null)
  const [names, setNames] = useState<Record<GrantSubjectType, NameMap>>({ user: {}, dept: {}, position: {}, role: {} })
  const [permissionNames, setPermissionNames] = useState<NameMap>({})
  const [ruleNames, setRuleNames] = useState<NameMap>({})

  const load = useCallback(() => {
    setLoading(true)
    setError(null)
    fetchGrants()
      .then(setList)
      .catch(e => setError(e instanceof Error ? e.message : '加载失败'))
      .finally(() => {
        setLoading(false)
        setBooted(true)
      })
  }, [])

  useEffect(load, [load])

  /** 主体/权限点/规则 ID → 名称：一次拉全，供表格翻译展示 */
  useEffect(() => {
    const loadNames = async () => {
      const [users, depts, posts, roles, menus, rules] = await Promise.all([
        lookupUsers([]).catch(() => []),
        fetchDepts().catch(() => []),
        fetchPosts().catch(() => []),
        fetchRoleOptions().catch(() => []),
        fetchMenus().catch(() => []),
        fetchDataRules().catch(() => [])
      ])
      setNames({
        user: Object.fromEntries(users.map(user => [user.id, user.realname || user.username])),
        dept: Object.fromEntries(depts.map(dept => [dept.id, dept.departName])),
        position: Object.fromEntries(posts.map(post => [post.id, post.postName || post.postCode])),
        role: Object.fromEntries(roles.map(role => [role.id, role.roleName || role.roleCode]))
      })
      setPermissionNames(Object.fromEntries(menus.map(menu => [menu.id, menu.name])))
      setRuleNames(Object.fromEntries(rules.map(rule => [rule.id, rule.name])))
    }
    void loadNames()
  }, [])

  /** 带主体跳转时：列表只显示该主体的授权，主体类型下拉也切到对应值 */
  const prefillType = prefillSubject?.type
  const prefillId = prefillSubject?.id
  useEffect(() => {
    if (prefillType) setSubjectFilter(prefillType)
  }, [prefillType, prefillId])

  const grants = useMemo(() => {
    const all = list ?? []
    if (!prefillType || !prefillId) return all
    return all.filter(grant => grant.subjectType === prefillType && grant.subjectId === prefillId)
  }, [list, prefillType, prefillId])

  const openCreate = () => {
    setEditing(null)
    setFormOpen(true)
  }

  const openEdit = (grant: Grant) => {
    setEditing(grant)
    setFormOpen(true)
  }

  const resolveSubjectName = useCallback((grant: Grant) => names[grant.subjectType]?.[grant.subjectId] ?? grant.subjectId, [names])

  const columns = useMemo<ColumnDef<Grant>[]>(
    () => [
      {
        accessorKey: 'subjectType',
        header: ({ column }) => <DataTableColumnHeader column={column} title="主体类型" />,
        cell: ({ row }) => SUBJECT_TYPE_LABELS[row.getValue<GrantSubjectType>('subjectType')] ?? row.getValue('subjectType'),
        filterFn: (row, id, value) => row.getValue(id) === value
      },
      {
        id: 'subjectName',
        accessorFn: row => resolveSubjectName(row),
        header: ({ column }) => <DataTableColumnHeader column={column} title="授权主体" />,
        cell: ({ row }) => <span className="font-medium">{row.getValue('subjectName') || '-'}</span>
      },
      {
        id: 'permissionName',
        accessorFn: row => permissionNames[row.permissionId] ?? row.permissionId,
        header: ({ column }) => <DataTableColumnHeader column={column} title="权限点" />,
        cell: ({ row }) => <code className="bg-muted rounded px-1.5 py-0.5 text-xs">{String(row.getValue('permissionName'))}</code>
      },
      {
        id: 'ruleName',
        accessorFn: row => (row.ruleId ? ruleNames[row.ruleId] ?? row.ruleId : ''),
        header: ({ column }) => <DataTableColumnHeader column={column} title="数据规则" />,
        cell: ({ row }) => <span className="text-muted-foreground">{String(row.getValue('ruleName')) || '-'}</span>
      },
      {
        accessorKey: 'expireAt',
        header: ({ column }) => <DataTableColumnHeader column={column} title="过期时间" />,
        cell: ({ row }) => {
          const value = row.getValue<string>('expireAt')
          if (!value) return <span className="text-muted-foreground">长期</span>
          const expired = new Date(value).getTime() < Date.now()
          return <span className={expired ? 'text-destructive text-xs' : 'text-xs'}>{value.replace('T', ' ').slice(0, 16)}{expired ? '（已过期）' : ''}</span>
        }
      },
      {
        accessorKey: 'status',
        header: ({ column }) => <DataTableColumnHeader column={column} title="状态" />,
        cell: ({ row }) => {
          const status = row.getValue<number>('status')
          return <StatusBadge ok={status === 1} label={status === 1 ? '正常' : '停用'} />
        }
      },
      {
        accessorKey: 'reason',
        header: '授权理由',
        enableSorting: false,
        cell: ({ row }) => <span className="text-muted-foreground">{row.getValue('reason') || '-'}</span>
      },
      {
        accessorKey: 'createTime',
        header: ({ column }) => <DataTableColumnHeader column={column} title="创建时间" />,
        cell: ({ row }) => <span className="text-muted-foreground text-xs">{String(row.getValue('createTime') ?? '').replace('T', ' ').slice(0, 16)}</span>
      },
      {
        id: 'actions',
        header: () => <div className="text-end">操作</div>,
        enableSorting: false,
        enableHiding: false,
        cell: ({ row }) => (
          <div className="text-end">
            {hasPermission('system:grant:write') && (
              <Button variant="ghost" size="icon" onClick={() => openEdit(row.original)}>
                <Pencil className="size-4" />
                <span className="sr-only">编辑</span>
              </Button>
            )}
            {hasPermission('system:grant:write') && (
              <Button variant="ghost" size="icon" onClick={() => setDeleting(row.original)}>
                <Trash2 className="text-destructive size-4" />
                <span className="sr-only">删除</span>
              </Button>
            )}
          </div>
        )
      }
    ],
    [resolveSubjectName, permissionNames, ruleNames]
  )

  const columnFilters = useMemo(() => (subjectFilter === 'all' ? [] : [{ id: 'subjectType', value: subjectFilter }]), [subjectFilter])
  const { table, keyword, setKeyword } = useDataTable({ data: grants, columns, columnFilters, getRowId: grant => grant.id })

  const handleSubmit = (values: GrantWritePayload) => {
    const request = editing
      ? withOperationLog('更新授权', () =>
          updateGrant(editing.id, { ruleId: values.ruleId, expireAt: values.expireAt, reason: values.reason })
        )
      : withOperationLog('新增授权', () => createGrant(values))
    request
      .then(() => {
        toast.success(editing ? '授权已更新' : '授权已创建')
        setFormOpen(false)
        load()
      })
      .catch(e => toastError(e, '保存失败'))
  }

  const handleDelete = () => {
    if (!deleting) return
    withOperationLog('删除授权', () => deleteGrant(deleting.id))
      .then(() => {
        toast.success('授权已删除')
        load()
      })
      .catch(e => toastError(e, '删除失败'))
    setDeleting(null)
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">授权管理</h1>
          <p className="text-muted-foreground text-sm">
            共 {grants.length} 条例外授权 · 最终权限 = 角色权限 ∪ 个人授权，个人授权只增不减
          </p>
          {prefillSubject && (
            <div className="bg-info/10 text-info mt-2 flex items-center gap-2 rounded-md px-2.5 py-1.5 text-xs">
              <span>
                已按主体过滤：{SUBJECT_TYPE_LABELS[prefillSubject.type]} · {names[prefillSubject.type]?.[prefillSubject.id] ?? prefillSubject.id}（新增授权会自动预填该主体）
              </span>
              <button type="button" className="ms-auto inline-flex items-center gap-0.5 hover:underline" onClick={() => void navigate({ to: '/system/grant', search: {} })}>
                <X className="size-3" />
                清除过滤
              </button>
            </div>
          )}
        </div>
        <div className="flex flex-wrap gap-2">
          {hasPermission('system:grant:write') && (
            <Button onClick={openCreate}>
              <Plus />
              新增授权
            </Button>
          )}
        </div>
      </div>

      {!booted ? (
        <Card>
          <CardContent className="space-y-3 py-6">
            <Skeleton className="h-9 w-full max-w-md" />
            <Skeleton className="h-64 w-full" />
          </CardContent>
        </Card>
      ) : error ? (
        <Card>
          <CardContent className="flex flex-col items-center gap-3 py-12">
            <p className="text-muted-foreground text-sm">{error}</p>
            <Button variant="outline" onClick={load}>
              重试
            </Button>
          </CardContent>
        </Card>
      ) : (
        <Card>
          <CardContent className="space-y-4">
            <div className="flex flex-wrap items-center gap-2">
              <div className="relative w-full max-w-xs">
                <Input placeholder="搜索主体 / 权限点 / 理由" value={keyword} onChange={e => setKeyword(e.target.value)} />
              </div>
              <Select value={subjectFilter} onValueChange={setSubjectFilter} items={{ all: '全部主体', ...SUBJECT_TYPE_LABELS }}>
                <SelectTrigger className="h-9 w-32">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">全部主体</SelectItem>
                  {Object.entries(SUBJECT_TYPE_LABELS).map(([value, label]) => (
                    <SelectItem key={value} value={value}>
                      {label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <RefreshButton onClick={() => void load()} disabled={loading} spinning={loading} className="ms-auto" />
              <DataTableViewOptions table={table} columnLabels={columnLabels} />
            </div>

            <DataTable table={table} loading={loading} emptyText="没有匹配的授权" />
            <DataTablePagination table={table} />
          </CardContent>
        </Card>
      )}

      {formOpen && (
        <GrantFormDialog
          key={editing?.id ?? 'new'}
          open={formOpen}
          onOpenChange={setFormOpen}
          grant={editing}
          prefill={editing ? undefined : prefillSubject}
          onSubmit={handleSubmit}
        />
      )}

      <ConfirmDialog
        open={!!deleting}
        onOpenChange={value => !value && setDeleting(null)}
        description={<>即将删除该授权行（软删，保留审计），授权生效后对应用户将失去该权限。</>}
        onConfirm={handleDelete}
      />
    </div>
  )
}
