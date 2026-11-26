import { useEffect, useState } from 'react'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { fetchDepts } from '@/features/system/dept/api'
import { fetchPosts } from '@/features/system/post/api'
import { fetchRoleOptions } from '@/features/system/role/api'
import { UserMultiSelect } from '@/features/users/components/user-multi-select'
import type { GrantSubjectType } from '../api'

/**
 * 授权主体选择器：按主体类型切换控件。
 * user 用可搜索的单选用户控件，其余用下拉（数据在弹窗打开时加载一次）。
 */
export function SubjectPicker({
  type,
  value,
  onChange
}: {
  type: GrantSubjectType
  value: string
  onChange: (id: string) => void
}) {
  const [options, setOptions] = useState<Array<{ id: string; label: string }>>([])

  useEffect(() => {
    if (type === 'user') return
    let alive = true
    const load =
      type === 'role'
        ? fetchRoleOptions().then(list => list.map(r => ({ id: r.id, label: r.roleName || r.roleCode })))
        : type === 'dept'
          ? fetchDepts().then(list => list.map(d => ({ id: d.id, label: d.departName })))
          : fetchPosts().then(list => list.map(p => ({ id: p.id, label: p.postName || p.postCode })))
    load
      .then(list => alive && setOptions(list))
      .catch(() => alive && setOptions([]))
    return () => {
      alive = false
    }
  }, [type])

  if (type === 'user') {
    return (
      <UserMultiSelect
        single
        value={value ? [value] : []}
        onChange={ids => onChange(ids[0] ?? '')}
        placeholder="搜索账号或姓名"
      />
    )
  }

  const items = Object.fromEntries(options.map(option => [option.id, option.label]))
  return (
    <Select value={value || undefined} items={items} onValueChange={onChange}>
      <SelectTrigger className="w-full">
        <SelectValue placeholder={`请选择${type === 'role' ? '角色' : type === 'dept' ? '部门' : '岗位'}`} />
      </SelectTrigger>
      <SelectContent>
        {options.map(option => (
          <SelectItem key={option.id} value={option.id}>
            {option.label}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  )
}
