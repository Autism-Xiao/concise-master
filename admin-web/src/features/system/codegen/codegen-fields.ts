// 代码生成器字段草稿：枚举解析、默认值校验与接口载荷组装（无 React 依赖）
import type { CodegenFieldType, CodegenSpecPayload } from './api'

/** 表单里的字段草稿：enum 用一行文本编辑（1:启用|0:停用），提交时再解析成数组 */
export interface FieldDraft {
  key: string
  name: string
  comment: string
  type: CodegenFieldType
  required: boolean
  unique: boolean
  query: boolean
  search: boolean
  default: string
  enumText: string
}

let seed = 0
export const nextFieldKey = (): string => `f${++seed}`
export const newField = (patch: Partial<FieldDraft> = {}): FieldDraft => ({
  key: nextFieldKey(),
  name: '',
  comment: '',
  type: 'string',
  required: false,
  unique: false,
  query: false,
  search: false,
  default: '',
  enumText: '',
  ...patch
})

export const DEMO_FIELDS: FieldDraft[] = [
  newField({ name: 'title', comment: '标题', required: true, search: true }),
  newField({ name: 'status', comment: '状态', type: 'enum', query: true, default: '1', enumText: '1:启用|0:停用' }),
  newField({ name: 'amount', comment: '金额', type: 'decimal' }),
  newField({ name: 'signed_at', comment: '签约时间', type: 'datetime' }),
  newField({ name: 'remark', comment: '备注', type: 'text' })
]

/** 枚举文本 → 结构化值，顺带把格式错误暴露给用户 */
export function parseEnumText(text: string): { values: Array<{ value: number; label: string }>; error?: string } {
  const values: Array<{ value: number; label: string }> = []
  for (const piece of text.split('|')) {
    const raw = piece.trim()
    if (!raw) continue
    const [value, label] = raw.split(':')
    if (value === undefined || label === undefined || !/^-?\d+$/.test(value.trim()) || !label.trim()) {
      return { values, error: `枚举项「${raw}」不合法，应为 值:标签（如 1:启用）` }
    }
    values.push({ value: Number(value.trim()), label: label.trim() })
  }
  if (values.length === 0) return { values, error: '枚举字段至少要有一个值，如 1:启用|0:停用' }
  return { values }
}

/** 把草稿整理成接口载荷；返回第一条校验错误（无错则 error 为空） */
export function buildPayload(
  form: {
    module: string
    label: string
    perms: string
    table: string
    menuParent: string
    sort: string
    icon: string
    audit: boolean
  },
  fields: FieldDraft[]
): { payload: CodegenSpecPayload | null; error?: string } {
  if (!/^[a-z][a-z0-9_]{1,31}$/.test(form.module)) return { payload: null, error: '模块标识须为小写蛇形（2~32 位，如 biz_order）' }
  if (!form.label.trim()) return { payload: null, error: '模块名称不能为空' }
  if (fields.length === 0) return { payload: null, error: '至少定义 1 个业务字段' }
  const names = new Set<string>()
  const out: CodegenFieldPayloadLite[] = []
  for (const field of fields) {
    if (!/^[a-z][a-z0-9_]{0,31}$/.test(field.name)) {
      return { payload: null, error: `字段名「${field.name || '空'}」须为小写蛇形（≤32 位）` }
    }
    if (names.has(field.name)) return { payload: null, error: `字段名「${field.name}」重复` }
    names.add(field.name)
    const item: CodegenFieldPayloadLite = {
      name: field.name,
      type: field.type,
      comment: field.comment.trim() || field.name,
      required: field.required,
      unique: field.unique,
      query: field.query,
      search: field.search
    }
    if (field.default.trim()) item.default = field.default.trim()
    if (field.type === 'enum') {
      const parsed = parseEnumText(field.enumText)
      if (parsed.error) return { payload: null, error: `字段「${field.name}」：${parsed.error}` }
      item.enumValues = parsed.values
      if (item.default && !parsed.values.some(value => String(value.value) === item.default)) {
        return { payload: null, error: `字段「${field.name}」默认值 ${item.default} 不在枚举项里` }
      }
    }
    out.push(item)
  }
  return {
    payload: {
      module: form.module,
      label: form.label.trim(),
      perms: form.perms.trim() || undefined,
      table: form.table.trim() || undefined,
      menuParent: form.menuParent,
      sort: Number(form.sort) || 50,
      icon: form.icon,
      audit: form.audit,
      fields: out
    }
  }
}

export type CodegenFieldPayloadLite = {
  name: string
  type: CodegenFieldType
  comment: string
  required: boolean
  unique: boolean
  query: boolean
  search: boolean
  default?: string
  enumValues?: Array<{ value: number; label: string }>
}
