import { useState } from 'react'
import { AppFormDialog } from '@/components/app-form-dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { FieldError, intRange, requiredWith, maxLength, useFieldErrors } from '@/lib/form-validation'
import type { DataRule, DataRuleWritePayload } from '../api'

interface DataRuleFormDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  /** null 表示新增 */
  rule: DataRule | null
  onSubmit: (values: DataRuleWritePayload) => void
}

interface FormState {
  name: string
  resource: string
  action: string
  ruleField: string
  ruleOperator: string
  ruleValue: string
  ruleEffect: string
  priority: number
}

const emptyForm: FormState = {
  name: '',
  resource: 'biz_order',
  action: 'all',
  ruleField: '',
  ruleOperator: 'eq',
  ruleValue: '',
  ruleEffect: 'allow',
  priority: 100
}

const RESOURCE_ITEMS: Record<string, string> = { biz_order: '订单', customer: '客户', supplier: '供应商' }
const ACTION_ITEMS: Record<string, string> = { all: '读写通用', read: '仅查询', write: '仅新增/修改', delete: '仅删除' }
const OPERATOR_ITEMS: Record<string, string> = {
  eq: '等于',
  ne: '不等于',
  gt: '大于',
  gte: '大于等于',
  lt: '小于',
  lte: '小于等于',
  in: '属于列表',
  not_in: '不属于列表',
  like: '包含',
  self: '是本人（归属列）',
  dept: '属本人部门（归属列）'
}
const EFFECT_ITEMS: Record<string, string> = { allow: '允许（可见）', deny: '拒绝（排除）' }

export function DataRuleFormDialog({ open, onOpenChange, rule, onSubmit }: DataRuleFormDialogProps) {
  const [form, setForm] = useState<FormState>(() =>
    rule
      ? {
          name: rule.name,
          resource: rule.resource,
          action: rule.action,
          ruleField: rule.ruleField,
          ruleOperator: rule.ruleOperator,
          ruleValue: rule.ruleValue ?? '',
          ruleEffect: rule.ruleEffect,
          priority: rule.priority
        }
      : emptyForm
  )
  const { errors, runValidation, clearError } = useFieldErrors()

  const set = <K extends keyof FormState>(key: K, value: FormState[K]) => {
    setForm(prev => ({ ...prev, [key]: value }))
    clearError(key as string)
  }

  const needsValue = !['self', 'dept'].includes(form.ruleOperator)

  const handleSubmit = () => {
    const rules = {
      name: [requiredWith('规则名称', maxLength(100, '规则名称'))],
      resource: [requiredWith('资源')],
      ruleField: [requiredWith('过滤字段')],
      priority: [intRange(0, 9999, '优先级')],
      ...(needsValue && !['in', 'not_in', 'like'].includes(form.ruleOperator) ? {} : {})
    }
    if (!runValidation(rules, form)) return
    onSubmit({
      name: form.name.trim(),
      resource: form.resource.trim(),
      action: form.action,
      ruleField: form.ruleField.trim(),
      ruleOperator: form.ruleOperator,
      ruleValue: form.ruleValue.trim() || null,
      ruleEffect: form.ruleEffect,
      priority: form.priority
    })
  }

  return (
    <AppFormDialog
      open={open}
      onOpenChange={onOpenChange}
      title={rule ? '编辑数据规则' : '新增数据规则'}
      description="规则只控制「能看到哪些行」，不改变菜单与按钮；精确 action 规则优先于 all 通用规则。"
      size="lg"
      formId="data-rule-form"
      onSubmit={handleSubmit}
    >
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label htmlFor="rule-name">规则名称</Label>
          <Input
            id="rule-name"
            value={form.name}
            onChange={e => set('name', e.target.value)}
            placeholder="如：订单_读_全部"
            maxLength={100}
            aria-invalid={!!errors.name}
          />
          <FieldError message={errors.name} />
        </div>
        <div className="space-y-2">
          <Label>资源</Label>
          <Select value={form.resource || undefined} items={RESOURCE_ITEMS} onValueChange={value => set('resource', value)}>
            <SelectTrigger>
              <SelectValue placeholder="选择资源" />
            </SelectTrigger>
            <SelectContent>
              {Object.entries(RESOURCE_ITEMS).map(([value, label]) => (
                <SelectItem key={value} value={value}>
                  {label}（{value}）
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <FieldError message={errors.resource} />
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label>作用动作</Label>
          <Select value={form.action} items={ACTION_ITEMS} onValueChange={value => set('action', value)}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {Object.entries(ACTION_ITEMS).map(([value, label]) => (
                <SelectItem key={value} value={value}>
                  {label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <p className="text-muted-foreground text-xs">「看全部、只改自己」配两条：read 全量 + write self。</p>
        </div>
        <div className="space-y-2">
          <Label>效果</Label>
          <Select value={form.ruleEffect} items={EFFECT_ITEMS} onValueChange={value => set('ruleEffect', value)}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {Object.entries(EFFECT_ITEMS).map(([value, label]) => (
                <SelectItem key={value} value={value}>
                  {label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label htmlFor="rule-field">过滤字段（实体属性名）</Label>
          <Input
            id="rule-field"
            value={form.ruleField}
            onChange={e => set('ruleField', e.target.value)}
            placeholder="如 id / createBy / amount"
            aria-invalid={!!errors.ruleField}
          />
          <p className="text-muted-foreground text-xs">必须是实体属性名；self / dept 会自动落到归属列 createBy。</p>
          <FieldError message={errors.ruleField} />
        </div>
        <div className="space-y-2">
          <Label>运算符</Label>
          <Select value={form.ruleOperator} items={OPERATOR_ITEMS} onValueChange={value => set('ruleOperator', value)}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {Object.entries(OPERATOR_ITEMS).map(([value, label]) => (
                <SelectItem key={value} value={value}>
                  {label}（{value}）
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label htmlFor="rule-value">规则值</Label>
          <Input
            id="rule-value"
            value={form.ruleValue}
            onChange={e => set('ruleValue', e.target.value)}
            placeholder={needsValue ? '如 100 / a,b,c / $user.id' : 'self / dept 无需填写'}
            disabled={!needsValue}
          />
          <p className="text-muted-foreground text-xs">支持 $user.id、$user.deptIds；in / not_in 用逗号分隔。</p>
        </div>
        <div className="space-y-2">
          <Label htmlFor="rule-priority">优先级（越小越先）</Label>
          <Input
            id="rule-priority"
            type="number"
            min={0}
            max={9999}
            value={form.priority}
            onChange={e => set('priority', Number(e.target.value) || 0)}
            aria-invalid={!!errors.priority}
          />
          <FieldError message={errors.priority} />
        </div>
      </div>
    </AppFormDialog>
  )
}
