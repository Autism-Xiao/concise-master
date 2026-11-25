import { Injectable } from '@nestjs/common'
import { collectDefaultMetrics, Counter, Histogram, Registry } from 'prom-client'

/**
 * Prometheus 指标中心（单例，进程内共享）
 *
 * - collectDefaultMetrics：CPU / 内存 / GC / 事件循环滞后等进程级指标，前缀 app_
 * - app_http_requests_total：请求计数（method / route 模板 / status 三维标签）
 * - app_http_request_duration_seconds：请求耗时直方图（P50/P90/P99 可直接查询）
 *
 * 标签用路由模板（req.route.path）而不是原始 URL——避免 /v1/users/:id 这类
 * 路径把标签基数打爆（每个用户 id 一个时间序列，Prometheus 会被拖死）。
 * 无法解析出模板的请求记为 "unmatched"。
 */
@Injectable()
export class MetricsService {
  readonly registry: Registry

  private readonly httpRequestsTotal: Counter<string>
  private readonly httpRequestDuration: Histogram<string>

  constructor() {
    this.registry = new Registry()
    collectDefaultMetrics({ register: this.registry, prefix: 'app_' })

    const labelNames = ['method', 'route', 'status'] as const
    this.httpRequestsTotal = new Counter({
      name: 'app_http_requests_total',
      help: 'HTTP 请求总数（route 为路由模板，非原始路径）',
      labelNames: [...labelNames],
      registers: [this.registry]
    })
    this.httpRequestDuration = new Histogram({
      name: 'app_http_request_duration_seconds',
      help: 'HTTP 请求耗时分布（秒）',
      labelNames: [...labelNames],
      buckets: [0.01, 0.05, 0.1, 0.3, 0.5, 1, 2, 5, 10],
      registers: [this.registry]
    })
  }

  /** 记录一次请求（由 main.ts 的 express 中间件在 res.finish 时调用；status 取真实下发码） */
  observe(method: string, route: string, status: number, durationSeconds: number): void {
    const labels = { method: method.toUpperCase(), route: route || 'unmatched', status: String(status) }
    this.httpRequestsTotal.inc(labels)
    this.httpRequestDuration.observe(labels, durationSeconds)
  }

  /** 渲染 Prometheus 文本格式（Content-Type 一并由 registry 提供） */
  async render(): Promise<string> {
    return this.registry.metrics()
  }

  get contentType(): string {
    return this.registry.contentType
  }
}
