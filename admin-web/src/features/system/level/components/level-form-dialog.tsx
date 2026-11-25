import { useState } from 'react'
import { AppFormDialog } from '@/components/app-form-dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { FieldError, intRange, maxLength, requiredWith, useFieldErrors } from '@/lib/form-validation'
import type { Level, LevelWritePayload } from '../api'

interface LevelFormDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  /** null 表示新增 */
  level: Level | null
  onSubmit: (values: LevelWritePayload) => void
}

interface FormState {
  levelName: string
  levelRank: number
  status: string
  remark: string
}

const emptyForm: FormState = { levelName: '', levelRank: 1, status: '1', remark: '' }

/** 由父组件按 key 控制重挂载，保证打开时表单初始化为对应职级 */
export function LevelFormDialog({ open, onOpenChange, level, onSubmit }: LevelFormDialogProps) {
  const [form, setForm] = useState<FormState>(() =>
    level ? { levelName: level.levelName, levelRank: level.levelRank, status: level.status, remark: level.remark ?? '' } : emptyForm
  )

  const { errors, runValidation, clearError } = useFieldErrors()

  const set = <K extends keyof FormState>(key: K, value: FormState[K]) => {
    setForm(prev => ({ ...prev, [key]: value }))
    clearError(key as string)
  }

  const handleSubmit = () => {
    if (
      !runValidation(
        {
          levelName: [requiredWith('职级名称', maxLength(100, '职级名称'))],
          levelRank: [intRange(1, 9999, '等级排序')]
        },
        form
      )
    )
      return
    onSubmit({ levelName: form.levelName.trim(), levelRank: form.levelRank, status: form.status, remark: form.remark.trim() || null })
  }

  return (
    <AppFormDialog
      open={open}
      onOpenChange={onOpenChange}
      title={level ? '编辑职级' : '新增职级'}
      description={level ? '修改职级信息后保存' : '填写信息创建新职级'}
      formId="level-form"
      onSubmit={handleSubmit}
    >
      <div className="space-y-2">
        <Label htmlFor="level-name">职级名称</Label>
        <Input
          id="level-name"
          value={form.levelName}
          onChange={e => set('levelName', e.target.value)}
          placeholder="如 P6 / M1"
          maxLength={100}
          aria-invalid={!!errors.levelName}
        />
        <FieldError message={errors.levelName} />
      </div>
      <div className="space-y-2">
        <Label htmlFor="level-rank">等级排序（数字越大级别越高）</Label>
        <Input
          id="level-rank"
          type="number"
          min={1}
          value={form.levelRank}
          onChange={e => set('levelRank', Number(e.target.value) || 1)}
          aria-invalid={!!errors.levelRank}
        />
        <FieldError message={errors.levelRank} />
      </div>
      <div className="space-y-2">
        <Label>状态</Label>
        <Select value={form.status} onValueChange={v => set('status', v)} items={{ 1: '正常', 0: '停用' }}>
          <SelectTrigger>
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="1">正常</SelectItem>
            <SelectItem value="0">停用</SelectItem>
          </SelectContent>
        </Select>
      </div>
      <div className="space-y-2">
        <Label htmlFor="level-remark">备注</Label>
        <Input id="level-remark" value={form.remark} onChange={e => set('remark', e.target.value)} />
      </div>
    </AppFormDialog>
  )
}
