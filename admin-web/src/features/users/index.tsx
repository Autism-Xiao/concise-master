import { toastError } from '@/lib/toast-error'
import { useCallback, useEffect, useMemo, useState } from 'react'
import type { ColumnDef } from '@tanstack/react-table'
import { Archive, Droplets, Download, Plus, Search, ShieldBan, ShieldCheck, Trash2, Upload, UserCog } from 'lucide-react'
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
import { UserPersonalMenusDialog } from './components/user-personal-menus-dialog'
import { UserDetailPanel } from './components/user-detail-panel'
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
import { fetchGrants, type Grant } from '@/features/system/grant/api'
import { fetchMenus } from '@/features/system/menu/api'
import { toastBatchResult } from '@/lib/batch-delete'
import { buildUserColumns, columnLabels } from './user-columns'

export function UsersPage() {
  /** 状态筛选：交给接口（serverStatus 为空串表示不筛） */
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [formOpen, setFormOpen] = useState(false)
  const [editing, setEditing] = useState<User | null>(null)
  const [deleting, setDeleting] = useState<User | null>(null)
  const [watermarkTarget, setWatermarkTarget] = useState<User | null>(null)
  const [vipTarget, setVipTarget] = useState<User | null>(null)
  const [superviseTarget, setSuperviseTarget] = useState<User | null>(null)
  const [personalMenusTarget, setPersonalMenusTarget] = useState<User | null>(null)
  // 特性开关（GET /v1/features，租户视角）：监管部门能力可按租户关闭
  const superviseDeptEnabled = useFeature('rbac.superviseDept')
  /** 用户 id → 生效中的个人授权菜单名（一次批量拉取，供列表列展示；弹窗内再按需拉详情） */
  const [personalMenus, setPersonalMenus] = useState<Record<string, string[]>>({})
  /** 主从布局：右侧详情选中的用户 id；不手动选时默认当前页第一行 */
  const [activeUserId, setActiveUserId] = useState<string | null>(null)
  /** 重置密码等操作后递增，驱动详情日志区重新加载 */
  const [refreshToken, setRefreshToken] = useState(0)
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

  /** 列表查询：翻页/搜索/排序/状态都由接口完成，前端只维护查询参数 */
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
      deptIds: '' // 部门树已移除；保留字段满足查询类型，空串 = 不过滤
    }),
    [statusFilter]
  )

  /** 批量拉取全部「用户主体」的授权 + 菜单表，避免列表逐行请求；授权列表接口不支持按 ids 过滤，取回后前端按主体分组 */
  useEffect(() => {
    if (!hasPermission('system:grant:list')) return
    Promise.all([
      fetchGrants({ subjectType: 'user' }).catch(() => [] as Grant[]),
      fetchMenus().catch(() => [])
    ])
      .then(([grants, menus]) => {
        const names = new Map(menus.map(menu => [menu.id, menu.name]))
        const now = Date.now()
        const grouped: Record<string, string[]> = {}
        for (const grant of grants) {
          if (grant.status !== 1 || grant.ruleEffect === 'deny') continue
          if (grant.expireAt && new Date(grant.expireAt).getTime() <= now) continue
          const list = grouped[grant.subjectId] ?? (grouped[grant.subjectId] = [])
          const name = names.get(grant.permissionId) ?? grant.permissionId
          if (!list.includes(name)) list.push(name)
        }
        setPersonalMenus(grouped)
      })
      .catch(() => setPersonalMenus({}))
  }, [])

  const openCreate = () => {
    setEditing(null)
    setFormOpen(true)
  }

  const openEdit = (user: User) => {
    setEditing(user)
    setFormOpen(true)
  }

  const columns = useMemo<ColumnDef<User>[]>(
    () =>
      buildUserColumns({
        onSelect: user => setActiveUserId(user.id),
        activeUserId: activeUserId ?? undefined,
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
        setPersonalMenusTarget,
        setVipTarget,
        setDeleting,
        superviseDeptEnabled,
        personalMenus
      }),
    // eslint-disable-next-line react-hooks/exhaustive-deps -- handler 均为渲染期闭包取最新值；普通值异步拉到后必须重建列
    [superviseDeptEnabled, personalMenus, activeUserId]
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
  /** 详情面板当前用户：手动点击账号优先，否则取当前页第一行；翻页后自动跟随 */
  const activeUser = pageRows.find(row => row.original.id === activeUserId)?.original ?? pageRows[0]?.original ?? null
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

  /** 导出 Excel：与列表同过滤条件（关键字/状态），导出的是筛选后的结果（不筛选即全量） */
  const handleExport = () => {
    setExporting(true)
    exportUsers({
      keyword: keyword.trim(),
      status: statusFilter === 'all' ? '' : statusFilter
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
      .then(result => {
        setResetResult({ username: user.username, password: result.password })
        setRefreshToken(token => token + 1) // 详情日志区立即看到本次重置记录
      })
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

  return (
    <div className="space-y-6">
      {/* 页标题：整行置顶（与其他页面惯例一致），下方才是主从网格 */}
      <div className="flex flex-wrap items-center justify-between gap-2">
        <div>
          <h1 className="text-2xl font-bold">用户管理</h1>
          <p className="text-muted-foreground text-sm">
            {/* 服务端分页后会拿到真实总数；total=-1 说明本次跳过了 COUNT，只能报「当前页 N 条」 */}
            {total >= 0 ? `共 ${total} 个用户` : `当前页 ${pageRows.length} 个用户`}
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

      <div className="items-start gap-4 xl:grid xl:grid-cols-[minmax(0,3fr)_minmax(0,7fr)]">
        {/* 左：用户列表（保留勾选框与批量操作） */}
        <div className="min-w-0 space-y-3">
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

        {/* 右：用户详情（基本信息 / 个人权限 + 用户日志） */}
        <div className="mt-4 min-w-0 xl:sticky xl:top-4 xl:mt-0">
          <UserDetailPanel
            user={activeUser}
            refreshToken={refreshToken}
            superviseDeptEnabled={superviseDeptEnabled}
            onEdit={openEdit}
            onResetPassword={handleResetPassword}
            onStatus={setStatusTarget}
            onKick={setKickTarget}
            onWatermark={setWatermarkTarget}
            onVip={setVipTarget}
            onSupervise={setSuperviseTarget}
            onDelete={setDeleting}
            onPlatformAdmin={handlePlatformAdmin}
            onReload={() => { setRefreshToken(token => token + 1); void reload() }}
          />
        </div>

        {formOpen && (
          <UserFormDrawer
            key={editing?.id ?? 'new'}
            open={formOpen}
            onOpenChange={setFormOpen}
            user={editing}
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

        {personalMenusTarget && (
          <UserPersonalMenusDialog
            key={personalMenusTarget.id}
            open={!!personalMenusTarget}
            onOpenChange={v => !v && setPersonalMenusTarget(null)}
            user={personalMenusTarget}
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
