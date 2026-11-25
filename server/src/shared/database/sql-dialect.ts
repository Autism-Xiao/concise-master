/**
 * 原生 SQL 方言适配（MySQL / PostgreSQL）
 *
 * 业务代码里保留 `?` 占位符（TypeORM 会自动翻译成 $1/$2），
 * 只把 MySQL 专属函数/语法通过这里的小助手替换成两库都能执行的片段。
 * 新增原生 SQL 时一律走本文件，不再直接写反引号或 MySQL 函数。
 */
import { isPostgres } from './dialect'

export { isPostgres } from './dialect'

export type DateFormat = 'date' | 'datetime' | 'month' | 'monthStart'

/** 日期格式化表达式：DATE_FORMAT(col, ...) / to_char(col, ...) */
export function sqlDate(column: string, format: DateFormat): string {
  if (!isPostgres()) {
    const patterns: Record<DateFormat, string> = {
      date: '%Y-%m-%d',
      datetime: '%Y-%m-%d %H:%i:%s',
      month: '%Y-%m',
      monthStart: '%Y-%m-01'
    }
    return `DATE_FORMAT(${column}, '${patterns[format]}')`
  }
  const patterns: Record<DateFormat, string> = {
    date: 'YYYY-MM-DD',
    datetime: 'YYYY-MM-DD HH24:MI:SS',
    month: 'YYYY-MM',
    monthStart: 'YYYY-MM-01'
  }
  return `to_char(${column}, '${patterns[format]}')`
}

/** 结果列别名：PG 会把未加引号的驼峰别名折成小写，必须显式加双引号 */
export function sqlAlias(name: string): string {
  return isPostgres() ? `AS "${name}"` : `AS ${name}`
}

/** 条件求和：MySQL SUM(cond) / PG COUNT(*) FILTER (WHERE cond) */
export function sqlSumIf(condition: string): string {
  return isPostgres() ? `COUNT(*) FILTER (WHERE ${condition})` : `SUM(${condition})`
}

/** 当前本地日期 */
export function sqlCurrentDate(): string {
  return isPostgres() ? 'CURRENT_DATE' : 'CURDATE()'
}

/** 日期加 N 天（amount 可是常量或 ? 占位符） */
export function sqlAddDays(base: string, amount: string): string {
  return isPostgres() ? `(${base} + ${amount} * INTERVAL '1 day')` : `DATE_ADD(${base}, INTERVAL ${amount} DAY)`
}

/** 当前时间减 N 天 */
export function sqlDaysAgo(amount: string): string {
  return isPostgres() ? `(NOW() - ${amount} * INTERVAL '1 day')` : `DATE_SUB(NOW(), INTERVAL ${amount} DAY)`
}

/** N 个月前的月初（ NATURAL MONTH 边界） */
export function sqlMonthsAgoStart(months: number): string {
  if (isPostgres()) return `(date_trunc('month', CURRENT_DATE) - ${months} * INTERVAL '1 month')`
  return `DATE_SUB(${sqlDate('CURDATE()', 'monthStart')}, INTERVAL ${months} MONTH)`
}

/** 唯一键冲突忽略：INSERT IGNORE INTO … / INSERT INTO … ON CONFLICT DO NOTHING */
export function sqlInsertIgnorePrefix(): string {
  return isPostgres() ? 'INSERT INTO' : 'INSERT IGNORE INTO'
}

export function sqlInsertIgnoreSuffix(): string {
  return isPostgres() ? ' ON CONFLICT DO NOTHING' : ''
}

/** 数据库名 */
export function sqlDatabase(): string {
  return isPostgres() ? 'current_database()' : 'DATABASE()'
}

/** 默认 schema（PG 通常为 public） */
export function sqlSchema(): string {
  return "'public'"
}

/** 部门 org_code 冗余字段刷新（跨表 UPDATE 语法两库不同） */
export function sqlUpdateUserOrgCode(): string {
  return isPostgres()
    ? 'UPDATE sys_user u SET org_code = ? FROM sys_user_depart ud WHERE ud.user_id = u.id AND ud.dep_id = ?'
    : 'UPDATE `sys_user` u JOIN `sys_user_depart` ud ON ud.`user_id` = u.`id` SET u.`org_code` = ? WHERE ud.`dep_id` = ?'
}

/** 删除某租户角色下的用户绑定（MySQL DELETE JOIN / PG DELETE USING） */
export function sqlDeleteTenantRoleBindings(placeholders: string): string {
  return isPostgres()
    ? `DELETE FROM sys_user_role ur USING sys_role r WHERE r.id = ur.role_id AND r.tenant_id = ? AND ur.user_id IN (${placeholders})`
    : `DELETE ur FROM sys_user_role ur INNER JOIN sys_role r ON r.id = ur.role_id WHERE r.tenant_id = ? AND ur.user_id IN (${placeholders})`
}

/** 代码生成：可反查表清单 */
export function sqlCodegenTables(): string {
  return isPostgres()
    ? `SELECT c.relname AS "TABLE_NAME", COALESCE(obj_description(c.oid), '') AS "TABLE_COMMENT",
              (SELECT COUNT(*) FROM information_schema.columns col
                WHERE col.table_schema = n.nspname AND col.table_name = c.relname) AS "COLUMNS"
         FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' AND c.relkind = 'r'
          AND c.relname NOT LIKE 'sys\\_%' AND c.relname NOT LIKE 'qrtz\\_%'
          AND c.relname <> 'migrations'
        ORDER BY c.relname ASC`
    : `SELECT t.TABLE_NAME, t.TABLE_COMMENT,
              (SELECT COUNT(*) FROM information_schema.COLUMNS c
                WHERE c.TABLE_SCHEMA = t.TABLE_SCHEMA AND c.TABLE_NAME = t.TABLE_NAME) AS COLUMNS
         FROM information_schema.TABLES t
        WHERE t.TABLE_SCHEMA = DATABASE()
          AND t.TABLE_TYPE = 'BASE TABLE'
          AND t.TABLE_NAME NOT LIKE 'sys\\_%'
          AND t.TABLE_NAME NOT LIKE 'qrtz\\_%'
          AND t.TABLE_NAME <> 'migrations'
        ORDER BY t.TABLE_NAME ASC`
}

/** 代码生成：列定义（含注释） */
export function sqlCodegenColumns(): string {
  return isPostgres()
    ? `SELECT c.column_name AS "COLUMN_NAME", c.data_type AS "DATA_TYPE", c.data_type AS "COLUMN_TYPE",
              c.is_nullable AS "IS_NULLABLE", c.column_default AS "COLUMN_DEFAULT",
              COALESCE(col_description(a.attrelid, a.attnum), '') AS "COLUMN_COMMENT"
         FROM information_schema.columns c
         JOIN pg_class cl ON cl.relname = c.table_name
         JOIN pg_namespace ns ON ns.oid = cl.relnamespace AND ns.nspname = c.table_schema
         JOIN pg_attribute a ON a.attrelid = cl.oid AND a.attname = c.column_name
        WHERE c.table_schema = 'public' AND c.table_name = ?
        ORDER BY c.ordinal_position ASC`
    : `SELECT COLUMN_NAME, DATA_TYPE, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT, COLUMN_COMMENT
         FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?
        ORDER BY ORDINAL_POSITION ASC`
}

/** 代码生成：单列唯一索引 */
export function sqlCodegenUniques(): string {
  return isPostgres()
    ? `SELECT a.attname AS "COLUMN_NAME"
         FROM pg_index i
         JOIN pg_class c ON c.oid = i.indrelid
         JOIN pg_namespace n ON n.oid = c.relnamespace
         JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = ANY(i.indkey)
        WHERE n.nspname = 'public' AND c.relname = ?
          AND i.indisunique AND NOT i.indisprimary
          AND array_length(i.indkey, 1) = 1`
    : `SELECT COLUMN_NAME FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND NON_UNIQUE = 0 AND INDEX_NAME <> 'PRIMARY'
        GROUP BY INDEX_NAME, COLUMN_NAME HAVING COUNT(*) = 1`
}

/** 代码生成：表注释 */
export function sqlCodegenTableComment(): string {
  return isPostgres()
    ? `SELECT COALESCE(obj_description(c.oid), '') AS "TABLE_COMMENT"
         FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' AND c.relname = ?`
    : `SELECT TABLE_COMMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?`
}

/** 代码生成：表是否存在 / 现有列名 */
export function sqlCodegenTableExists(): string {
  return isPostgres()
    ? `SELECT COUNT(*) AS c FROM information_schema.tables WHERE table_schema = 'public' AND table_name = ?`
    : `SELECT COUNT(*) AS c FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?`
}

export function sqlCodegenTableColumns(): string {
  return isPostgres()
    ? `SELECT column_name AS c FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = ? ORDER BY ordinal_position`
    : `SELECT COLUMN_NAME AS c FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? ORDER BY ORDINAL_POSITION`
}
