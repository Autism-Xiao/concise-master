import { toastError } from '@/lib/toast-error'
import { useCallback, useEffect, useMemo, useState } from 'react'
import type { ColumnDef } from '@tanstack/react-table'
import { Archive, Droplets, Download, Plus, Search, ShieldBan, ShieldCheck, Trash2, Upload, UserCog, Users } from 'lucide-react'
import { toast } from 'sonner'
import { useFeature } from '@/lib/features'
import { Button } from '@/components/ui/button'
import { RefreshButton } from '@/components/ui/refresh-button'
import { Card, CardContent } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Skeleton } from '@/components/ui/skeleton'
import { ConfirmDialog } from '@/components/confirm-dialog'
import { DataTable, DataTablePagination, DataTableViewOptions, useServerTable, type ServerTableQuery } from '@/components/data-table'
import { hasPermission } from '@/lib/auth'
import { UserFormDrawer } from './components/user-form-drawer'
import { UserWatermarkDialog } from './components/user-watermark-dialog'
import { UserVipDialog } from './components/user-vip-dialog'
import { ResetPasswordResultDialog } from './components/reset-password-result-dialog'
import { RecycleBinDialog } from './components/recycle-bin-dialog'
import { saveBlobFile } from '@/lib/download'
import { ExcelImportDialog } from '@/components/excel-import-dialog'
import { UserLoginLogDialog } from './components/user-login-log-dialog'
import { BatchRolesDialog } from './components/batch-roles-dialog'
import { SuperviseDeptsDialog } from './components/supervise-depts-dialog'
import { BATCH_WATERMARK_MODE_LABEL, BatchWatermarkDialog } from './components/batch-watermark-dialog'
import {
  batchAssignRoles,
  batchUpdateUsersStatus,
  batchUpdateUsersWatermark,
  createUser,
  deleteUser,
  deleteUsers,
  downloadUserTemplate,
  exportUsers,
  fetchUserPage,
  forceOfflineUser,
  importUsers,
  resetUserPassword,
  setUserPlatformAdmin,
  unlockUser,
  updateUser,
  updateUserStatus,
  userStatusMap,
  type BatchWatermarkMode,
  type User,
  type UserWritePayload
} from './api'
import { withOperationLog } from '@/features/system/log/api'
import { fetchDepts, type Dept } from '@/features/system/dept/api'
import { toastBatchResult } from '@/lib/batch-delete'
import { cn } from 'cn'
import { buildDeptTree, collectSubtreeIds, DeptTreeRow, type DeptNode } from './user-dept-tree'
import { buildUserColumns, columnLabels } from './user-columns'

export function UsersPage() {
  /** 状态筛选：交给接口（serverStatus 为空串表示不筛） */
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [formOpen, setFormOpen] = useState(false)
  /** 新增用户时要默认带上的部门（左树选中/行内 + 按钮），undefined = 不带 */
  const [createDeptIds, setCreateDeptIds] = useState<string[] | undefined>(undefined)
  const [editing, setEditing] = useState<User | null>(null)
  const [deleting, setDeleting] = useState<User | null>(null)
  const [watermarkTarget, setWatermarkTarget] = useState<User | null>(null)
  const [vipTarget, setVipTarget] = useState<User | null>(null)
  const [superviseTarget, setSuperviseTarget] = useState<User | null>(null)
  // 特性开关（GET /v1/features，租户视角）：监管部门能力可按租户关闭
  const superviseDeptEnabled = useFeature('rbac.superviseDept')
  const [importOpen, setImportOpen] = useState(false)
  const [exporting, setExporting] = useState(false)
  /** 重置密码结果：非空时弹一次性明文展示框 */
  const [resetResult, setResetResult] = useState<{ username: string; password: string } | null>(null)
  /** 冻结/解冻二次确认目标 */
  const [statusTarget, setStatusTarget] = useState<{ user: User; next: 1 | 2 } | null>(null)
  /** 强制下线二次确认目标 */
  const [kickTarget, setKickTarget] = useState<User | null>(null)
  const [recycleOpen, setRecycleOpen] = useState(false)
  /** 登录日志弹窗目标（按用户过滤） */
  const [logTarget, setLogTarget] = useState<User | null>(null)
  /** 批量分配角色弹窗开关（目标用户取当前勾选行） */
  const [batchRolesOpen, setBatchRolesOpen] = useState(false)
  /** 批量水印弹窗开关（目标用户取当前勾选行） */
  const [batchWatermarkOpen, setBatchWatermarkOpen] = useState(false)
  /** 批量启停确认框：非空时待执行 */
  const [batchStatusTarget, setBatchStatusTarget] = useState<1 | 2 | null>(null)

  /* ---------- 左侧部门树（可选过滤器：不选 = 查全部；接口失败/无部门时整块隐藏降级为单列表格） ---------- */
  const [depts, setDepts] = useState<Dept[] | null>(null)
  const [deptKeyword, setDeptKeyword] = useState('')
  const [selectedDeptId, setSelectedDeptId] = useState<string | null>(null)
  const [deptCollapsed, setDeptCollapsed] = useState<Set<string>>(new Set())

  useEffect(() => {
    // 部门树是增强能力不是依赖：拉不到就静默降级，用户管理页依然可用
    fetchDepts()
      .then(setDepts)
      .catch(() => setDepts([]))
  }, [])

  const deptTree = useMemo(() => (depts ? buildDeptTree(depts) : []), [depts])
  const deptById = useMemo(() => new Map((depts ?? []).map(d => [d.id, d])), [depts])
  /** 选中的部门已不存在（被删/被筛掉）时回退到「全部部门」，避免右侧停在过期过滤上 */
  useEffect(() => {
    if (depts && selectedDeptId && !deptById.has(selectedDeptId)) setSelectedDeptId(null)
  }, [depts, deptById, selectedDeptId])

  const selectedDept = selectedDeptId ? (deptById.get(selectedDeptId) ?? null) : null
  /** 选中部门 → 本部门 + 子孙部门 id 并集（后端 deptIds 过滤命中任一部门即返回） */
  const selectedDeptIds = useMemo(() => {
    if (!selectedDept) return []
    const node = deptTree.find(root => root.id === selectedDept.id)
    if (node) return collectSubtreeIds(node)
    // 树里找不到（理论不可达）时兜底只过滤本部门
    return [selectedDept.id]
  }, [selectedDept, deptTree])

  /** 部门搜索：命中名称的过滤（命中节点及其祖先链保留展开） */
  const deptSearching = deptKeyword.trim() !== ''
  const visibleDeptTree = useMemo(() => {
    if (!deptSearching) return deptTree
    const kw = deptKeyword.trim().toLowerCase()
    const filterTree = (nodes: DeptNode[]): DeptNode[] =>
      nodes
        .map(node => {
          const children = filterTree(node.children)
          if (node.departName.toLowerCase().includes(kw) || children.length) return { ...node, children }
          return null
        })
        .filter((n): n is DeptNode => n != null)
    return filterTree(deptTree)
  }, [deptTree, deptSearching, deptKeyword])

  const toggleDept = (id: string) =>
    setDeptCollapsed(prev => {
      const next = new Set(prev)
      if (next.has(id)) next.delete(id)
      else next.add(id)
      return next
    })

  /** 列表查询：翻页/搜索/排序/状态/部门都由接口完成，前端只维护查询参数 */
  const fetchPage = useCallback(
    ({ page, pageSize, keyword, filters, sortBy, sortOrder }: ServerTableQuery<{ status: string; deptIds: string }>) =>
      fetchUserPage({
        page,
        pageSize,
        keyword,
        status: filters.status,
        deptIds: filters.deptIds ? filters.deptIds.split(',').filter(Boolean) : undefined,
        sortBy,
        sortOrder
      }),
    []
  )

  const tableFilters = useMemo(
    () => ({
      status: statusFilter === 'all' ? '' : statusFilter,
      deptIds: selectedDeptIds.join(',')
    }),
    [statusFilter, selectedDeptIds]
  )

  const openCreate = (deptId?: string) => {
    setEditing(null)
    setCreateDeptIds(deptId ? [deptId] : selectedDept ? selectedDeptIds : undefined)
    setFormOpen(true)
  }

  const openEdit = (user: User) => {
    setEditing(user)
    setFormOpen(true)
  }

  const columns = useMemo<ColumnDef<User>[]>(
    () =>
      buildUserColumns({
        openEdit,
        onResetPassword: user => handleResetPassword(user),
        onUnlock: user => handleUnlock(user),
        onPlatformAdmin: user => handlePlatformAdmin(user),
        onReload: () => reload(),
        setWatermarkTarget,
        setStatusTarget,
        setKickTarget,
        setLogTarget,
        setSuperviseTarget,
        setVipTarget,
        setDeleting,
        superviseDeptEnabled
      }),
    // eslint-disable-next-line react-hooks/exhaustive-deps -- 列定义引用的是渲染期调用的 handler（闭包取最新值），不需要随函数标识重建
    []
  )

  const statusItems = useMemo(() => ({ all: '全部状态', ...Object.fromEntries(Object.entries(userStatusMap).map(([value, { label }]) => [value, label])) }), [])
  const { table, keyword, setKeyword, loading, booted, error, total, reload, rowSelection, setRowSelection } = useServerTable({
    columns,
    query: fetchPage,
    filters: tableFilters,
    getRowId: user => user.id
  })
  /** 当前页行数（导出按钮的可用性判断用，不能用 total —— 空搜索时 total 可能是 0 但列表有行） */
  const pageRows = table.getRowModel().rows
  const selectedCount = Object.keys(rowSelection).filter(key => rowSelection[key]).length
  const [batchDeleting, setBatchDeleting] = useState(false)
  const [batchBusy, setBatchBusy] = useState(false)

  const handleBatchDelete = async () => {
    const targets = table.getSelectedRowModel().rows.map(row => row.original)
    if (!targets.length || batchBusy) return
    setBatchBusy(true)
    try {
      const result = await withOperationLog(`批量删除 ${targets.length} 个用户`, () => deleteUsers(targets.map(user => user.id)))
      toastBatchResult(result, '用户')
      setBatchDeleting(false)
      setRowSelection({})
      reload()
    } finally {
      setBatchBusy(false)
    }
  }

  /** 批量启用/停用：复用单条规则（admin 跳过、停用踢会话），逐条返回跳过原因 */
  const handleBatchStatus = (next: 1 | 2) => {
    const targets = table.getSelectedRowModel().rows.map(row => row.original)
    if (!targets.length) return
    setBatchBusy(true)
    withOperationLog(`批量${next === 2 ? '停用' : '启用'} ${targets.length} 个用户`, () =>
      batchUpdateUsersStatus(
        targets.map(user => user.id),
        next,
        '管理员批量操作'
      )
    )
      .then(result => {
        toast.success(`已${next === 2 ? '停用' : '启用'} ${result.updated} 个用户${result.kicked ? `，强制下线 ${result.kicked} 个在线会话` : ''}`)
        result.skipped?.forEach(item => toast.warning(`「${item.username}」已跳过：${item.reason}`))
        setRowSelection({})
        setBatchStatusTarget(null)
        reload()
      })
      .catch(e => toastError(e, '批量操作失败'))
      .finally(() => setBatchBusy(false))
  }

  /** 批量分配角色提交 */
  const handleBatchRoles = async (ids: string[], roleIds: string[]) => {
    try {
      const result = await withOperationLog(`为 ${ids.length} 个用户批量分配角色`, () => batchAssignRoles(ids, roleIds))
      toast.success(`已更新 ${result.updated} 个用户的角色`)
      setBatchRolesOpen(false)
      setRowSelection({})
      reload()
    } catch (e) {
      toastError(e, '批量分配失败')
    }
  }

  /** 批量水印：三档成品动作（强制开/强制关/跟随全局），单条失败不阻断并回传跳过原因 */
  const handleBatchWatermark = async (ids: string[], mode: BatchWatermarkMode) => {
    try {
      const result = await withOperationLog(`批量${BATCH_WATERMARK_MODE_LABEL[mode]} ${ids.length} 个用户`, () => batchUpdateUsersWatermark(ids, mode))
      if (result.updated > 0) {
        toast.success(`已为 ${result.updated} 个用户${BATCH_WATERMARK_MODE_LABEL[mode]}，用户刷新页面后生效`)
      } else {
        toast.error('没有用户被更新')
      }
      result.skipped?.forEach(item => toast.warning(`已跳过 ${item.id}：${item.reason}`))
      setBatchWatermarkOpen(false)
      setRowSelection({})
      reload()
    } catch (e) {
      toastError(e, '批量水印设置失败')
    }
  }

  const handleSubmit = (values: UserWritePayload) => {
    const request = editing ? withOperationLog('更新用户', () => updateUser(editing.id, values)) : withOperationLog('新增用户', () => createUser(values))
    request
      .then(() => {
        toast.success(editing ? '用户已更新' : '用户已创建')
        setFormOpen(false)
        reload()
      })
      .catch(e => toastError(e, '保存失败'))
  }

  /** 导出 Excel：与列表同过滤条件（关键字/状态/部门），导出的是筛选后的结果（不筛选即全量） */
  const handleExport = () => {
    setExporting(true)
    exportUsers({
      keyword: keyword.trim(),
      status: statusFilter === 'all' ? '' : statusFilter,
      deptIds: selectedDeptIds.length ? selectedDeptIds : undefined
    })
      .then(({ filename, blob }) => {
        saveBlobFile(filename, blob)
        toast.success('用户已导出')
      })
      .catch(e => toastError(e, '导出失败'))
      .finally(() => setExporting(false))
  }

  const handleDelete = () => {
    if (!deleting) return
    withOperationLog(`删除用户「${deleting.realname || deleting.username}」`, () => deleteUser(deleting.id))
      .then(() => {
        toast.success(`已删除用户「${deleting.realname || deleting.username}」`)
        reload()
      })
      .catch(e => toastError(e, '删除失败'))
    setDeleting(null)
  }

  /** 重置密码：成功后弹一次性明文展示框（明文只在本次响应里，后端不落库） */
  const handleResetPassword = (user: User) => {
    withOperationLog(`重置用户「${user.realname || user.username}」的密码`, () => resetUserPassword(user.id))
      .then(result => setResetResult({ username: user.username, password: result.password }))
      .catch(e => toastError(e, '重置失败'))
  }

  /** 解锁登录：清零失败计数，幂等（未锁定时也提示成功无妨） */
  const handleUnlock = (user: User) => {
    withOperationLog(`解锁用户「${user.realname || user.username}」的登录`, () => unlockUser(user.id))
      .then(() => toast.success(`账号「${user.username}」已解锁`))
      .catch(e => toastError(e, '解锁失败'))
  }

  /** 授予/取消平台管理员：平台级操作，后端拒绝取消自己与最后一个；改完 alert 提示 30s 内生效 */
  const handlePlatformAdmin = (user: User) => {
    const next = Number(user.isPlatformAdmin) !== 1
    withOperationLog(`${next ? '授予' : '取消'}用户「${user.realname || user.username}」的平台管理员`, () => setUserPlatformAdmin(user.id, next))
      .then(() => {
        toast.success(next ? `已授予「${user.username}」平台管理员，最多 30 秒生效` : `已取消「${user.username}」的平台管理员权限`)
        reload()
      })
      .catch(e => toastError(e, '操作失败'))
  }

  /** 冻结/解冻确认：冻结会踢掉该用户全部在线会话 */
  const handleStatusChange = () => {
    const target = statusTarget
    if (!target) return
    const { user, next } = target
    withOperationLog(`${next === 2 ? '冻结' : '解冻'}用户「${user.realname || user.username}」`, () => updateUserStatus(user.id, next))
      .then(result => toast.success(next === 2 ? `已冻结「${user.username}」，并下线其 ${result.kicked} 个在线会话` : `已解冻「${user.username}」`))
      .catch(e => toastError(e, '操作失败'))
      .finally(() => reload())
    setStatusTarget(null)
  }

  /** 强制下线确认 */
  const handleKick = () => {
    if (!kickTarget) return
    const user = kickTarget
    withOperationLog(`强制下线用户「${user.realname || user.username}」`, () => forceOfflineUser(user.id))
      .then(result => toast.success(`已下线「${user.username}」的 ${result.kicked} 个在线会话`))
      .catch(e => toastError(e, '操作失败'))
    setKickTarget(null)
  }

  /** 部门树刷新（保持与左侧树的加载态一致：null = 骨架屏） */
  const reloadDepts = useCallback(() => {
    setDepts(null)
    fetchDepts()
      .then(setDepts)
      .catch(() => setDepts([]))
  }, [])

  return (
    <div className="space-y-6">
      {/* 页标题：整行置顶（与其他页面惯例一致），下方才是主从网格 */}
      <div className="flex flex-wrap items-center justify-between gap-2">
        <div>
          <h1 className="text-2xl font-bold">用户管理</h1>
          <p className="text-muted-foreground text-sm">
            {/* 服务端分页后会拿到真实总数；total=-1 说明本次跳过了 COUNT，只能报「当前页 N 条」 */}
            {total >= 0 ? `共 ${total} 个用户` : `当前页 ${pageRows.length} 个用户`}
            {selectedDept && ` · 「${selectedDept.departName}」及下级`}
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          {hasPermission('system:user:export') && (
            <Button variant="outline" onClick={handleExport} disabled={exporting || pageRows.length === 0}>
              <Download />
              {exporting ? '导出中…' : '导出'}
            </Button>
          )}
          {hasPermission('system:user:import') && (
            <Button variant="outline" onClick={() => setImportOpen(true)}>
              <Upload />
              导入
            </Button>
          )}
          {hasPermission('system:user:restore') && (
            <Button variant="outline" onClick={() => setRecycleOpen(true)}>
              <Archive />
              回收站
            </Button>
          )}
          {hasPermission('system:user:delete') && selectedCount > 0 && (
            <Button variant="outline" onClick={() => setBatchDeleting(true)} disabled={batchBusy}>
              <Trash2 />
              批量删除（{selectedCount}）
            </Button>
          )}
          {hasPermission('system:user:update') && selectedCount > 0 && (
            <>
              <Button variant="outline" onClick={() => setBatchStatusTarget(1)} disabled={batchBusy}>
                <ShieldCheck />
                批量启用（{selectedCount}）
              </Button>
              <Button variant="outline" onClick={() => setBatchStatusTarget(2)} disabled={batchBusy}>
                <ShieldBan />
                批量停用（{selectedCount}）
              </Button>
              <Button variant="outline" onClick={() => setBatchRolesOpen(true)} disabled={batchBusy}>
                <UserCog />
                批量分配角色（{selectedCount}）
              </Button>
              <Button variant="outline" onClick={() => setBatchWatermarkOpen(true)} disabled={batchBusy}>
                <Droplets />
                批量水印（{selectedCount}）
              </Button>
            </>
          )}
          {hasPermission('system:user:add') && (
            <Button onClick={() => openCreate()}>
              <Plus />
              新增用户
            </Button>
          )}
        </div>
      </div>

      <div className="grid gap-4 xl:grid-cols-[240px_minmax(0,1fr)]">
        {/* 左：部门树 —— 可选过滤器，不选 = 查全部；无部门/接口失败时整块隐藏，降级为单列表格 */}
        {depts === null ? (
          <Card className="h-fit xl:sticky xl:top-4">
            <div className="px-3 pt-3">
              <Skeleton className="h-6 w-24" />
              <Skeleton className="mt-3 h-8 w-full" />
            </div>
            <CardContent className="space-y-2 px-3 pt-3 pb-2">
              {Array.from({ length: 6 }).map((_, i) => (
                <Skeleton key={i} className="h-7 w-full" />
              ))}
            </CardContent>
          </Card>
        ) : depts.length === 0 ? null : (
          <Card className="h-fit xl:sticky xl:top-4">
            <div className="flex items-center justify-between px-3 pt-3">
              <span className="text-sm font-semibold">部门</span>
              <RefreshButton onClick={reloadDepts} className="size-7" spinning={depts === null} />
            </div>
            <div className="px-3 pt-2 pb-1">
              <Input placeholder="搜索部门名称" className="h-8 text-sm" value={deptKeyword} onChange={e => setDeptKeyword(e.target.value)} />
            </div>
            {/* data-scroll：滚动条默认隐藏、悬停显现，与侧边栏一致 */}
            <CardContent data-scroll="tree" className="max-h-[calc(100vh-260px)] overflow-y-auto px-2 pb-2">
              <div className="py-1">
                {/* 虚拟根节点：不选部门 = 不过滤（游客模式/游离账号都能看全量） */}
                <button
                  type="button"
                  className={cn(
                    'hover:bg-accent flex w-full items-center gap-1.5 rounded-md px-2 py-1.5 text-start text-sm',
                    !selectedDeptId && 'bg-accent font-medium'
                  )}
                  onClick={() => setSelectedDeptId(null)}
                >
                  <Users className="text-muted-foreground size-3.5 shrink-0" />
                  全部部门
                </button>
                {visibleDeptTree.map(node => (
                  <DeptTreeRow
                    key={node.id}
                    node={node}
                    depth={1}
                    collapsed={deptCollapsed}
                    selectedId={selectedDeptId}
                    onToggle={toggleDept}
                    onSelect={dept => setSelectedDeptId(dept.id)}
                    onAddUser={deptId => openCreate(deptId)}
                    canAdd={hasPermission('system:user:add')}
                  />
                ))}
                {visibleDeptTree.length === 0 && deptSearching && <p className="text-muted-foreground py-6 text-center text-sm">没有匹配的部门</p>}
              </div>
            </CardContent>
          </Card>
        )}

        {/* 右：用户表格（部门树隐藏时自动占满整行） */}
        {/* 注意：xl 下首列固定 240px；部门树为空时本节点是唯一子元素，会落进首列被压成 240px，必须跨两列 */}
        <div className={cn('min-w-0', depts?.length === 0 && 'xl:col-span-2')}>
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
                <Button variant="outline" onClick={reload}>
                  重试
                </Button>
              </CardContent>
            </Card>
          ) : (
            <Card>
              <CardContent className="space-y-4">
                <div className="flex flex-wrap items-center gap-2">
                  <div className="relative w-full max-w-xs">
                    <Search className="text-muted-foreground absolute start-2.5 top-1/2 size-4 -translate-y-1/2" />
                    <Input placeholder="搜索账号 / 姓名 / 手机号" className="ps-8" value={keyword} onChange={e => setKeyword(e.target.value)} />
                  </div>
                  <Select value={statusFilter} onValueChange={setStatusFilter} items={statusItems}>
                    <SelectTrigger className="h-9 w-32">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">全部状态</SelectItem>
                      {Object.entries(userStatusMap).map(([value, { label }]) => (
                        <SelectItem key={value} value={value}>
                          {label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <RefreshButton onClick={() => void reload()} className="ms-auto" />
                  <DataTableViewOptions table={table} columnLabels={columnLabels} />
                </div>

                <DataTable table={table} loading={loading} emptyText="没有匹配的用户" />
                <DataTablePagination table={table} />
              </CardContent>
            </Card>
          )}
        </div>

        {formOpen && (
          <UserFormDrawer
            key={`${editing?.id ?? 'new'}-${(createDeptIds ?? []).join(',')}`}
            open={formOpen}
            onOpenChange={setFormOpen}
            user={editing}
            defaultDeptIds={createDeptIds}
            onSubmit={handleSubmit}
          />
        )}

        {importOpen && (
          <ExcelImportDialog
            open={importOpen}
            onOpenChange={setImportOpen}
            title="导入用户"
            description="按「登录账号」判定：不存在则新增（密码留空将生成随机初始密码，并在导入结果里展示一次），已存在则更新填写了的字段。部门/角色按名称匹配，多个用「/」分隔。仅支持 .xlsx，单次最多 2000 行。"
            warning={
              <>
                已存在的「登录账号」会被<b className="font-medium">覆盖</b>（含密码、角色、状态与部门），不是只跳过。导入前请核对文件里有没有误填系统账号。
              </>
            }
            accept=".xlsx,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            onImported={reload}
            downloadTemplate={downloadUserTemplate}
            importFile={file => importUsers(file).then(r => ({ ...r, errors: r.errors.map(e => ({ ...e, label: e.username })) }))}
          />
        )}

        {watermarkTarget && (
          <UserWatermarkDialog
            key={watermarkTarget.id}
            open={!!watermarkTarget}
            onOpenChange={v => !v && setWatermarkTarget(null)}
            user={watermarkTarget}
            onSaved={() => {
              toast.success(`已更新「${watermarkTarget.realname || watermarkTarget.username}」的水印设置`)
              reload()
            }}
          />
        )}

        {vipTarget && <UserVipDialog key={vipTarget.id} open={!!vipTarget} onOpenChange={v => !v && setVipTarget(null)} user={vipTarget} onSaved={reload} />}

        {superviseTarget && (
          <SuperviseDeptsDialog
            key={superviseTarget.id}
            open={!!superviseTarget}
            onOpenChange={v => !v && setSuperviseTarget(null)}
            user={superviseTarget}
            onSaved={reload}
          />
        )}

        <ConfirmDialog
          confirmText="删除"
          open={!!deleting}
          onOpenChange={v => !v && setDeleting(null)}
          description={<>即将删除用户「{deleting?.realname || deleting?.username}」，该操作为软删除，可在「回收站」恢复。</>}
          onConfirm={handleDelete}
        />

        <ConfirmDialog
          confirmText="删除"
          open={batchDeleting}
          onOpenChange={v => !batchBusy && setBatchDeleting(v)}
          title="批量删除用户"
          description={
            <>
              即将删除勾选的 {selectedCount} 个用户，该操作为软删除，可在「回收站」恢复。{batchBusy ? '正在删除，请稍候…' : ''}
            </>
          }
          onConfirm={handleBatchDelete}
        />

        <ResetPasswordResultDialog
          open={!!resetResult}
          onOpenChange={v => !v && setResetResult(null)}
          username={resetResult?.username}
          password={resetResult?.password}
        />

        <ConfirmDialog
          confirmText={statusTarget?.next === 2 ? '冻结' : '解冻'}
          confirmVariant={statusTarget?.next === 2 ? 'destructive' : 'default'}
          open={!!statusTarget}
          onOpenChange={v => !v && setStatusTarget(null)}
          title={statusTarget?.next === 2 ? '确认冻结该账号？' : '确认解冻该账号？'}
          description={
            statusTarget?.next === 2 ? (
              <>即将冻结用户「{statusTarget?.user.realname || statusTarget?.user.username}」：登录立即被拒，其全部在线会话将被强制下线。解冻可随时在此操作。</>
            ) : (
              <>即将解冻用户「{statusTarget?.user.realname || statusTarget?.user.username}」，解冻后可正常登录。</>
            )
          }
          onConfirm={handleStatusChange}
        />

        <ConfirmDialog
          confirmText="强制下线"
          open={!!kickTarget}
          onOpenChange={v => !v && setKickTarget(null)}
          title="确认强制下线？"
          description={<>即将把用户「{kickTarget?.realname || kickTarget?.username}」的全部在线会话踢下线，其令牌立即失效，可重新登录。</>}
          onConfirm={handleKick}
        />

        <RecycleBinDialog open={recycleOpen} onOpenChange={setRecycleOpen} onRestored={reload} />

        {logTarget && <UserLoginLogDialog key={logTarget.id} open={!!logTarget} onOpenChange={v => !v && setLogTarget(null)} user={logTarget} />}

        {batchRolesOpen && selectedCount > 0 && (
          <BatchRolesDialog
            open={batchRolesOpen}
            onOpenChange={v => {
              if (!v) setBatchRolesOpen(false)
            }}
            targets={table.getSelectedRowModel().rows.map(row => row.original)}
            onSubmit={handleBatchRoles}
          />
        )}

        {batchWatermarkOpen && selectedCount > 0 && (
          <BatchWatermarkDialog
            open={batchWatermarkOpen}
            onOpenChange={v => {
              if (!v) setBatchWatermarkOpen(false)
            }}
            targets={table.getSelectedRowModel().rows.map(row => row.original)}
            onSubmit={handleBatchWatermark}
          />
        )}

        <ConfirmDialog
          confirmText={batchStatusTarget === 2 ? '停用' : '启用'}
          confirmVariant={batchStatusTarget === 2 ? 'destructive' : 'default'}
          open={!!batchStatusTarget}
          onOpenChange={v => {
            if (!batchBusy) setBatchStatusTarget(v ? batchStatusTarget : null)
          }}
          title={batchStatusTarget === 2 ? `确认批量停用 ${selectedCount} 个账号？` : `确认批量启用 ${selectedCount} 个账号？`}
          description={
            batchStatusTarget === 2 ? (
              <>停用后这些用户立即无法登录，全部在线会话将被强制下线；内置管理员会被自动跳过并在结果中说明。</>
            ) : (
              <>启用后这些用户可正常登录。</>
            )
          }
          onConfirm={() => batchStatusTarget && handleBatchStatus(batchStatusTarget)}
        />
      </div>
    </div>
  )
}
