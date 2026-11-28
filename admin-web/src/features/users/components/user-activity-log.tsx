import { useEffect, useState, type ReactNode } from 'react'
import { Button } from '@/components/ui/button'
import { Segmented } from '@/components/ui/segmented'
import { Skeleton } from '@/components/ui/skeleton'
import { toastError } from '@/lib/toast-error'
import { fetchLoginLogs, fetchOperationLogs, type LoginLog, type OperationLog } from '@/features/system/log/api'
import { fetchPasswordRecords, PASSWORD_CHANGE_TYPE_LABELS, type PasswordRecord, type User } from '../api'

type LogTab = 'login' | 'operation' | 'password'

const TABS = [
  { value: 'login', label: '登录日志' },
  { value: 'operation', label: '操作日志' },
  { value: 'password', label: '密码修改' }
] as const

const PAGE_SIZE = 10

interface UserActivityLogProps {
  user: User
  /** 外部操作（如重置密码）完成后递增，触发日志重新加载 */
  refreshToken?: number
}

function Cell({ children, className = '' }: { children?: ReactNode; className?: string }) {
  return <td className={`border-border border-b px-3 py-2 align-top ${className}`}>{children}</td>
}

/**
 * 用户详情下方的日志区：登录日志 / 操作日志 / 密码修改记录
 *
 * 三个接口都按用户 id 精确过滤，服务端分页；切换页签时回到第一页。
 */
export function UserActivityLog({ user, refreshToken = 0 }: UserActivityLogProps) {
  const [tab, setTab] = useState<LogTab>('login')
  const [page, setPage] = useState(1)
  const [loading, setLoading] = useState(true)
  const [total, setTotal] = useState(0)
  const [loginLogs, setLoginLogs] = useState<LoginLog[]>([])
  const [operLogs, setOperLogs] = useState<OperationLog[]>([])
  const [pwdRecords, setPwdRecords] = useState<PasswordRecord[]>([])

  useEffect(() => {
    let cancelled = false
    setLoading(true)
    const done = (records: Array<LoginLog | OperationLog | PasswordRecord>, count: number) => {
      if (cancelled) return
      if (tab === 'login') setLoginLogs(records as LoginLog[])
      if (tab === 'operation') setOperLogs(records as OperationLog[])
      if (tab === 'password') setPwdRecords(records as PasswordRecord[])
      setTotal(count)
      setLoading(false)
    }
    const fail = (e: unknown) => {
      if (cancelled) return
      toastError(e, '加载用户日志失败')
      setTotal(0)
      setLoading(false)
    }

    if (tab === 'login') {
      fetchLoginLogs({ userId: user.id, page, pageSize: PAGE_SIZE }).then(res => done(res.records ?? [], res.total ?? 0)).catch(fail)
    } else if (tab === 'operation') {
      fetchOperationLogs({ userId: user.id, page, pageSize: PAGE_SIZE }).then(res => done(res.records ?? [], res.total ?? 0)).catch(fail)
    } else {
      fetchPasswordRecords(user.id, page, PAGE_SIZE).then(res => done(res.records ?? [], res.total ?? 0)).catch(fail)
    }
    return () => { cancelled = true }
  }, [user.id, tab, page, refreshToken])

  const switchTab = (value: string) => {
    setTab(value as LogTab)
    setPage(1)
  }

  const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE))

  return (
    <section className="space-y-3 pt-2">
      <div className="flex flex-wrap items-center justify-between gap-2">
        <h4 className="text-sm font-semibold">用户日志</h4>
        <Segmented value={tab} onChange={switchTab} options={TABS.map(t => ({ value: t.value, label: t.label }))} />
      </div>

      {loading ? (
        <div className="space-y-2">
          {Array.from({ length: 4 }).map((_, i) => <Skeleton key={i} className="h-8 w-full" />)}
        </div>
      ) : (
        <div className="overflow-x-auto rounded-md border">
          <table className="w-full text-sm">
            <thead className="bg-muted/50 text-muted-foreground text-xs">
              {tab === 'login' && (
                <tr><th className="px-3 py-2 text-start font-medium">登录时间</th><th className="px-3 py-2 text-start font-medium">地点</th><th className="px-3 py-2 text-start font-medium">终端</th><th className="px-3 py-2 text-start font-medium">IP</th><th className="px-3 py-2 text-start font-medium">结果</th></tr>
              )}
              {tab === 'operation' && (
                <tr><th className="px-3 py-2 text-start font-medium">操作时间</th><th className="px-3 py-2 text-start font-medium">操作类型</th><th className="px-3 py-2 text-start font-medium">IP</th><th className="px-3 py-2 text-start font-medium">耗时</th><th className="px-3 py-2 text-start font-medium">结果</th></tr>
              )}
              {tab === 'password' && (
                <tr><th className="px-3 py-2 text-start font-medium">修改时间</th><th className="px-3 py-2 text-start font-medium">类型</th><th className="px-3 py-2 text-start font-medium">操作人</th><th className="px-3 py-2 text-start font-medium">来源 IP</th><th className="px-3 py-2 text-start font-medium">备注</th></tr>
              )}
            </thead>
            <tbody>
              {tab === 'login' && loginLogs.map(log => (
                <tr key={log.id}>
                  <Cell className="whitespace-nowrap font-mono text-xs">{log.time}</Cell>
                  <Cell>{log.location || '未知'}</Cell>
                  <Cell className="text-xs">{[log.browser, log.os].filter(v => v && v !== '未知').join(' / ') || '-'}</Cell>
                  <Cell className="font-mono text-xs">{log.ip || '-'}</Cell>
                  <Cell>
                    <span className={log.status === '成功' ? 'text-emerald-600 dark:text-emerald-400' : 'text-destructive'} title={log.message}>
                      {log.status}
                    </span>
                  </Cell>
                </tr>
              ))}
              {tab === 'operation' && operLogs.map(log => (
                <tr key={log.id}>
                  <Cell className="whitespace-nowrap font-mono text-xs">{log.time}</Cell>
                  <Cell>{log.action || '-'}{log.proxy && <span className="ms-1 rounded bg-amber-100 px-1 text-[10px] text-amber-700 dark:bg-amber-950 dark:text-amber-300">代维</span>}</Cell>
                  <Cell className="font-mono text-xs">{log.ip || '-'}</Cell>
                  <Cell className="font-mono text-xs">{log.cost ?? 0} ms</Cell>
                  <Cell className={log.status === '成功' ? 'text-emerald-600 dark:text-emerald-400' : 'text-destructive'}>{log.status}</Cell>
                </tr>
              ))}
              {tab === 'password' && pwdRecords.map(record => (
                <tr key={record.id}>
                  <Cell className="whitespace-nowrap font-mono text-xs">{record.createTime?.replace('T', ' ').slice(0, 19)}</Cell>
                  <Cell>{PASSWORD_CHANGE_TYPE_LABELS[record.changeType] ?? record.changeType}</Cell>
                  <Cell>{record.operatorName || record.operatorId || '-'}</Cell>
                  <Cell className="font-mono text-xs">{record.ip || '-'}</Cell>
                  <Cell className="text-muted-foreground">{record.remark || '-'}</Cell>
                </tr>
              ))}
              {(tab === 'login' ? loginLogs : tab === 'operation' ? operLogs : pwdRecords).length === 0 && (
                <tr><td colSpan={5} className="text-muted-foreground py-8 text-center text-sm">暂无记录</td></tr>
              )}
            </tbody>
          </table>
        </div>
      )}

      <div className="flex items-center justify-between gap-2">
        <span className="text-muted-foreground text-xs">共 {total} 条 · 第 {page} / {totalPages} 页</span>
        <div className="flex gap-1">
          <Button variant="outline" size="sm" disabled={page <= 1 || loading} onClick={() => setPage(p => p - 1)}>上一页</Button>
          <Button variant="outline" size="sm" disabled={page >= totalPages || loading} onClick={() => setPage(p => p + 1)}>下一页</Button>
        </div>
      </div>
    </section>
  )
}
