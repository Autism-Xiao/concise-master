import { Component, type ErrorInfo, type ReactNode } from 'react'
import { RotateCcw, TriangleAlert } from 'lucide-react'
import { Button } from '@/components/ui/button'

interface Props {
  children: ReactNode
  /** 值变化时自动清除错误态（例如标签 nonce / 租户代次变化） */
  resetKey?: string | number
  /** 自定义标题，默认为「页面暂时无法展示」 */
  title?: string
}

interface State {
  error: Error | null
}

/**
 * React 错误边界：组件渲染抛错时只降级当前区域，不再整页白屏。
 * 页签级包住业务页、根布局包住 Outlet、入口包住路由 Provider，三层互不替代。
 */
export class ErrorBoundary extends Component<Props, State> {
  state: State = { error: null }

  static getDerivedStateFromError(error: Error): State {
    return { error }
  }

  componentDidCatch(error: Error, info: ErrorInfo): void {
    // 生产环境只留控制台证据链；具体堆栈不展示给用户
    console.error('[页面渲染异常]', error, info.componentStack)
  }

  componentDidUpdate(prevProps: Props): void {
    if (this.state.error && prevProps.resetKey !== this.props.resetKey) {
      this.setState({ error: null })
    }
  }

  private retry = () => this.setState({ error: null })

  render(): ReactNode {
    if (!this.state.error) return this.props.children
    return (
      <div className="flex min-h-[320px] w-full items-center justify-center p-8">
        <div className="border-border bg-card max-w-md rounded-xl border p-8 text-center shadow-sm">
          <div className="bg-destructive/10 mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full">
            <TriangleAlert className="text-destructive h-6 w-6" />
          </div>
          <div className="text-lg font-semibold">{this.props.title ?? '页面暂时无法展示'}</div>
          <p className="text-muted-foreground mt-2 text-sm">该页面遇到了一个内部错误，其他页面不受影响。你可以重试，或返回首页继续使用。</p>
          <p className="text-muted-foreground mt-3 text-xs break-all opacity-70">{this.state.error.message}</p>
          <div className="mt-6 flex justify-center gap-3">
            <Button variant="outline" size="sm" onClick={this.retry}>
              <RotateCcw className="mr-2 h-4 w-4" />
              重试
            </Button>
            <Button variant="default" size="sm" asChild>
              <a href="/dashboard">返回首页</a>
            </Button>
          </div>
        </div>
      </div>
    )
  }
}
