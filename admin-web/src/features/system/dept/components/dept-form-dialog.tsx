import { useMemo, useState } from 'react'
import { AppFormDialog } from '@/components/app-form-dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { cn } from 'cn'
import { useDict } from '@/lib/dict'
import { FieldError, intRange, maxLength, optional, requiredWith, sysCode, useFieldErrors } from '@/lib/form-validation'
import type { Dept, DeptWritePayload } from '../api'

interface DeptFormDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  /** null 表示新增 */
  dept: Dept | null
  /** 新增时预选的上级部门 id，null 为顶级 */
  parentId: string | null
  /** 可选上级部门列表（编辑时已排除自身及后代） */
  depts: Dept[]
  onSubmit: (values: DeptWritePayload) => void
}

interface FormState {
  departName: string
  /** 英文名（非必填） */
  departNameEn: string
  /** 英文简写（非必填） */
  departNameAbbr: string
  /** null 表示顶级部门 */
  parentId: string | null
  /** 空串 = 新建时由后端自动生成 */
  orgCode: string
  orgCategory: string
  departOrder: number
  status: string
  description: string
}

const emptyForm: FormState = {
  departName: '',
  departNameEn: '',
  departNameAbbr: '',
  parentId: null,
  orgCode: '',
  orgCategory: '2',
  departOrder: 0,
  status: '1',
  description: ''
}

/** 单行单选组（原生 radio，横向排布） */
function RadioLine<T extends string>({ value, options, onChange }: { value: T; options: Array<{ value: T; label: string }>; onChange: (v: T) => void }) {
  return (
    <div className="flex h-9 items-center gap-x-5">
      {options.map(opt => (
        <label key={opt.value} className="flex cursor-pointer items-center gap-1.5 text-sm">
          <input type="radio" className="accent-primary size-3.5 cursor-pointer" checked={value === opt.value} onChange={() => onChange(opt.value)} />
          <span>{opt.label}</span>
        </label>
      ))}
    </div>
  )
}

/** 由父组件按 key 控制重挂载，保证打开时表单初始化为对应部门 */
export function DeptFormDialog({ open, onOpenChange, dept, parentId, depts, onSubmit }: DeptFormDialogProps) {
  /** 机构类型走字典 sys_org_category */
  const orgCategoryItems = useDict('sys_org_category', { '1': '公司', '2': '部门', '4': '子公司' })
  const [form, setForm] = useState<FormState>(() =>
    dept
      ? {
          departName: dept.departName,
          departNameEn: dept.departNameEn ?? '',
          departNameAbbr: dept.departNameAbbr ?? '',
          parentId: dept.parentId,
          orgCode: dept.orgCode ?? '',
          orgCategory: dept.orgCategory ?? '2',
          departOrder: dept.departOrder,
          status: dept.status ?? '1',
          description: dept.description ?? ''
        }
      : { ...emptyForm, parentId: parentId ?? null }
  )

  const { errors, runValidation, clearError } = useFieldErrors()

  const set = <K extends keyof FormState>(key: K, value: FormState[K]) => {
    setForm(prev => ({ ...prev, [key]: value }))
    clearError(key as string)
  }

  const deptItems = useMemo(() => ({ none: '无（顶级部门）', ...Object.fromEntries(depts.map(d => [d.id, d.departName])) }), [depts])

  const field = 'space-y-2'

  const handleSubmit = () => {
    if (
      !runValidation(
        {
          departName: [requiredWith('部门名称', maxLength(100, '部门名称'))],
          departNameEn: [optional(maxLength(500, '英文名'))],
          departNameAbbr: [optional(maxLength(500, '英文简写'))],
          orgCode: [optional(sysCode, maxLength(64, '部门编码'))],
          departOrder: [intRange(0, 9999, '排序号')]
        },
        form
      )
    )
      return
    onSubmit({
      departName: form.departName.trim(),
      departNameEn: form.departNameEn.trim() || null,
      departNameAbbr: form.departNameAbbr.trim() || null,
      parentId: form.parentId,
      orgCode: form.orgCode.trim() || null,
      orgCategory: form.orgCategory,
      departOrder: form.departOrder,
      status: form.status,
      description: form.description.trim() || null
    })
  }

  return (
    <AppFormDialog
      open={open}
      onOpenChange={onOpenChange}
      title={dept ? '修改部门' : '新增部门'}
      description={dept ? '更换上级部门会同步更新部门编码；手工改编码会同步刷新挂靠用户' : '部门编码留空由后端按层级自动生成'}
      size="xl"
      contentClassName="max-h-[88vh]"
      formId="dept-form"
      onSubmit={handleSubmit}
    >
      <div className="grid grid-cols-2 gap-x-6 gap-y-4">
        <div className={field}>
          <Label htmlFor="dept-name">
            <span className="text-destructive">*</span> 部门名称
          </Label>
          <Input id="dept-name" value={form.departName} onChange={e => set('departName', e.target.value)} maxLength={100} aria-invalid={!!errors.departName} />
          <FieldError message={errors.departName} />
        </div>
        <div className={field}>
          <Label htmlFor="dept-code">
            <span className="text-destructive">*</span> 部门编码
          </Label>
          <Input
            id="dept-code"
            value={form.orgCode}
            onChange={e => set('orgCode', e.target.value)}
            placeholder={dept ? '' : '留空自动生成，如 A01A02'}
            maxLength={64}
            aria-invalid={!!errors.orgCode}
          />
          <FieldError message={errors.orgCode} />
        </div>

        <div className={field}>
          <Label htmlFor="dept-name-en">英文名（选填）</Label>
          <Input
            id="dept-name-en"
            value={form.departNameEn}
            onChange={e => set('departNameEn', e.target.value)}
            placeholder="如 R&D Department"
            maxLength={500}
            aria-invalid={!!errors.departNameEn}
          />
          <FieldError message={errors.departNameEn} />
        </div>
        <div className={field}>
          <Label htmlFor="dept-name-abbr">英文简写（选填）</Label>
          <Input
            id="dept-name-abbr"
            value={form.departNameAbbr}
            onChange={e => set('departNameAbbr', e.target.value)}
            placeholder="如 RD"
            maxLength={500}
            aria-invalid={!!errors.departNameAbbr}
          />
          <FieldError message={errors.departNameAbbr} />
        </div>

        <div className={field}>
          <Label>上级部门</Label>
          <Select value={form.parentId ?? 'none'} onValueChange={v => set('parentId', v === 'none' ? null : v)} items={deptItems}>
            <SelectTrigger className="w-full">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="none">无（顶级部门）</SelectItem>
              {depts.map(d => (
                <SelectItem key={d.id} value={d.id}>
                  {d.departName}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        <div className={field}>
          <Label>部门类型</Label>
          <Select value={form.orgCategory} onValueChange={v => set('orgCategory', v)} items={orgCategoryItems}>
            <SelectTrigger className="w-full">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {Object.entries(orgCategoryItems).map(([value, label]) => (
                <SelectItem key={value} value={value}>
                  {label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className={field}>
          <Label htmlFor="dept-sort">
            <span className="text-destructive">*</span> 排序号
          </Label>
          <Input
            id="dept-sort"
            type="number"
            min={0}
            value={form.departOrder}
            onChange={e => set('departOrder', Number(e.target.value))}
            aria-invalid={!!errors.departOrder}
          />
          <FieldError message={errors.departOrder} />
        </div>
        <div className={field}>
          <Label>状态</Label>
          <RadioLine
            value={form.status}
            options={[
              { value: '1', label: '启用' },
              { value: '0', label: '停用' }
            ]}
            onChange={v => set('status', v)}
          />
        </div>
      </div>

      <div className={cn(field)}>
        <Label htmlFor="dept-desc">备注</Label>
        <textarea
          id="dept-desc"
          value={form.description}
          onChange={e => set('description', e.target.value)}
          placeholder="请输入备注"
          rows={3}
          className="ring-foreground/10 focus-visible:ring-primary/50 placeholder:text-muted-foreground w-full rounded-md px-3 py-2 text-sm ring-1 outline-none focus-visible:ring-2"
        />
      </div>
    </AppFormDialog>
  )
}
