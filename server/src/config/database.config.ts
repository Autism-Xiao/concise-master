import { registerAs } from '@nestjs/config'
import type { DataSourceOptions } from 'typeorm'

import { env, envBoolean, envNumber } from '../global/env'
import { dialectOf } from '../shared/database/dialect'
import { SnakeNamingStrategy } from '../shared/database/snake-naming.strategy'

/**
 * 数据库配置（MySQL / PostgreSQL 双方言）
 *
 * DB_TYPE=mysql（默认）→ 走原有 MySQL 链与迁移目录 migrations/mysql
 * DB_TYPE=postgres      → 走 PostgreSQL 基线 + 增量迁移目录 migrations/postgres
 *
 * entities 采用 dist 路径供迁移 CLI 使用；运行时由 autoLoadEntities 自动收集。
 * namingStrategy：全局 snake_case（createdAt→created_at），与既有表结构风格一致。
 */
export const databaseConfig = registerAs('database', (): DataSourceOptions => {
  const dialect = dialectOf()
  const common = {
    host: env('DB_HOST', '127.0.0.1'),
    username: env('DB_USERNAME', dialect === 'postgres' ? 'postgres' : 'root'),
    password: env('DB_PASSWORD'),
    database: env('DB_DATABASE', 'concise_server'),
    entities: ['dist/modules/**/*.entity.js'],
    migrations: [`dist/migrations/${dialect}/*.js`],
    namingStrategy: new SnakeNamingStrategy(),
    synchronize: envBoolean('DB_SYNCHRONIZE', false),
    logging: envBoolean('DB_LOGGING', false)
  }

  if (dialect === 'postgres') {
    return {
      ...common,
      type: 'postgres',
      port: envNumber('DB_PORT', 5432),
      extra: {
        // pg 连接池上限；多副本注意 max_connections 总量 = 实例数 × 20 + 余量
        max: envNumber('DB_POOL_SIZE', 20),
        connectionTimeoutMillis: 10_000
      }
    }
  }

  return {
    ...common,
    type: 'mysql',
    port: envNumber('DB_PORT', 3306),
    charset: 'utf8mb4_unicode_ci',
    timezone: '+08:00',
    extra: {
      // 压测基线（docs/2026-11-08-压测基线与负载脚本.md）：池 = 10 时所有碰库接口封顶 ~100 RPS、
      // 延迟随并发线性膨胀。20 对单实例够用；多副本注意 max_connections 总量 = 实例数 × 20 + 余量
      connectionLimit: envNumber('DB_POOL_SIZE', 20),
      // 复用 TCP 长连接：避免空闲期被服务端断开后首个请求重建连接的长尾延迟
      enableKeepAlive: true,
      keepAliveInitialDelay: 10_000
    }
  }
})
