import type { FormEvent, ReactNode } from 'react'
import { Button } from '@/components/ui/button'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { cn } from '@/lib/utils'

/**
 * 公共表单弹窗（居中弹出）
 *
 * 与 AppDrawer 的分工：字段少、不需要长表单滚动时用弹窗；字段多用 AppDrawer。
 * 两者都把「标题头 + form + 取消/保存底栏」这套壳收口，业务弹窗只写字段。
 *
 * 原理：DialogContent 的 fixed 布局按组件类型把 children 分拣到头/身/尾，
 * 所以 form 作为独立 body 元素、DialogHeader/DialogFooter 必须直接挂在 DialogContent 下。
 * 提交按钮用 form={formId} 关联到 body 里的 <form>，回车与点击都能提交。
 */
export type AppFormDialogSize = 'sm' | 'md' | 'lg' | 'xl' | '2xl'

/** 档位与 Tailwind max-w-* 一一对应，迁移时可原样保留弹窗原有宽度 */
const SIZE_CLASS: Record<AppFormDialogSize, string> = {
  sm: 'sm:max-w-sm',
  md: 'sm:max-w-md',
  lg: 'sm:max-w-lg',
  xl: 'sm:max-w-xl',
  '2xl': 'sm:max-w-2xl'
}

interface AppFormDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  title: ReactNode
  description?: ReactNode
  /** 宽度档位，默认 md（约 448px） */
  size?: AppFormDialogSize
  /** form 的 id；提交按钮通过 form={formId} 关联，业务 <form> 需用同一个 id */
  formId: string
  children: ReactNode
  /** 表单提交处理；内部已完成 preventDefault */
  onSubmit: (e: FormEvent<HTMLFormElement>) => void
  submitting?: boolean
  submitText?: string
  cancelText?: string
  submitDisabled?: boolean
  /** form 附加类（默认 space-y-4） */
  formClassName?: string
  /** DialogContent 附加类（如 max-h-[88vh]） */
  contentClassName?: string
  /** 底栏自定义按钮，插在取消/保存之前（如「继续添加」） */
  footerExtra?: ReactNode
  /** 保存按钮文案在提交中的替身，默认「保存中…」 */
  submittingText?: string
}

export function AppFormDialog({
  open,
  onOpenChange,
  title,
  description,
  size = 'md',
  formId,
  children,
  onSubmit,
  submitting = false,
  submitText = '保存',
  cancelText = '取消',
  submitDisabled = false,
  formClassName,
  contentClassName,
  footerExtra,
  submittingText = '保存中…'
}: AppFormDialogProps) {
  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    onSubmit(e)
  }

  return (
    <Dialog open={open} onOpenChange={next => !submitting && onOpenChange(next)}>
      <DialogContent className={cn(SIZE_CLASS[size], contentClassName)}>
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          {description != null && <DialogDescription>{description}</DialogDescription>}
        </DialogHeader>
        <form id={formId} className={cn('space-y-4', formClassName)} onSubmit={handleSubmit}>
          {children}
        </form>
        <DialogFooter>
          {footerExtra}
          <Button type="button" variant="outline" onClick={() => onOpenChange(false)} disabled={submitting}>
            {cancelText}
          </Button>
          <Button type="submit" form={formId} disabled={submitting || submitDisabled}>
            {submitting ? submittingText : submitText}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
