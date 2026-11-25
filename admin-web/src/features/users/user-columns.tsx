import { toastError } from '@/lib/toast-error'
// 用户表格列定义与视图选项标签，供 UsersPage 通过 buildUserColumns 注入回调使用
import type { ColumnDef } from '@tanstack/react-table'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuSeparator, DropdownMenuTrigger } from '@/components/ui/dropdown-menu'
import { StatusBadge } from '@/components/status-badge'
import { DataTableColumnHeader, selectColumn } from '@/components/data-table'
import { getUsername, hasPermission } from '@/lib/auth'
import { withOperationLog } from '@/features/system/log/api'
import {
  BadgeCheck,
  Droplets,
  FileClock,
  KeyRound,
  LogOut,
  MoreHorizontal,
  Network,
  Pencil,
  RefreshCcw,
  ShieldBan,
  ShieldCheck,
  Trash2,
  Unlock,
  UserCog
} from 'lucide-react'
import { clearUserPermissionCache, resetUserAvatar, userStatusMap, type User } from './api'

export const columnLabels: Record<string, string> = {
  username: '账号',
  realname: '姓名',
  email: '邮箱',
  phone: '手机号',
  status: '状态',
  roleNames: '角色',
  postNames: '岗位',
  watermark: '水印',
  createTime: '创建时间'
}
export interface UserColumnsActions {
  openEdit: (user: User) => void
  onResetPassword: (user: User) => void
  onUnlock: (user: User) => void
  onPlatformAdmin: (user: User) => void
  onReload: () => void
  setWatermarkTarget: (user: User | null) => void
  setStatusTarget: (target: { user: User; next: 1 | 2 } | null) => void
  setKickTarget: (user: User | null) => void
  setLogTarget: (user: User | null) => void
  setSuperviseTarget: (user: User | null) => void
  setVipTarget: (user: User | null) => void
  setDeleting: (user: User | null) => void
  superviseDeptEnabled: boolean
}

export function buildUserColumns(actions: UserColumnsActions): ColumnDef<User>[] {
  return [
    selectColumn<User>(u => u.realname || u.username),
    {
      accessorKey: 'username',
      header: ({ column }) => <DataTableColumnHeader column={column} title="账号" />,
      cell: ({ row }) => (
        // 用内联徽标而不是单开一列：平台管理员通常只有一两个，加列会把表格再挤宽 80px
        <span className="flex items-center gap-1.5 font-medium whitespace-nowrap">
          {row.getValue('username')}
          {Number(row.original.isPlatformAdmin) === 1 && (
            <span
              className="inline-flex rounded-full bg-amber-100 px-1.5 py-0.5 text-[10px] leading-none font-medium text-amber-700 dark:bg-amber-950 dark:text-amber-300"
              title="平台管理员：可跨租户视角、可访问平台级功能"
            >
              平台
            </span>
          )}
          {Number(row.original.vipLevel) === 1 && (
            <span
              className="inline-flex rounded-full bg-violet-100 px-1.5 py-0.5 text-[10px] leading-none font-medium text-violet-700 dark:bg-violet-950 dark:text-violet-300"
              title="VIP：可自助开通团队（租户）"
            >
              VIP
            </span>
          )}
        </span>
      )
    },
    {
      accessorKey: 'realname',
      header: ({ column }) => <DataTableColumnHeader column={column} title="姓名" />,
      cell: ({ row }) => row.getValue('realname') || '-'
    },
    {
      accessorKey: 'email',
      header: ({ column }) => <DataTableColumnHeader column={column} title="邮箱" />,
      cell: ({ row }) => row.getValue('email') || '-'
    },
    {
      accessorKey: 'phone',
      header: '手机号',
      enableSorting: false,
      cell: ({ row }) => row.getValue('phone') || '-'
    },
    {
      accessorKey: 'status',
      header: ({ column }) => <DataTableColumnHeader column={column} title="状态" />,
      cell: ({ row }) => {
        const status = row.getValue<number>('status')
        const meta = userStatusMap[status] ?? { label: String(status) }
        return <StatusBadge ok={status === 1} label={meta.label} />
      },
      filterFn: (row, id, value) => String(row.getValue(id)) === String(value)
    },
    {
      id: 'roleNames',
      accessorFn: row => (row.roles ?? []).map(r => r.roleName).join('、'),
      header: ({ column }) => <DataTableColumnHeader column={column} title="角色" />,
      cell: ({ row }) => row.getValue('roleNames') || '-'
    },
    {
      id: 'levelName',
      accessorFn: row => row.level?.levelName ?? '',
      header: ({ column }) => <DataTableColumnHeader column={column} title="职级" />,
      cell: ({ row }) => row.getValue('levelName') || '-'
    },
    {
      id: 'postNames',
      accessorFn: row => (row.posts ?? []).map(p => p.postName || p.postCode).join('、'),
      header: ({ column }) => <DataTableColumnHeader column={column} title="岗位" />,
      cell: ({ row }) => row.getValue('postNames') || '-'
    },
    {
      id: 'deptNames',
      accessorFn: row => (row.depts ?? []).map(d => d.departName).join('、'),
      header: ({ column }) => <DataTableColumnHeader column={column} title="部门" />,
      cell: ({ row }) => row.getValue('deptNames') || '-'
    },
    {
      id: 'watermark',
      accessorFn: row => (row.watermarkEffective ? '已开启' : '已关闭'),
      header: ({ column }) => <DataTableColumnHeader column={column} title="水印" />,
      cell: ({ row }) => {
        const user = row.original
        const enforcedLabel = user.watermarkEnforced === 1 ? '（强制开）' : user.watermarkEnforced === 2 ? '（强制关）' : ''
        const effective = user.watermarkEffective === true
        return <StatusBadge ok={effective} label={`${effective ? '已开启' : '已关闭'}${enforcedLabel}`} />
      }
    },
    {
      accessorKey: 'createTime',
      header: ({ column }) => <DataTableColumnHeader column={column} title="创建时间" />,
      cell: ({ row }) => (row.getValue('createTime') as string)?.replace('T', ' ').slice(0, 19) || '-'
    },
    {
      id: 'actions',
      header: () => <div className="text-end">操作</div>,
      enableSorting: false,
      enableHiding: false,
      cell: ({ row }) => {
        const user = row.original
        const frozen = user.status === 2
        return (
          <div className="flex items-center justify-end">
            {hasPermission('system:user:update') && (
              <Button variant="ghost" size="icon" onClick={() => actions.openEdit(user)}>
                <Pencil className="size-4" />
                <span className="sr-only">编辑</span>
              </Button>
            )}
            {hasPermission('system:user:update') && (
              <Button variant="ghost" size="icon" onClick={() => actions.setWatermarkTarget(user)} title="水印设置">
                <Droplets className="size-4" />
                <span className="sr-only">水印设置</span>
              </Button>
            )}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" size="icon" title="更多操作">
                  <MoreHorizontal className="size-4" />
                  <span className="sr-only">更多操作</span>
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-44">
                {hasPermission('system:user:reset-password') && (
                  <DropdownMenuItem onClick={() => actions.onResetPassword(user)}>
                    <KeyRound className="size-4" />
                    重置密码
                  </DropdownMenuItem>
                )}
                {hasPermission('system:user:update') && (
                  <DropdownMenuItem onClick={() => actions.setStatusTarget({ user, next: frozen ? 1 : 2 })}>
                    {frozen ? <ShieldCheck className="size-4" /> : <ShieldBan className="size-4" />}
                    {frozen ? '解冻' : '冻结'}
                  </DropdownMenuItem>
                )}
                {hasPermission('system:online:kick') && (
                  <DropdownMenuItem onClick={() => actions.setKickTarget(user)}>
                    <LogOut className="size-4" />
                    强制下线
                  </DropdownMenuItem>
                )}
                {hasPermission('system:user:update') && (
                  <DropdownMenuItem onClick={() => actions.onUnlock(user)}>
                    <Unlock className="size-4" />
                    解锁登录
                  </DropdownMenuItem>
                )}
                {hasPermission('system:user:update') && (
                  <DropdownMenuItem
                    onClick={() =>
                      withOperationLog(`清除用户「${user.realname || user.username}」的权限缓存`, () => clearUserPermissionCache(user.id))
                        .then(result => toast.success(`已清除 ${result.cleared} 个角色的权限缓存，下次操作即生效`))
                        .catch(e => toastError(e, '清除失败'))
                    }
                  >
                    <RefreshCcw className="size-4" />
                    清除权限缓存
                  </DropdownMenuItem>
                )}
                {hasPermission('system:user:update') && (
                  <DropdownMenuItem
                    onClick={() =>
                      withOperationLog(`重置用户「${user.realname || user.username}」的头像`, () => resetUserAvatar(user.id))
                        .then(() => toast.success('头像已重置为系统默认'))
                        .catch(e => toastError(e, '重置失败'))
                        .finally(() => actions.onReload())
                    }
                  >
                    <UserCog className="size-4" />
                    重置头像
                  </DropdownMenuItem>
                )}
                {hasPermission('system:log:login') && (
                  <DropdownMenuItem onClick={() => actions.setLogTarget(user)}>
                    <FileClock className="size-4" />
                    登录日志
                  </DropdownMenuItem>
                )}
                {/* 管辖部门（ReBAC 监管数据权限）：data_scope 部门档的用户额外可见所选部门的数据；
                      特性开关 rbac.superviseDept 关闭的租户直接隐藏入口（后端 FeatureGuard 同步拦截） */}
                {hasPermission('system:user:update') && actions.superviseDeptEnabled && (
                  <DropdownMenuItem onClick={() => actions.setSuperviseTarget(user)}>
                    <Network className="size-4" />
                    管辖部门
                  </DropdownMenuItem>
                )}
                {/* 平台级操作：权限点 scope=platform，后端还会拒绝取消自己/最后一个，所以自己那一行不显示 */}
                {hasPermission('system:user:platform') && user.username !== getUsername() && (
                  <>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem onClick={() => actions.onPlatformAdmin(user)}>
                      <ShieldCheck className="size-4" />
                      {Number(user.isPlatformAdmin) === 1 ? '取消平台管理员' : '设为平台管理员'}
                    </DropdownMenuItem>
                  </>
                )}
                {/* VIP 同样是平台级操作：决定该账号能否自助开通团队，租户管理员无权发放 */}
                {hasPermission('system:user:vip') && (
                  <DropdownMenuItem onClick={() => actions.setVipTarget(user)}>
                    <BadgeCheck className="size-4" />
                    {Number(user.vipLevel) === 1 ? '调整 VIP' : '开通 VIP'}
                  </DropdownMenuItem>
                )}
                {hasPermission('system:user:delete') && (
                  <>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem variant="destructive" onClick={() => actions.setDeleting(user)}>
                      <Trash2 className="size-4" />
                      删除
                    </DropdownMenuItem>
                  </>
                )}
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        )
      }
    }
  ]
}
