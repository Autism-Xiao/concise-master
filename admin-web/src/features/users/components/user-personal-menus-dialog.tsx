import { useEffect, useMemo, useState } from 'react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Skeleton } from '@/components/ui/skeleton'
import { hasPermission } from '@/lib/auth'
import { fetchGrants, type Grant } from '@/features/system/grant/api'
import { fetchMenus, type Menu } from '@/features/system/menu/api'
import type { User } from '../api'

interface UserPersonalMenusDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  user: User
}

interface MenuMap {
  [id: string]: string
}

/** 只算「有效」授权：状态启用 + 未过期；deny 行不参与放行 */
function isActive(grant: Grant): boolean {
  if (grant.status !== 1) return false
  if (grant.ruleEffect === 'deny') return false
  if (grant.expireAt && new Date(grant.expireAt).getTime() <= Date.now()) return false
  return true
}

/**
 * 用户个人菜单（例外授权）只读视图：
 * 展示该用户通过 sys_grant 单独拿到的菜单/按钮节点，并给出「已失效」行便于排查。
 * 不在这里编辑——配置统一走授权管理页，避免两套写入口。
 */
export function UserPersonalMenusDialog({ open, onOpenChange, user }: UserPersonalMenusDialogProps) {
  const [grants, setGrants] = useState<Grant[] | null>(null)
  const [menuNames, setMenuNames] = useState<MenuMap>({})
  const [loadError, setLoadError] = useState<string | null>(null)

  useEffect(() => {
    if (!open) return
    setGrants(null)
    setLoadError(null)
    Promise.all([
      fetchGrants({ subjectType: 'user', subjectId: user.id }),
      fetchMenus().catch(() => [] as Menu[])
    ])
      .then(([rows, menus]) => {
        setGrants(rows)
        setMenuNames(Object.fromEntries(menus.map(menu => [menu.id, menu.name])))
      })
      .catch(e => setLoadError(e instanceof Error ? e.message : '加载失败'))
  }, [open, user.id])

  const { active, inactive } = useMemo(() => {
    if (!grants) return { active: [] as Grant[], inactive: [] as Grant[] }
    return {
      active: grants.filter(isActive),
      inactive: grants.filter(grant => !isActive(grant))
    }
  }, [grants])

  const menuLabel = (grant: Grant) => menuNames[grant.permissionId] ?? grant.permissionId

  const goConfig = () => {
    onOpenChange(false)
    toast.info('请在右侧用户详情的「个人权限」页签中配置')
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>个人菜单 · {user.realname || user.username}</DialogTitle>
          <DialogDescription>
            账号 {user.username} 的例外授权（个人权限）。最终菜单 = 角色菜单 ∪ 个人授权；个人授权只增不减，无法回收角色已有的菜单。
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-3">
          {loadError ? (
            <p className="text-destructive text-sm">{loadError}</p>
          ) : !grants ? (
            <div className="space-y-2 py-2">
              <Skeleton className="h-6 w-full" />
              <Skeleton className="h-6 w-4/5" />
            </div>
          ) : (
            <>
              <div>
                <p className="text-muted-foreground mb-2 text-xs">生效中（{active.length}）</p>
                {active.length === 0 ? (
                  <p className="text-muted-foreground rounded-md border border-dashed px-3 py-4 text-center text-sm">暂无个人菜单授权</p>
                ) : (
                  <div className="max-h-64 space-y-1.5 overflow-y-auto rounded-md border p-2">
                    {active.map(grant => (
                      <div key={grant.id} className="bg-muted/40 flex items-center justify-between gap-3 rounded px-2 py-1.5 text-sm">
                        <span className="truncate font-medium">{menuLabel(grant)}</span>
                        <span className="text-muted-foreground shrink-0 text-xs">
                          {grant.expireAt ? `${grant.expireAt.replace('T', ' ').slice(0, 16)} 到期` : '长期'}
                        </span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
              {inactive.length > 0 && (
                <div>
                  <p className="text-muted-foreground mb-2 text-xs">已失效（{inactive.length}，不参与生效）</p>
                  <div className="max-h-32 space-y-1 overflow-y-auto rounded-md border border-dashed p-2">
                    {inactive.map(grant => (
                      <div key={grant.id} className="text-muted-foreground flex items-center justify-between gap-3 px-1 text-xs">
                        <span className="truncate">{menuLabel(grant)}</span>
                        <span>{grant.status !== 1 ? '已停用' : grant.ruleEffect === 'deny' ? 'deny' : '已过期'}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </>
          )}
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>关闭</Button>
          {hasPermission('system:grant:write') && (
            <Button onClick={goConfig}>去个人权限配置</Button>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
