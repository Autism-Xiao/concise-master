import { Global, Module } from '@nestjs/common'

import { MetricsService } from './metrics.service'

/**
 * 可观测性指标（全局）
 *
 * - MetricsService：prom-client Registry 单例（默认进程指标 + HTTP 计数/耗时）
 * - HTTP 计数/耗时由 main.ts 的 express 中间件采集（registerHttpMetrics），不在 Nest
 *   拦截器里做——拦截器在 Guard 之后，守卫拒绝的请求统计不到，也读不到真实状态码
 * - 暴露端点在 main.ts 以 express 实例注册（/api/metrics），不进 Nest 管线，
 *   避开 TransformInterceptor 的 JSON 包装与鉴权链；METRICS_TOKEN 非空时要求令牌
 */
@Global()
@Module({
  providers: [MetricsService],
  exports: [MetricsService]
})
export class MetricsModule {}
