import { useCallback, useEffect, useMemo, useState } from 'react'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader } from '@/components/ui/card'
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuSeparator, DropdownMenuTrigger } from '@/components/ui/dropdown-menu'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Segmented } from '@/components/ui/segmented'
import { Skeleton } from '@/components/ui/skeleton'
import { hasPermission } from '@/lib/auth'
import { toast } from 'sonner'
import { toastError } from '@/lib/toast-error'
import { MoreHorizontal, Pencil, KeyRound } from 'lucide-react'
import { fetchMenus, type Menu } from '@/features/system/menu/api'
import { fetchDataRules, type DataRule } from '@/features/system/data-rule/api'
import { fetchRoleOptions, type Role } from '@/features/system/role/api'
import {
  createGrant,
  deleteGrant,
  fetchGrants,
  updateGrant,
  type Grant,
  type GrantWritePayload
} from '@/features/system/grant/api'
import { GrantFormDialog } from '@/features/system/grant/components/grant-form-dialog'
import { fetchOnlineUsers, type OnlineUser } from '@/features/ops/online/api'
import { batchAssignRoles, fetchUserDetail, userStatusMap, type User } from '../api'
import { UserActivityLog } from './user-activity-log'

const TABS = [
  { value: 'basic', label: '基本信息' },
  { value: 'permission', label: '权限配置' }
] as const

const SEX_LABELS: Record<number, string> = { 0: '未知', 1: '男', 2: '女' }

interface UserDetailPanelProps {
  user: User | null
  refreshToken: number
  /** 租户特性开关：监管部门能力可按租户关闭（与列表页口径一致） */
  superviseDeptEnabled: boolean
  onEdit: (user: User) => void
  onResetPassword: (user: User) => void
  onStatus: (target: { user: User; next: 1 | 2 } | null) => void
  onKick: (user: User | null) => void
  onWatermark: (user: User | null) => void
  onVip: (user: User | null) => void
  onSupervise: (user: User | null) => void
  onDelete: (user: User | null) => void
  onPlatformAdmin: (user: User) => void
  onReload: () => void
}

function DetailRow({ label, children }: { label: string; children?: React.ReactNode }) {
  return (
    <div className="border-border/60 flex items-start gap-3 border-b px-2 py-2.5 last:border-b-0">
      <span className="text-muted-foreground w-20 shrink-0 text-sm">{label}</span>
      <span className="min-w-0 flex-1 text-sm break-all">{children || '-'}</span>
    </div>
  )
}

function formatDate(value?: string | null): string {
  if (!value) return '-'
  return String(value).replace('T', ' ').slice(0, 19)
}

/**
 * 用户详情（主从布局右栏）
 *
 * 两个 Tab：基本信息 / 权限配置（角色 + 个人权限 + 数据权限，均来自 sys_grant / sys_data_rule）。
 * 下方固定展示用户日志区：登录 / 操作 / 密码修改。
 * 档案 Tab 按需求砍掉，原基础字段并入「基本信息」。
 */
export function UserDetailPanel(props: UserDetailPanelProps) {
  const { user, refreshToken, superviseDeptEnabled, onEdit, onResetPassword, onStatus, onKick, onWatermark, onVip, onSupervise, onDelete, onPlatformAdmin, onReload } = props
  const [tab, setTab] = useState<'basic' | 'permission'>('basic')
  const [detail, setDetail] = useState<User | null>(null)
  const [loading, setLoading] = useState(false)
  const [grants, setGrants] = useState<Grant[] | null>(null)
  const [menus, setMenus] = useState<Menu[]>([])
  const [grantFormOpen, setGrantFormOpen] = useState(false)
  const [editingGrant, setEditingGrant] = useState<Grant | null>(null)
  const [onlineSession, setOnlineSession] = useState<OnlineUser | null>(null)
  /** 权限配置 Tab：角色列表、数据规则表（用于把 grant.ruleId 翻译成中文规则名） */
  const [roles, setRoles] = useState<Role[]>([])
  const [dataRules, setDataRules] = useState<DataRule[]>([])
  /** 单用户分配角色弹窗 */
  const [roleDialogOpen, setRoleDialogOpen] = useState(false)
  const [selectedRoleIds, setSelectedRoleIds] = useState<string[]>([])
  const [savingRoles, setSavingRoles] = useState(false)
  /** 授权过期判断的基准时刻（挂载时固定，避免渲染期调用 Date.now 破坏纯度） */
  const [now] = useState(() => Date.now())

  const userId = user?.id

  useEffect(() => {
    if (!userId) {
      setDetail(null)
      setGrants(null)
      setOnlineSession(null)
      return
    }
    let cancelled = false
    setLoading(true)
    fetchUserDetail(userId)
      .then(data => { if (!cancelled) setDetail(data) })
      .catch(e => toastError(e, '加载用户详情失败'))
      .finally(() => { if (!cancelled) setLoading(false) })
    return () => { cancelled = true }
  }, [userId, refreshToken])

  const loadGrants = useCallback(() => {
    if (!userId) return
    fetchGrants({ subjectType: 'user', subjectId: userId })
      .then(setGrants)
      .catch(() => setGrants([]))
  }, [userId])

  useEffect(() => { loadGrants() }, [loadGrants, refreshToken])

  useEffect(() => {
    fetchMenus().then(setMenus).catch(() => setMenus([]))
  }, [])

  // 权限配置 Tab 依赖：角色列表（分配弹窗）+ 数据规则表（ruleId → 规则名）
  useEffect(() => {
    fetchRoleOptions().then(setRoles).catch(() => setRoles([]))
    fetchDataRules().then(setDataRules).catch(() => setDataRules([]))
  }, [])

  // 当前在线会话：只在 Redis 里，离线后查不到；在线时长取 lastActive - loginTime 的实时值
  useEffect(() => {
    if (!user?.username) { setOnlineSession(null); return }
    fetchOnlineUsers({ page: 1, pageSize: 100, keyword: user.username })
      .then(res => setOnlineSession(res.records.find(s => s.userId === user.id) ?? null))
      .catch(() => setOnlineSession(null))
  }, [user?.id, user?.username, refreshToken])

  const menuNameById = useMemo(() => new Map(menus.map(menu => [menu.id, menu.name])), [menus])
  const ruleNameById = useMemo(() => new Map(dataRules.map(rule => [rule.id, rule.name])), [dataRules])
  /** 数据权限：带 ruleId 的个人授权（数据规则是全局的，主体绑定在 grant.ruleId 上） */
  const dataGrants = useMemo(() => (grants ?? []).filter(grant => !!grant.ruleId), [grants])
  const onlineDuration = useMemo(() => {
    if (!onlineSession) return '-'
    const start = new Date(onlineSession.loginTime).getTime()
    const end = new Date(onlineSession.lastActive).getTime()
    const minutes = Math.max(0, Math.floor((end - start) / 60_000))
    if (minutes < 1) return '不足 1 分钟'
    if (minutes < 60) return `${minutes} 分钟`
    return `${Math.floor(minutes / 60)} 小时 ${minutes % 60} 分钟`
  }, [onlineSession])

  const current = detail ?? user
  const submitGrant = (values: GrantWritePayload) => {
    const request = editingGrant ? updateGrant(editingGrant.id, values) : createGrant(values)
    request
      .then(() => {
        toast.success(editingGrant ? '授权已更新' : '授权已新增')
        setGrantFormOpen(false)
        setEditingGrant(null)
        loadGrants()
        onReload()
      })
      .catch(e => toastError(e, '保存授权失败'))
  }

  const removeGrant = (grant: Grant) => {
    if (!window.confirm(`确认删除授权「${menuNameById.get(grant.permissionId) ?? grant.permissionId}」？`)) return
    deleteGrant(grant.id)
      .then(() => { toast.success('授权已删除'); loadGrants(); onReload() })
      .catch(e => toastError(e, '删除授权失败'))
  }

  /** 打开角色分配弹窗：带上当前用户手动绑定的角色（岗位带入的角色由岗位决定，不在此覆盖） */
  const openRoleDialog = () => {
    const manualRoleIds = (current?.roles ?? [])
      .filter(role => current?.roleSources?.[role.id] !== 'position')
      .map(role => role.id)
    setSelectedRoleIds(manualRoleIds)
    setRoleDialogOpen(true)
  }

  const submitRoles = () => {
    if (!current) return
    setSavingRoles(true)
    batchAssignRoles([current.id], selectedRoleIds)
      .then(() => {
        toast.success('角色已更新，权限实时生效')
        setRoleDialogOpen(false)
        onReload()
      })
      .catch(e => toastError(e, '角色分配失败'))
      .finally(() => setSavingRoles(false))
  }

  if (!current) {
    return (
      <Card>
        <CardContent className="text-muted-foreground flex min-h-80 items-center justify-center text-sm">
          请从左侧列表点击账号，查看用户详情
        </CardContent>
      </Card>
    )
  }

  const statusMap = userStatusMap[current.status] ?? userStatusMap[1]

  return (
    <>
    <Card>
      <CardHeader className="flex flex-row items-start justify-between gap-3 border-b pb-3">
        <div className="flex min-w-0 items-center gap-3">
          <Avatar className="size-11 shrink-0">
            {current.avatar && <AvatarImage src={current.avatar} alt={current.realname || current.username} />}
            <AvatarFallback>{(current.realname || current.username).slice(0, 2).toUpperCase()}</AvatarFallback>
          </Avatar>
          <div className="min-w-0">
            <div className="flex flex-wrap items-center gap-2">
              <h3 className="truncate text-base font-semibold">{current.realname || current.username}</h3>
              <span className={`rounded-full px-2 py-0.5 text-xs ${statusMap.className}`}>{statusMap.label}</span>
              {onlineSession && <span className="rounded-full bg-emerald-500/15 px-2 py-0.5 text-xs text-emerald-600 dark:text-emerald-400">在线</span>}
            </div>
            <p className="text-muted-foreground mt-0.5 truncate font-mono text-xs">{current.username}</p>
          </div>
        </div>
        <div className="flex shrink-0 items-center gap-1">
          {hasPermission('system:user:update') && (
            <Button variant="outline" size="sm" onClick={() => onEdit(current)}><Pencil className="size-3.5" />编辑</Button>
          )}
          {hasPermission('system:user:reset-password') && (
            <Button variant="outline" size="sm" onClick={() => onResetPassword(current)}><KeyRound className="size-3.5" />重置密码</Button>
          )}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon" className="size-8"><MoreHorizontal className="size-4" /></Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              {hasPermission('system:user:update') && (
                <>
                  <DropdownMenuItem onClick={() => onStatus({ user: current, next: current.status === 1 ? 2 : 1 })}>
                    {current.status === 1 ? '冻结账号' : '解冻账号'}
                  </DropdownMenuItem>
                  <DropdownMenuItem onClick={() => onKick(current)}>强制下线</DropdownMenuItem>
                  <DropdownMenuItem onClick={() => onWatermark(current)}>水印设置</DropdownMenuItem>
                  {superviseDeptEnabled && <DropdownMenuItem onClick={() => onSupervise(current)}>管辖部门</DropdownMenuItem>}
                  <DropdownMenuItem onClick={() => onVip(current)}>VIP 设置</DropdownMenuItem>
                  <DropdownMenuItem onClick={() => onPlatformAdmin(current)}>平台管理员</DropdownMenuItem>
                  <DropdownMenuSeparator />
                </>
              )}
              {hasPermission('system:user:delete') && (
                <DropdownMenuItem className="text-destructive" onClick={() => onDelete(current)}>删除用户</DropdownMenuItem>
              )}
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </CardHeader>

      <CardContent className="space-y-4 pt-4">
        <Segmented value={tab} onChange={value => setTab(value as 'basic' | 'permission')} options={TABS.map(t => ({ value: t.value, label: t.label }))} />

        {loading && !detail ? (
          <div className="space-y-2">{Array.from({ length: 8 }).map((_, i) => <Skeleton key={i} className="h-9 w-full" />)}</div>
        ) : tab === 'basic' ? (
          <div className="grid grid-cols-1 gap-x-6 lg:grid-cols-2">
            <dl>
              <DetailRow label="账号">{current.username}</DetailRow>
              <DetailRow label="姓名">{current.realname}</DetailRow>
              <DetailRow label="性别">{current.sex !== undefined ? SEX_LABELS[current.sex] ?? '-' : '-'}</DetailRow>
              <DetailRow label="手机号">{current.phone}</DetailRow>
              <DetailRow label="邮箱">{current.email}</DetailRow>
              <DetailRow label="座机">{current.telephone}</DetailRow>
              <DetailRow label="生日">{current.birthday?.slice(0, 10)}</DetailRow>
              <DetailRow label="职级">{current.level?.levelName}</DetailRow>
              <DetailRow label="水印">{current.watermarkEnabled ? '已开启' : '未开启'}</DetailRow>
            </dl>
            <dl>
              <DetailRow label="角色">{current.roles?.map(role => role.roleName).join('、')}</DetailRow>
              <DetailRow label="部门">{current.depts?.map(dept => dept.departName).join('、')}</DetailRow>
              <DetailRow label="岗位">{current.posts?.map(post => post.postName).join('、')}</DetailRow>
              <DetailRow label="创建时间">{formatDate(current.createTime)}</DetailRow>
              <DetailRow label="更新时间">{formatDate(current.updateTime)}</DetailRow>
              <DetailRow label="在线时长">{onlineDuration}{onlineSession && <span className="text-muted-foreground text-xs">（当前会话）</span>}</DetailRow>
              <DetailRow label="强制改密">{current.mustChangePassword === 1 ? '是' : '否'}</DetailRow>
              <DetailRow label="简介">{current.bio}</DetailRow>
            </dl>
          </div>
        ) : (
          <div className="space-y-4">
            {/* 汇总：三个数字一览，口径与下方明细一致 */}
            <div className="grid grid-cols-3 gap-2">
              <div className="bg-muted/40 rounded-md border px-3 py-2.5 text-center">
                <div className="text-xl font-semibold tabular-nums">{current.roles?.length ?? 0}</div>
                <div className="text-muted-foreground text-xs">角色数量</div>
              </div>
              <div className="bg-muted/40 rounded-md border px-3 py-2.5 text-center">
                <div className="text-xl font-semibold tabular-nums">{grants?.length ?? 0}</div>
                <div className="text-muted-foreground text-xs">个人权限</div>
              </div>
              <div className="bg-muted/40 rounded-md border px-3 py-2.5 text-center">
                <div className="text-xl font-semibold tabular-nums">{dataGrants.length}</div>
                <div className="text-muted-foreground text-xs">数据权限</div>
              </div>
            </div>
            <p className="text-muted-foreground text-xs">
              最终权限 = 角色权限 ∪ 个人权限（只增不减）；数据权限在个人授权上绑定规则，控制"能看到哪些行"。
            </p>

            {/* 角色配置 */}
            <section className="space-y-2">
              <div className="flex flex-wrap items-center justify-between gap-2">
                <h4 className="text-sm font-medium">角色配置</h4>
                {hasPermission('system:user:update') && (
                  <Button size="sm" variant="outline" onClick={openRoleDialog}>分配角色</Button>
                )}
              </div>
              {current.roles?.length ? (
                <div className="flex flex-wrap gap-1.5">
                  {current.roles.map(role => (
                    <span key={role.id} className="bg-secondary rounded-md border px-2 py-1 text-xs">
                      {role.roleName || role.roleCode}
                      {current.roleSources?.[role.id] === 'position' && (
                        <span className="text-muted-foreground ml-1">（岗位带入）</span>
                      )}
                    </span>
                  ))}
                </div>
              ) : (
                <p className="text-muted-foreground rounded-md border border-dashed px-3 py-4 text-center text-xs">暂无角色</p>
              )}
            </section>

            {/* 个人权限：一条授权 = 一个权限点，保留单条增改与理由/到期 */}
            <section className="space-y-2">
              <div className="flex flex-wrap items-center justify-between gap-2">
                <h4 className="text-sm font-medium">个人权限</h4>
                {hasPermission('system:grant:write') && (
                  <Button size="sm" variant="outline" onClick={() => { setEditingGrant(null); setGrantFormOpen(true) }}>新增个人权限</Button>
                )}
              </div>
              {grants === null ? (
                <div className="space-y-2">{Array.from({ length: 3 }).map((_, i) => <Skeleton key={i} className="h-10 w-full" />)}</div>
              ) : grants.length === 0 ? (
                <p className="text-muted-foreground rounded-md border border-dashed px-3 py-4 text-center text-xs">暂无个人授权</p>
              ) : (
                <div className="divide-border rounded-md border divide-y">
                  {grants.map(grant => {
                    const expired = !!grant.expireAt && new Date(grant.expireAt).getTime() < now
                    const inactive = grant.status !== 1 || expired
                    return (
                      <div key={grant.id} className="flex flex-wrap items-center justify-between gap-2 px-3 py-2.5">
                        <div className="min-w-0 flex-1">
                          <div className="flex flex-wrap items-center gap-2">
                            <span className="text-sm font-medium">{menuNameById.get(grant.permissionId) ?? grant.permissionId}</span>
                            <span className={inactive ? 'bg-muted text-muted-foreground rounded px-1.5 py-0.5 text-[10px]' : 'bg-emerald-500/15 rounded px-1.5 py-0.5 text-[10px] text-emerald-600 dark:text-emerald-400'}>
                              {inactive ? '已失效' : '生效中'}
                            </span>
                          </div>
                          <p className="text-muted-foreground mt-0.5 text-xs">
                            到期：{grant.expireAt ? formatDate(grant.expireAt) : '长期'} · 理由：{grant.reason || '-'}
                          </p>
                        </div>
                        {hasPermission('system:grant:write') && (
                          <div className="flex gap-1">
                            <Button variant="ghost" size="sm" onClick={() => { setEditingGrant(grant); setGrantFormOpen(true) }}>编辑</Button>
                            <Button variant="ghost" size="sm" className="text-destructive" onClick={() => removeGrant(grant)}>删除</Button>
                          </div>
                        )}
                      </div>
                    )
                  })}
                </div>
              )}
            </section>

            {/* 数据权限：带 ruleId 的授权；规则定义在「数据规则配置」里维护，这里只读查看 */}
            <section className="space-y-2">
              <div className="flex flex-wrap items-center justify-between gap-2">
                <h4 className="text-sm font-medium">数据权限</h4>
                {hasPermission('system:grant:write') && (
                  <Button size="sm" variant="outline" onClick={() => { setEditingGrant(null); setGrantFormOpen(true) }}>
                    绑定数据规则
                  </Button>
                )}
              </div>
              {grants === null ? (
                <div className="space-y-2">{Array.from({ length: 2 }).map((_, i) => <Skeleton key={i} className="h-10 w-full" />)}</div>
              ) : dataGrants.length === 0 ? (
                <p className="text-muted-foreground rounded-md border border-dashed px-3 py-4 text-center text-xs">暂无数据权限</p>
              ) : (
                <div className="divide-border rounded-md border divide-y">
                  {dataGrants.map(grant => {
                    const expired = !!grant.expireAt && new Date(grant.expireAt).getTime() < now
                    const inactive = grant.status !== 1 || expired
                    return (
                      <div key={grant.id} className="flex flex-wrap items-center justify-between gap-2 px-3 py-2.5">
                        <div className="min-w-0 flex-1">
                          <div className="flex flex-wrap items-center gap-2">
                            <span className="text-sm font-medium">{ruleNameById.get(grant.ruleId!) ?? grant.ruleId}</span>
                            <span className={inactive ? 'bg-muted text-muted-foreground rounded px-1.5 py-0.5 text-[10px]' : 'bg-emerald-500/15 rounded px-1.5 py-0.5 text-[10px] text-emerald-600 dark:text-emerald-400'}>
                              {inactive ? '已失效' : '生效中'}
                            </span>
                          </div>
                          <p className="text-muted-foreground mt-0.5 text-xs">
                            权限点：{menuNameById.get(grant.permissionId) ?? grant.permissionId} · 到期：{grant.expireAt ? formatDate(grant.expireAt) : '长期'}
                          </p>
                        </div>
                        {hasPermission('system:grant:write') && (
                          <div className="flex gap-1">
                            <Button variant="ghost" size="sm" onClick={() => { setEditingGrant(grant); setGrantFormOpen(true) }}>编辑</Button>
                            <Button variant="ghost" size="sm" onClick={() => removeGrant(grant)}>解绑</Button>
                          </div>
                        )}
                      </div>
                    )
                  })}
                </div>
              )}
            </section>

            {grantFormOpen && (
              <GrantFormDialog
                key={editingGrant?.id ?? 'new'}
                open={grantFormOpen}
                onOpenChange={setGrantFormOpen}
                grant={editingGrant}
                prefill={{ type: 'user', id: userId ?? '' }}
                onSubmit={submitGrant}
              />
            )}
          </div>
        )}

        <UserActivityLog user={current} refreshToken={refreshToken} />
      </CardContent>
    </Card>
      {roleDialogOpen && (
        <Dialog open={roleDialogOpen} onOpenChange={setRoleDialogOpen}>
          <DialogContent className="sm:max-w-md">
            <DialogHeader>
              <DialogTitle>分配角色</DialogTitle>
              <DialogDescription>
                保存后该用户的角色将整体替换为所选列表；已选角色决定其菜单与数据范围，权限实时生效。
              </DialogDescription>
            </DialogHeader>
            <div className="max-h-64 space-y-1.5 overflow-y-auto rounded-md border p-2">
              {roles.length === 0 ? (
                <p className="text-muted-foreground py-6 text-center text-sm">暂无可选角色</p>
              ) : (
                roles.map(role => (
                  <label key={role.id} className="hover:bg-accent flex cursor-pointer items-center gap-2 rounded px-1 py-1 text-sm">
                    <input
                      type="checkbox"
                      className="accent-primary"
                      checked={selectedRoleIds.includes(role.id)}
                      onChange={() =>
                        setSelectedRoleIds(prev => (prev.includes(role.id) ? prev.filter(id => id !== role.id) : [...prev, role.id]))
                      }
                    />
                    {role.roleName || role.roleCode}
                    <span className="text-muted-foreground text-xs">{role.roleCode}</span>
                  </label>
                ))
              )}
            </div>
            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => setRoleDialogOpen(false)}>取消</Button>
              <Button type="button" onClick={submitRoles} disabled={savingRoles}>{savingRoles ? '保存中…' : '保存'}</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      )}
    </>
  )
}
