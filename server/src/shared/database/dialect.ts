/**
 * 数据库方言开关（MySQL / PostgreSQL 双兼容）
 *
 * 全局唯一判断入口：配置层、原生 SQL 适配层、备份服务都从这里读，
 * 只允许通过 DB_TYPE 环境变量切换，避免各处各自猜测驱动类型。
 */
export type DbDialect = 'mysql' | 'postgres'

/** 当前方言；默认 mysql 保证既有部署零行为变化 */
export function dialectOf(): DbDialect {
  return String(process.env.DB_TYPE ?? '')
    .trim()
    .toLowerCase() === 'postgres'
    ? 'postgres'
    : 'mysql'
}

/** 是否 PostgreSQL */
export function isPostgres(): boolean {
  return dialectOf() === 'postgres'
}
