/**
 * 原生 SQL 查询统一入口（MySQL / PostgreSQL 双方言）
 *
 * TypeORM 1.x 的 MySQL 驱动会把 `?` 占位符翻译成驱动参数，但 PG 驱动不会，
 * 直接把 `?` 交给 node-postgres 会报 42601 语法错误。所有业务层原生 SQL
 * 统一走这里：MySQL 原样透传，PG 按出现顺序替换为 $1/$2/…。
 *
 * 用法：await queryRaw(this.dataSource, 'SELECT ... WHERE id = ?', [id])
 */
import { isPostgres } from './dialect'

type Queryable = {
  query: (sql: string, parameters?: unknown[]) => Promise<unknown>
}

/**
 * 把 `?` 占位符按出现顺序换成 $1/$2/…。
 * 只替换「占位符」：跳过单引号字符串字面量里的 `?`（如 JSON 文本、LIKE 模式里的问号），
 * 也跳过已被转义的 `??`（方言里偶尔用于标识符转义，保留原样）。
 * 用有限状态机扫描，单引号内 `''` 表示字面量中的一个引号。
 */
function toPostgresPlaceholders(sql: string): string {
  let index = 0
  let out = ''
  let inString = false
  for (let i = 0; i < sql.length; i++) {
    const ch = sql[i]
    if (ch === "'") {
      // SQL 标准：字符串内两个连续单引号 = 一个字面量单引号，不结束字符串
      if (inString && sql[i + 1] === "'") {
        out += "''"
        i++
        continue
      }
      inString = !inString
      out += ch
      continue
    }
    if (!inString && ch === '?') {
      out += `$${++index}`
      continue
    }
    out += ch
  }
  return out
}

export async function queryRaw<T = unknown>(runner: Queryable, sql: string, params: unknown[] = []): Promise<T> {
  return (await runner.query(isPostgres() ? toPostgresPlaceholders(sql) : sql, params)) as T
}
