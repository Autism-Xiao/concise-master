// 用户页左侧部门树：部门节点构造、子树 id 收集与树行渲染
import { Button } from '@/components/ui/button'
import { Building2, ChevronRight, Plus } from 'lucide-react'
import { cn } from 'cn'
import type { Dept } from '@/features/system/dept/api'

export interface DeptNode extends Dept {
  children: DeptNode[]
}

/** 按 parentId 组部门树（接口返回扁平列表，parentId 为 null 为顶级） */
export function buildDeptTree(depts: Dept[]): DeptNode[] {
  const nodes = new Map<string, DeptNode>(depts.map(d => [d.id, { ...d, children: [] }]))
  const roots: DeptNode[] = []
  for (const d of depts) {
    const node = nodes.get(d.id)
    if (!node) continue
    const parent = d.parentId ? nodes.get(d.parentId) : undefined
    if (parent && parent.id !== d.id) parent.children.push(node)
    else roots.push(node)
  }
  const sortRecursive = (list: DeptNode[]) => {
    list.sort((a, b) => a.departOrder - b.departOrder)
    list.forEach(n => sortRecursive(n.children))
  }
  sortRecursive(roots)
  return roots
}

/** 收集部门自身 + 全部子孙部门 id（选中父部门时把子部门的人也查出来，一次 deptIds 并集查询） */
export function collectSubtreeIds(node: DeptNode, acc: string[] = []): string[] {
  acc.push(node.id)
  node.children.forEach(child => collectSubtreeIds(child, acc))
  return acc
}

/** 左侧部门树单行 */
export function DeptTreeRow({
  node,
  depth,
  collapsed,
  selectedId,
  onToggle,
  onSelect,
  onAddUser,
  canAdd
}: {
  node: DeptNode
  depth: number
  collapsed: Set<string>
  selectedId: string | null
  onToggle: (id: string) => void
  onSelect: (dept: Dept) => void
  onAddUser: (deptId: string) => void
  canAdd: boolean
}) {
  const hasChildren = node.children.length > 0
  const isCollapsed = collapsed.has(node.id)
  const selected = selectedId === node.id
  return (
    <div>
      <div
        className={cn('hover:bg-accent group flex cursor-pointer items-center gap-1 rounded-md px-2 py-1.5 text-sm', selected && 'bg-accent font-medium')}
        style={{ paddingInlineStart: depth * 16 + 8 }}
        onClick={() => onSelect(node)}
      >
        {hasChildren ? (
          <button
            type="button"
            className="hover:bg-muted -ms-1 flex size-5 items-center justify-center rounded"
            onClick={e => {
              e.stopPropagation()
              onToggle(node.id)
            }}
            aria-label={isCollapsed ? '展开' : '收起'}
          >
            <ChevronRight className={cn('size-3.5 transition-transform', !isCollapsed && 'rotate-90')} />
          </button>
        ) : (
          <span className="size-5" />
        )}
        <Building2 className="text-muted-foreground size-3.5 shrink-0" />
        <span className="truncate">{node.departName}</span>
        {canAdd && (
          <Button
            variant="ghost"
            size="icon"
            title="在该部门下新增用户"
            aria-label={`在「${node.departName}」下新增用户`}
            className="ms-auto size-6 opacity-0 transition-opacity group-hover:opacity-100"
            onClick={e => {
              e.stopPropagation()
              onAddUser(node.id)
            }}
          >
            <Plus className="size-3.5" />
          </Button>
        )}
      </div>
      {!isCollapsed &&
        hasChildren &&
        node.children.map(child => (
          <DeptTreeRow
            key={child.id}
            node={child}
            depth={depth + 1}
            collapsed={collapsed}
            selectedId={selectedId}
            onToggle={onToggle}
            onSelect={onSelect}
            onAddUser={onAddUser}
            canAdd={canAdd}
          />
        ))}
    </div>
  )
}
