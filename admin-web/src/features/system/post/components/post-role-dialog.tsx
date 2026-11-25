import { toastError } from '@/lib/toast-error'
import { useEffect, useState } from 'react'
import { Loader2 } from 'lucide-react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Skeleton } from '@/components/ui/skeleton'
import { fetchRoleOptions, type Role } from '@/features/system/role/api'
import { assignPositionRoles, fetchPositionRoleIds, type Post } from '../api'

interface PostRoleDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  post: Post
  onSaved: () => void
}

const DATA_SCOPE_LABEL: Record<number, string> = { 1: '全部数据', 2: '本部门及以下', 3: '本部门', 4: '仅本人' }

/**
 * 岗位默认角色配置（岗位 → 角色模板）：
 *
 * 勾选 = 持有该岗位的用户自动获得这些角色（sys_user_role.source='position'）；
 * 手动分配的角色（source='manual'）不受模板影响，调岗/摘岗时只回收岗位来源的绑定。
 * admin 角色后端拒绝配置（租户管理员必须显式分配给具体用户）。
 */
export function PostRoleDialog({ open, onOpenChange, post, onSaved }: PostRoleDialogProps) {
  const [roles, setRoles] = useState<Role[] | null>(null)
  const [selected, setSelected] = useState<string[]>([])
  const [loadError, setLoadError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    if (!open) return
    setRoles(null)
    setSelected([])
    setLoadError(null)
    Promise.all([fetchRoleOptions(), fetchPositionRoleIds(post.id)])
      .then(([roleList, roleIds]) => {
        setRoles(roleList)
        setSelected(roleIds)
      })
      .catch(e => setLoadError(e instanceof Error ? e.message : '加载角色失败'))
  }, [open, post.id])

  const selectedSet = new Set(selected)

  const toggle = (id: string) => setSelected(prev => (prev.includes(id) ? prev.filter(v => v !== id) : [...prev, id]))

  const submit = async (e: React.FormEvent) => {
    e.preventDefault()
    setSubmitting(true)
    try {
      const result = await assignPositionRoles(post.id, selected)
      toast.success(
        result.syncedUsers > 0
          ? `已更新「${post.postName}」的默认角色，${result.syncedUsers} 个持有者的角色已自动同步`
          : `已更新「${post.postName}」的默认角色（当前没有用户持有该岗位）`
      )
      onOpenChange(false)
      onSaved()
    } catch (error) {
      toastError(error, '保存失败')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>岗位默认角色</DialogTitle>
          <DialogDescription>
            岗位：{post.postName}（{post.postCode}）
            <br />
            勾选后，持有该岗位的用户会自动获得所选角色（挂岗即带出、调岗即回收）；用户管理里手动分配的角色不受影响。
          </DialogDescription>
        </DialogHeader>

        <form id="post-role-form" className="space-y-3" onSubmit={submit}>
          {loadError ? (
            <p className="text-destructive text-sm">{loadError}</p>
          ) : !roles ? (
            <div className="space-y-2 py-2">
              <Skeleton className="h-5 w-full" />
              <Skeleton className="h-5 w-4/5" />
              <Skeleton className="h-5 w-3/5" />
            </div>
          ) : roles.length === 0 ? (
            <p className="text-muted-foreground py-2 text-sm">还没有可选角色，请先在「角色管理」里创建。</p>
          ) : (
            <div className="max-h-72 space-y-1 overflow-y-auto rounded-md border p-2">
              {roles.map(role => {
                const scope = role.dataScope ? DATA_SCOPE_LABEL[role.dataScope] : undefined
                return (
                  <label key={role.id} className="hover:bg-accent flex cursor-pointer items-center gap-2 rounded px-1 py-0.5 text-sm">
                    <input type="checkbox" className="accent-primary" checked={selectedSet.has(role.id)} onChange={() => toggle(role.id)} />
                    <span>{role.roleName || role.roleCode}</span>
                    <span className="text-muted-foreground ms-auto text-xs">{[scope, role.roleCode].filter(Boolean).join(' · ')}</span>
                  </label>
                )
              })}
            </div>
          )}
        </form>

        <DialogFooter>
          <Button type="button" variant="outline" onClick={() => onOpenChange(false)} disabled={submitting}>
            取消
          </Button>
          <Button type="submit" form="post-role-form" disabled={submitting || !!loadError || !roles?.length}>
            {submitting && <Loader2 className="size-4 animate-spin" />}
            保存
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
