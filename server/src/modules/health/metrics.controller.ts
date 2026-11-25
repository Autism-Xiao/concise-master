import { Controller, ForbiddenException, Get, Inject, Res } from '@nestjs/common'
import { timingSafeEqual } from 'node:crypto'
import type { Response } from 'express'
import { ApiOperation, ApiTags } from '@nestjs/swagger'
import { DataSource } from 'typeorm'

import { Public } from '../../common/decorators/public.decorator'
import { RedisService } from '../../shared/redis/redis.service'
import { queryRaw } from '../../shared/database/raw-query'

/**
 * Prometheus 指标端点（文本格式）
 *
 * GET /api/v1/metrics（@Public，可选 METRICS_TOKEN 保护）
 *
 * 设计取舍：
 * - 不引 prom-client：暴露的指标就这几项，手拼文本格式比引 300K+ 依赖划算；
 * - 采集是拉取式，每次 scrape 现查 DB/Redis 健康（Prometheus 默认 15s 一次，
 *   一次 SELECT 1 + PING 的成本可忽略）；
 * - 进程级指标（内存/CPU/句柄）取自 process/os，多实例部署下各实例独立暴露；
 * - 业务计数（API 调用量等）在 sys_tenant_usage 有账单底稿，指标端不重复聚合，
 *   需要时由 Prometheus 的 mysql exporter 直接抓库。
 */
@ApiTags('系统 V1 · 指标')
@Controller('v1/metrics')
export class MetricsController {
  constructor(
    private readonly dataSource: DataSource,
    @Inject(RedisService) private readonly redisService: RedisService
  ) {}

  /** 常量时间 token 比较：长度不等直接 false，等长逐字节异或累加（防 timing 侧信道逐位猜 token） */
  private safeTokenEquals(given: string, expected: string): boolean {
    const a = Buffer.from(given)
    const b = Buffer.from(expected)
    if (a.length !== b.length) return false
    return timingSafeEqual(a, b)
  }

  @Public()
  @Get()
  @ApiOperation({ summary: 'Prometheus 指标（文本格式）', description: '可选 METRICS_TOKEN 保护（Authorization: Bearer）' })
  async metrics(@Res() res: Response) {
    const expected = process.env.METRICS_TOKEN
    if (expected) {
      // 只认 Authorization: Bearer：token 走 URL 会进访问日志/反代日志，等于写在明面上
      const bearer = (res.req.headers.authorization ?? '').replace(/^Bearer\s+/i, '')
      if (!bearer || !this.safeTokenEquals(bearer, expected)) {
        throw new ForbiddenException('METRICS_TOKEN 校验失败')
      }
    }

    // DB / Redis 健康（探测失败计 0，不抛错——指标端永远返回 200）
    let dbUp = 0
    try {
      await queryRaw(this.dataSource, 'SELECT 1')
      dbUp = 1
    } catch {
      // 保持 0
    }
    let redisUp = 0
    if (this.redisService.enabled && this.redisService.client) {
      try {
        await this.redisService.client.ping()
        redisUp = 1
      } catch {
        redisUp = 0
      }
    }

    const memory = process.memoryUsage()
    const cpu = process.cpuUsage()
    const lines: string[] = [
      '# HELP process_uptime_seconds 进程运行秒数',
      '# TYPE process_uptime_seconds gauge',
      `process_uptime_seconds ${process.uptime().toFixed(1)}`,
      '# HELP process_resident_memory_bytes 常驻内存（RSS）',
      '# TYPE process_resident_memory_bytes gauge',
      `process_resident_memory_bytes ${memory.rss}`,
      '# HELP process_heap_used_bytes V8 堆已用',
      '# TYPE process_heap_used_bytes gauge',
      `process_heap_used_bytes ${memory.heapUsed}`,
      '# HELP process_heap_total_bytes V8 堆总量',
      '# TYPE process_heap_total_bytes gauge',
      `process_heap_total_bytes ${memory.heapTotal}`,
      '# HELP process_external_memory_bytes Buffer/外部内存',
      '# TYPE process_external_memory_bytes gauge',
      `process_external_memory_bytes ${memory.external}`,
      '# HELP process_cpu_user_seconds_total 用户态 CPU 累计秒',
      '# TYPE process_cpu_user_seconds_total counter',
      `process_cpu_user_seconds_total ${(cpu.user / 1_000_000).toFixed(3)}`,
      '# HELP process_cpu_system_seconds_total 内核态 CPU 累计秒',
      '# TYPE process_cpu_system_seconds_total counter',
      `process_cpu_system_seconds_total ${(cpu.system / 1_000_000).toFixed(3)}`,
      '# HELP app_db_up 数据库健康（1 正常）',
      '# TYPE app_db_up gauge',
      `app_db_up ${dbUp}`,
      '# HELP app_redis_up Redis 健康（1 正常；未启用时为 0 且不告警）',
      '# TYPE app_redis_up gauge',
      `app_redis_up ${redisUp}`,
      '# HELP app_build_info 构建信息',
      '# TYPE app_build_info gauge',
      `app_build_info{version="${process.env.npm_package_version ?? 'unknown'}",node="${process.version}"} 1`
    ]

    res.setHeader('Content-Type', 'text/plain; version=0.0.4; charset=utf-8')
    return res.send(lines.join('\n') + '\n')
  }
}
