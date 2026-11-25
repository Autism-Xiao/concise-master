import type { ReactNode } from 'react'
import { useRef, useState } from 'react'
import { Download, FileSpreadsheet, Upload } from 'lucide-react'
import { toast } from 'sonner'
import { toastError } from '@/lib/toast-error'
import { Button } from '@/components/ui/button'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { saveBlobFile } from '@/lib/download'
import { humanizeImportError } from '@/lib/import-error'
import { isApiError } from '@/lib/api-error'
import { isImportTemplateError } from '@/lib/biz-code'

/** 后端所有导入接口的统一返回结构（层级/字典/岗位/用户/角色/公告一致） */
export interface ImportResult {
  total: number
  created: number
  updated: number
  skipped: number
  failed: number
  /**
   * 失败明细；row 为行号，label 为该行的业务标识（标题/角色编码/账号…），用于「第 N 行（xxx）」。
   * key/username 是历史字段名，保留兼容已有调用方。
   */
  errors: Array<{ row: number; label?: string; key?: string; username?: string; message: string }>
  /**
   * 新建账号的随机初始密码（仅用户导入会返回；密码列留空时后端逐行生成，
   * 明文只在本次响应里出现一次，请线下告知用户并提醒首次登录修改）
   */
  generatedPasswords?: Array<{ row: number; username: string; password: string }>
}

interface ExcelImportDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  title: string
  /** 判定规则说明，写清「已存在时是更新还是跳过」 */
  description: ReactNode
  /** 风险提示（覆盖、删数据等），不传则不显示 */
  warning?: ReactNode
  templateHint?: ReactNode
  /** 选择文件时接受的格式，默认仅 xlsx；需要 csv 的模块传完整 accept 串 */
  accept?: string
  /** 导入成功（含部分成功）时回调，父组件据此刷新列表 */
  onImported: () => void
  /** 下载模板 */
  downloadTemplate: () => Promise<{ filename: string; blob: Blob }>
  /** 上传并导入 */
  importFile: (file: File) => Promise<ImportResult>
}

/** 失败明细最多展示条数，避免几十行错误把弹窗撑爆 */
const MAX_ERROR_ROWS = 10

/**
 * 通用 Excel 导入弹窗
 *
 * 各模块的导入交互完全一样（选文件 → 上传 → 展示逐行统计与失败原因），
 * 差异只有「模板怎么下」「文件怎么传」，所以收敛成一个组件，避免每个页面抄一遍。
 */
export function ExcelImportDialog({
  open,
  onOpenChange,
  title,
  description,
  warning,
  templateHint,
  accept = '.xlsx,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  onImported,
  downloadTemplate,
  importFile
}: ExcelImportDialogProps) {
  const inputRef = useRef<HTMLInputElement>(null)
  const [file, setFile] = useState<File | null>(null)
  const [importing, setImporting] = useState(false)
  const [downloading, setDownloading] = useState(false)
  const [report, setReport] = useState<ImportResult | null>(null)

  const reset = () => {
    setFile(null)
    setReport(null)
    if (inputRef.current) {
      inputRef.current.value = ''
    }
  }

  const handleClose = (next: boolean) => {
    if (!next) reset()
    onOpenChange(next)
  }

  const handleTemplate = () => {
    setDownloading(true)
    downloadTemplate()
      .then(({ filename, blob }) => saveBlobFile(filename, blob))
      .catch(e => toastError(e, '模板下载失败'))
      .finally(() => setDownloading(false))
  }

  const handleImport = () => {
    if (!file) {
      toast.error('请先选择文件')
      return
    }
    setImporting(true)
    setReport(null)
    importFile(file)
      .then(result => {
        setReport(result)
        if (result.created || result.updated) {
          onImported()
        }
        if (result.failed === 0) {
          toast.success(`导入完成：新增 ${result.created} 条，更新 ${result.updated} 条`)
        } else {
          toast.warning(`导入完成，但有 ${result.failed} 行失败，请查看下方明细`)
        }
      })
      .catch(e => {
        // 模板问题（缺列/没数据行）不是用户操作错了，引导回「下载模板」；其余原样透出
        if (isApiError(e) && isImportTemplateError(e.code)) {
          toast.error(`${e.message}。可点击上方「下载模板」，按模板列顺序填写后再导入`)
        } else {
          toastError(e, '导入失败')
        }
      })
      .finally(() => setImporting(false))
  }

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          <DialogDescription>{description}</DialogDescription>
        </DialogHeader>

        <div className="space-y-4">
          {warning && (
            <div className="rounded-md border border-amber-500/30 bg-amber-500/10 px-3 py-2 text-xs text-amber-700 dark:text-amber-400">{warning}</div>
          )}

          <div className="flex flex-wrap items-center gap-2">
            <Button type="button" variant="outline" size="sm" onClick={handleTemplate} disabled={downloading}>
              <Download className="size-4" />
              {downloading ? '下载中…' : '下载模板'}
            </Button>
            <span className="text-muted-foreground text-xs">{templateHint ?? '模板含填写说明，必填列带 *'}</span>
          </div>

          <div className="rounded-md border border-dashed p-4">
            <input
              ref={inputRef}
              type="file"
              accept={accept}
              className="hidden"
              onChange={e => {
                setFile(e.target.files?.[0] ?? null)
                setReport(null)
              }}
            />
            <div className="flex items-center justify-between gap-3">
              <div className="flex min-w-0 items-center gap-2">
                <FileSpreadsheet className="text-muted-foreground size-4 shrink-0" />
                <span className="truncate text-sm">{file ? file.name : '未选择文件'}</span>
                {file && <span className="text-muted-foreground shrink-0 text-xs">{(file.size / 1024).toFixed(1)} KB</span>}
              </div>
              <Button type="button" variant="outline" size="sm" onClick={() => inputRef.current?.click()} disabled={importing}>
                <Upload className="size-4" />
                选择文件
              </Button>
            </div>
          </div>

          {report && (
            <div className="space-y-2 rounded-md border p-3 text-sm">
              <div className="flex flex-wrap gap-x-4 gap-y-1">
                <span>共 {report.total} 行</span>
                <span className="text-emerald-600">新增 {report.created}</span>
                <span className="text-sky-600">更新 {report.updated}</span>
                <span className="text-muted-foreground">跳过 {report.skipped}</span>
                <span className={report.failed ? 'text-destructive' : 'text-muted-foreground'}>失败 {report.failed}</span>
              </div>
              {report.generatedPasswords && report.generatedPasswords.length > 0 && (
                <div className="rounded-md border border-sky-500/30 bg-sky-500/10 px-3 py-2">
                  <p className="text-xs font-medium text-sky-700 dark:text-sky-400">
                    以下 {report.generatedPasswords.length} 个新建账号使用了随机初始密码（仅本次展示，请及时保存并线下告知用户，提醒首次登录修改）：
                  </p>
                  <ul className="max-h-40 space-y-1 overflow-auto font-mono text-xs">
                    {report.generatedPasswords.map(item => (
                      <li key={`${item.row}-${item.username}`}>
                        第 {item.row} 行 {item.username}：{item.password}
                      </li>
                    ))}
                  </ul>
                </div>
              )}
              {report.errors.length > 0 && (
                <ul className="text-muted-foreground max-h-40 space-y-1 overflow-auto text-xs">
                  {report.errors.slice(0, MAX_ERROR_ROWS).map(item => (
                    <li key={`${item.row}-${item.label ?? item.key ?? item.username ?? item.message}`}>
                      第 {item.row} 行{item.label || item.key || item.username ? `（${item.label ?? item.key ?? item.username}）` : ''}：
                      {humanizeImportError(item.message)}
                    </li>
                  ))}
                  {report.errors.length > MAX_ERROR_ROWS && <li>…另有 {report.errors.length - MAX_ERROR_ROWS} 条未展示</li>}
                </ul>
              )}
            </div>
          )}
        </div>

        <DialogFooter>
          <Button type="button" variant="outline" onClick={() => handleClose(false)}>
            {report ? '关闭' : '取消'}
          </Button>
          <Button type="button" onClick={handleImport} disabled={!file || importing}>
            {importing ? '导入中…' : '开始导入'}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
