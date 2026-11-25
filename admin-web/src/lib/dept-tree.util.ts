// 部门/菜单等扁平列表的共享树工具：由 parentId 组树、收集子树 id、统一时间文案
/** 带子节点的树节点，保留原实体的全部字段 */
export type TreeNode<T> = T & { children: TreeNode<T>[] }

interface ParentIdItem {
  id: string
  parentId?: string | null
}

/** 由 parentId 组树；同级排序规则由调用方给出（部门按 departOrder，菜单按 sortNo） */
export function buildTree<T extends ParentIdItem>(items: T[], compare: (a: T, b: T) => number): TreeNode<T>[] {
  const nodes = new Map<string, TreeNode<T>>(items.map(item => [item.id, { ...item, children: [] }]))
  const roots: TreeNode<T>[] = []
  for (const item of items) {
    const node = nodes.get(item.id)
    if (!node) continue
    const parent = item.parentId ? nodes.get(item.parentId) : undefined
    if (parent && parent.id !== item.id) parent.children.push(node)
    else roots.push(node)
  }
  const sortRecursive = (list: TreeNode<T>[]) => {
    list.sort(compare)
    list.forEach(n => sortRecursive(n.children))
  }
  sortRecursive(roots)
  return roots
}

/** 收集某节点及其全部后代的 id（含自身，按扁平列表逐轮扩散） */
export function collectSubtreeIds(id: string, items: ParentIdItem[]): Set<string> {
  const ids = new Set<string>([id])
  let changed = true
  while (changed) {
    changed = false
    for (const d of items) {
      if (d.parentId != null && ids.has(d.parentId) && !ids.has(d.id)) {
        ids.add(d.id)
        changed = true
      }
    }
  }
  return ids
}

export function formatDateTime(value?: string | null): string {
  if (!value) return '-'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return '-'
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
}
