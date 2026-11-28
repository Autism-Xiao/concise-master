import { useEffect, useMemo, useState } from 'react'
import { AppFormDialog } from '@/components/app-form-dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { fetchMenus, type Menu } from '@/features/system/menu/api'
import { fetchDataRules } from '@/features/system/data-rule/api'
import { FieldError, maxLength, requiredSelect, requiredWith, useFieldErrors } from '@/lib/form-validation'
import { SUBJECT_TYPE_LABELS, type Grant, type GrantSubjectType, type GrantWritePayload } from '../api'
import { SubjectPicker } from './subject-picker'

interface GrantFormDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  /** null 表示新增 */
  grant: Grant | null
  /** 新增时预填的主体（从用户管理等页面跳转过来） */
  prefill?: { type: GrantSubjectType; id: string }
  onSubmit: (values: GrantWritePayload) => void
}

interface FormState {
  subjectType: GrantSubjectType
  subjectId: string
  permissionId: string
  ruleId: string
  /** datetime-local 格式；空表示永久 */
  expireAt: string
  reason: string
}

const emptyForm: FormState = { subjectType: 'user', subjectId: '', permissionId: '', ruleId: '', expireAt: '', reason: '' }

/** ISO 字符串 ↔ datetime-local 输入值 */
function toLocalInput(iso?: string | null): string {
  if (!iso) return ''
  const date = new Date(iso)
  if (Number.isNaN(date.getTime())) return ''
  const offset = date.getTimezoneOffset() * 60_000
  return new Date(date.getTime() - offset).toISOString().slice(0, 16)
}

export function GrantFormDialog({ open, onOpenChange, grant, prefill, onSubmit }: GrantFormDialogProps) {
  const [form, setForm] = useState<FormState>(() =>
    grant
      ? {
          subjectType: grant.subjectType,
          subjectId: grant.subjectId,
          permissionId: grant.permissionId,
          ruleId: grant.ruleId ?? '',
          expireAt: toLocalInput(grant.expireAt),
          reason: grant.reason ?? ''
        }
      : prefill
      ? { ...emptyForm, subjectType: prefill.type, subjectId: prefill.id }
      : emptyForm
  )
  const [menus, setMenus] = useState<Menu[]>([])
  const [rules, setRules] = useState<Array<{ id: string; name: string }>>([])
  const { errors, runValidation, clearError } = useFieldErrors()

  useEffect(() => {
    fetchMenus()
      .then(setMenus)
      .catch(() => setMenus([]))
    fetchDataRules()
      .then(list => setRules(list.filter(rule => rule.status === 1).map(rule => ({ id: rule.id, name: rule.name }))))
      .catch(() => setRules([]))
  }, [])

  const set = <K extends keyof FormState>(key: K, value: FormState[K]) => {
    setForm(prev => ({ ...prev, [key]: value }))
    clearError(key as string)
  }

  /** 可授权节点：菜单(1) + 按钮(2)，目录(0) 不参与授权 */
  const permissionItems = useMemo(
    () =>
      Object.fromEntries(
        menus
          .filter(menu => menu.menuType === 1 || menu.menuType === 2)
          .filter(menu => !!menu.perms || menu.menuType === 1)
          .map(menu => [menu.id, `${menu.name}${menu.perms ? ` · ${menu.perms}` : ''}${menu.menuType === 2 ? '（按钮）' : ''}`])
      ),
    [menus]
  )
  const ruleItems = useMemo(() => ({ none: '不绑定规则', ...Object.fromEntries(rules.map(rule => [rule.id, rule.name])) }), [rules])

  const handleSubmit = () => {
    if (
      !runValidation(
        {
          subjectId: [requiredSelect('主体')],
          permissionId: [requiredSelect('权限点')],
          reason: [requiredWith('授权理由', maxLength(300, '授权理由'))]
        },
        form
      )
    )
      return
    onSubmit({
      subjectType: form.subjectType,
      subjectId: form.subjectId.trim(),
      permissionId: form.permissionId,
      ruleId: form.ruleId || null,
      expireAt: form.expireAt ? new Date(form.expireAt).toISOString() : null,
      reason: form.reason.trim()
    })
  }

  return (
    <AppFormDialog
      open={open}
      onOpenChange={onOpenChange}
      title={grant ? '编辑授权' : '新增授权'}
      description="并集模型：授权只会增加权限，不能回收角色已有的权限；要少给权限请调整角色。"
      size="lg"
      formId="grant-form"
      onSubmit={handleSubmit}
    >
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label>主体类型</Label>
          <Select
            value={form.subjectType}
            onValueChange={value => {
              set('subjectType', value as GrantSubjectType)
              set('subjectId', '')
            }}
            items={SUBJECT_TYPE_LABELS}
            disabled={!!grant}
          >
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {Object.entries(SUBJECT_TYPE_LABELS).map(([value, label]) => (
                <SelectItem key={value} value={value}>
                  {label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <p className="text-muted-foreground text-xs">新建时可选；编辑时主体不可改，请删除后重建。</p>
        </div>
        <div className="space-y-2">
          <Label>主体</Label>
          <SubjectPicker type={form.subjectType} value={form.subjectId} onChange={id => set('subjectId', id)} />
          <FieldError message={errors.subjectId} />
        </div>
      </div>

      <div className="space-y-2">
        <Label>权限点（菜单或按钮）</Label>
        <Select value={form.permissionId || undefined} items={permissionItems} onValueChange={value => set('permissionId', value)} disabled={!!grant}>
          <SelectTrigger>
            <SelectValue placeholder="选择要额外授予的菜单或按钮" />
          </SelectTrigger>
          <SelectContent>
            {Object.entries(permissionItems).map(([id, label]) => (
              <SelectItem key={id} value={id}>
                {label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        <FieldError message={errors.permissionId} />
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label>数据规则（可选）</Label>
          <Select value={form.ruleId || 'none'} items={ruleItems} onValueChange={value => set('ruleId', value === 'none' ? '' : value)}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="none">不绑定规则</SelectItem>
              {rules.map(rule => (
                <SelectItem key={rule.id} value={rule.id}>
                  {rule.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <p className="text-muted-foreground text-xs">控制"能看到哪些行"；不绑则只给菜单/按钮，行范围回退角色 data_scope。</p>
        </div>
        <div className="space-y-2">
          <Label>过期时间（留空 = 长期）</Label>
          <Input type="datetime-local" value={form.expireAt} onChange={e => set('expireAt', e.target.value)} />
          <p className="text-muted-foreground text-xs">临时授权请务必填写，到期自动失效。</p>
        </div>
      </div>

      <div className="space-y-2">
        <Label htmlFor="grant-reason">授权理由</Label>
        <Input
          id="grant-reason"
          value={form.reason}
          onChange={e => set('reason', e.target.value)}
          placeholder="如：[跨部门协作] 小张查看订单，仅本周核对用"
          maxLength={300}
          aria-invalid={!!errors.reason}
        />
        <FieldError message={errors.reason} />
      </div>
    </AppFormDialog>
  )
}
