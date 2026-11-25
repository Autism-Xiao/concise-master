import { Injectable, type CallHandler, type ExecutionContext, type NestInterceptor } from '@nestjs/common'
import { tap, type Observable } from 'rxjs'

import { MetricsService } from './metrics.service'

interface RequestLike {
  method?: string
  route?: { path?: string }
  user?: { id?: string }
}

/**
 * HTTP 指标采集拦截器（全局注册，APP_INTERCEPTOR）
 *
 * 挂在守卫之后、业务 handler 之前：守卫层拒绝的请求（401/403/429）走不到
 * handler，但拦截器链已经启动——用 tap 的 finalize 语义保证异常路径也计数。
 * /api/metrics 自身不计（在 main.ts 的 express 层注册，根本进不了 Nest）。
 *
 * 放弃了 nestjs-prometheus 之类的现成方案：本项目只需一个计数器 + 一个直方图，
 * 引入整个库的模块体系反而拉长启动链路。
 */
@Injectable()
export class MetricsInterceptor implements NestInterceptor {
  constructor(private readonly metrics: MetricsService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const http = context.switchToHttp()
    const request = http.getRequest<RequestLike | undefined>()
    const response = http.getResponse<{ statusCode?: number } | undefined>()
    if (!request || request.method === 'OPTIONS') return next.handle()

    const startedAt = process.hrtime.bigint()
    const route = request.route?.path ?? 'unmatched'
    const method = request.method ?? 'GET'

    return next.handle().pipe(
      tap({
        next: () => this.record(method, route, response?.statusCode ?? 200, startedAt),
        error: error => {
          // 统一异常过滤器还没跑，这里只能拿到原始异常；状态码尽力取，取不到按 500
          const status = (error as { status?: number; getStatus?: () => number })?.getStatus?.() ?? (error as { status?: number })?.status ?? 500
          this.record(method, route, status, startedAt)
        }
      })
    )
  }

  private record(method: string, route: string, status: number, startedAt: bigint): void {
    const durationSeconds = Number(process.hrtime.bigint() - startedAt) / 1e9
    this.metrics.observe(method, route, status, durationSeconds)
  }
}
