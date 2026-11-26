import { useCallback, useEffect, useMemo, useState } from 'react'
import { Pencil, Plus, Trash2 } from 'lucide-react'
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
import { createDataRule, deleteDataRule, fetchDataRules, updateDataRule, type DataRule, type DataRuleWritePayload } from './api'
import { DataRuleFormDialog } from './components/data-rule-form-dialog'

const columnLabels: Record<string, string> = {
  name: '规则名称',
  resource: '资源',
  action: '动作',
  ruleField: '过滤字段',
  ruleOperator: '运算符',
  ruleValue: '规则值',
  ruleEffect: '效果',
  priority: '优先级',
  status: '状态'
}

const ACTION_LABELS: Record<string, string> = { all: '读写通用', read: '仅查询', write: '仅新增/修改', delete: '仅删除' }
const OPERATOR_LABELS: Record<string, string> = {
  eq: '等于', ne: '不等于', gt: '大于', gte: '大于等于', lt: '小于', lte: '小于等于',
  in: '属于列表', not_in: '不属于列表', like: '包含', self: '是本人', dept: '属本人部门'
}

export function DataRulePage() {
  const [list, setList] = useState<DataRule[] | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [booted, setBooted] = useState(false)
  const [resourceFilter, setResourceFilter] = useState('all')
  const [actionFilter, setActionFilter] = useState('all')
  const [formOpen, setFormOpen] = useState(false)
  const [editing, setEditing] = useState<DataRule | null>(null)
  const [deleting, setDeleting] = useState<DataRule | null>(null)

  const load = useCallback(() => {
    setLoading(true)
    setError(null)
    fetchDataRules()
      .then(setList)
      .catch(e => setError(e instanceof Error ? e.message : '加载失败'))
      .finally(() => {
        setLoading(false)
        setBooted(true)
      })
  }, [])

  useEffect(load, [load])

  const rules = useMemo(() => list ?? [], [list])

  const openCreate = () => {
    setEditing(null)
    setFormOpen(true)
  }

  const openEdit = (rule: DataRule) => {
    setEditing(rule)
    setFormOpen(true)
  }

  const columns = useMemo<ColumnDef<DataRule>[]>(
    () => [
      {
        accessorKey: 'name',
        header: ({ column }) => <DataTableColumnHeader column={column} title="规则名称" />,
        cell: ({ row }) => <span className="font-medium">{row.getValue('name')}</span>
      },
      {
        accessorKey: 'resource',
        header: ({ column }) => <DataTableColumnHeader column={column} title="资源" />,
        cell: ({ row }) => <code className="bg-muted rounded px-1.5 py-0.5 text-xs">{row.getValue('resource')}</code>,
        filterFn: (row, id, value) => row.getValue(id) === value
      },
      {
        accessorKey: 'action',
        header: ({ column }) => <DataTableColumnHeader column={column} title="动作" />,
        cell: ({ row }) => ACTION_LABELS[row.getValue<string>('action')] ?? row.getValue('action'),
        filterFn: (row, id, value) => row.getValue(id) === value
      },
      {
        accessorKey: 'ruleField',
        header: ({ column }) => <DataTableColumnHeader column={column} title="过滤字段" />,
        cell: ({ row }) => <code className="text-xs">{row.getValue('ruleField')}</code>
      },
      {
        accessorKey: 'ruleOperator',
        header: ({ column }) => <DataTableColumnHeader column={column} title="运算符" />,
        cell: ({ row }) => OPERATOR_LABELS[row.getValue<string>('ruleOperator')] ?? row.getValue('ruleOperator')
      },
      {
        accessorKey: 'ruleValue',
        header: '规则值',
        enableSorting: false,
        cell: ({ row }) => <span className="text-muted-foreground">{row.getValue('ruleValue') || '-'}</span>
      },
      {
        accessorKey: 'ruleEffect',
        header: ({ column }) => <DataTableColumnHeader column={column} title="效果" />,
        cell: ({ row }) => {
          const effect = row.getValue<string>('ruleEffect')
          return <StatusBadge ok={effect === 'allow'} label={effect === 'allow' ? '允许' : '拒绝'} />
        }
      },
      {
        accessorKey: 'priority',
        header: ({ column }) => <DataTableColumnHeader column={column} title="优先级" />,
        cell: ({ row }) => <span className="tabular-nums">{row.getValue('priority')}</span>
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
        id: 'actions',
        header: () => <div className="text-end">操作</div>,
        enableSorting: false,
        enableHiding: false,
        cell: ({ row }) => (
          <div className="text-end">
            {hasPermission('system:rule:write') && (
              <Button variant="ghost" size="icon" onClick={() => openEdit(row.original)}>
                <Pencil className="size-4" />
                <span className="sr-only">编辑</span>
              </Button>
            )}
            {hasPermission('system:rule:write') && (
              <Button variant="ghost" size="icon" onClick={() => setDeleting(row.original)}>
                <Trash2 className="text-destructive size-4" />
                <span className="sr-only">删除</span>
              </Button>
            )}
          </div>
        )
      }
    ],
    []
  )

  const columnFilters = useMemo(() => {
    const filters: Array<{ id: string; value: string }> = []
    if (resourceFilter !== 'all') filters.push({ id: 'resource', value: resourceFilter })
    if (actionFilter !== 'all') filters.push({ id: 'action', value: actionFilter })
    return filters
  }, [resourceFilter, actionFilter])
  const { table, keyword, setKeyword } = useDataTable({ data: rules, columns, columnFilters, getRowId: rule => rule.id })

  const handleSubmit = (values: DataRuleWritePayload) => {
    const request = editing
      ? withOperationLog('更新数据规则', () => updateDataRule(editing.id, values))
      : withOperationLog('新增数据规则', () => createDataRule(values))
    request
      .then(() => {
        toast.success(editing ? '数据规则已更新' : '数据规则已创建')
        setFormOpen(false)
        load()
      })
      .catch(e => toastError(e, '保存失败'))
  }

  const handleDelete = () => {
    if (!deleting) return
    withOperationLog('删除数据规则', () => deleteDataRule(deleting.id))
      .then(() => {
        toast.success('数据规则已删除')
        load()
      })
      .catch(e => toastError(e, '删除失败'))
    setDeleting(null)
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">数据规则</h1>
          <p className="text-muted-foreground text-sm">
            共 {rules.length} 条规则 · 规则只控制可见行；allow 取 OR，deny 取 AND NOT，精确动作优先于 all
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          {hasPermission('system:rule:write') && (
            <Button onClick={openCreate}>
              <Plus />
              新增规则
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
                <Input placeholder="搜索规则名称 / 字段" value={keyword} onChange={e => setKeyword(e.target.value)} />
              </div>
              <Select value={resourceFilter} onValueChange={setResourceFilter} items={{ all: '全部资源', biz_order: '订单', customer: '客户', supplier: '供应商' }}>
                <SelectTrigger className="h-9 w-32">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">全部资源</SelectItem>
                  <SelectItem value="biz_order">订单</SelectItem>
                  <SelectItem value="customer">客户</SelectItem>
                  <SelectItem value="supplier">供应商</SelectItem>
                </SelectContent>
              </Select>
              <Select value={actionFilter} onValueChange={setActionFilter} items={{ all: '全部动作', ...ACTION_LABELS }}>
                <SelectTrigger className="h-9 w-36">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">全部动作</SelectItem>
                  {Object.entries(ACTION_LABELS).map(([value, label]) => (
                    <SelectItem key={value} value={value}>
                      {label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <RefreshButton onClick={() => void load()} disabled={loading} spinning={loading} className="ms-auto" />
              <DataTableViewOptions table={table} columnLabels={columnLabels} />
            </div>

            <DataTable table={table} loading={loading} emptyText="没有匹配的规则" />
            <DataTablePagination table={table} />
          </CardContent>
        </Card>
      )}

      {formOpen && (
        <DataRuleFormDialog key={editing?.id ?? 'new'} open={formOpen} onOpenChange={setFormOpen} rule={editing} onSubmit={handleSubmit} />
      )}

      <ConfirmDialog
        open={!!deleting}
        onOpenChange={value => !value && setDeleting(null)}
        description={<>即将删除数据规则「{deleting?.name}」。若仍被授权引用，后端会拒绝删除。</>}
        onConfirm={handleDelete}
      />
    </div>
  )
}
