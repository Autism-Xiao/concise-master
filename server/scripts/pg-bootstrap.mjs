/**
 * PostgreSQL 首次引导脚本（双向兼容改造配套）
 *
 * 用途：
 *   1) 按实体元数据在 PG 中建表（TypeORM synchronize，仅首次使用）；
 *   2) 从现有 MySQL 库按表逐行复制种子/业务数据（方言无关，走实体元数据）；
 *   3) 修正 PG serial/identity 序列到当前最大主键；
 *   4) 登记 PG 基线迁移（migration:run）。
 *
 * 用法：
 *   node scripts/pg-bootstrap.mjs --sync   # 建表 + 复制数据 + 修序列
 *   node scripts/pg-bootstrap.mjs          # 只复制数据 + 修序列（表已存在时）
 *
 * 注意：复制会覆盖 PG 同名表的全部数据；MySQL 库只读，不会改动。
 * 该脚本只复制实体声明的列，CompatColumns 迁移新增的历史列（如 sys_user.login_tenant_id）
 * 不会带过去；执行完迁移后请再运行 `pnpm db:pg:backfill` 回填这些列。
 */
import 'dotenv/config'

import { DataSource } from 'typeorm'
import { databaseConfig } from '../dist/config/database.config.js'

const doSync = process.argv.includes('--sync')

// 先快照 .env 中的 PG 连接参数，避免构造 MySQL 数据源时覆盖
const PG_ENV = {
  port: process.env.PG_PORT ?? process.env.DB_PORT ?? '5432',
  username: process.env.PG_USERNAME ?? process.env.DB_USERNAME ?? 'postgres',
  password: process.env.PG_PASSWORD ?? process.env.DB_PASSWORD ?? ''
}

function sourceFor(type) {
  // databaseConfig() 内部从 process.env.DB_TYPE 读取方言；端口按各自容器分别指定
  process.env.DB_TYPE = type
  process.env.DB_PORT = type === 'mysql' ? (process.env.MYSQL_PORT ?? '3306') : PG_ENV.port
  process.env.DB_USERNAME = type === 'mysql' ? (process.env.MYSQL_USERNAME ?? 'root') : PG_ENV.username
  process.env.DB_PASSWORD = type === 'mysql' ? (process.env.MYSQL_PASSWORD ?? '') : PG_ENV.password
  return new DataSource(databaseConfig())
}

const mysql = sourceFor('mysql')
const pg = sourceFor('postgres')

/** PG 标识符引号 */
function quotePg(name) {
  return `"${String(name).replace(/"/g, '""')}"`
}

/** MySQL 标识符引号 */
function quoteMy(name) {
  return `\`${String(name).replace(/`/g, '``')}\``
}

function normalize(value, column) {
  if (value === undefined) return null
  if (value === null) return null
  if (Buffer.isBuffer(value)) return value
  if (value instanceof Date) return value
  if (typeof value === 'object') return JSON.stringify(value)
  if (column.type === 'boolean' && typeof value === 'number') return value !== 0
  return value
}

async function main() {
  await mysql.initialize()
  await pg.initialize()
  console.log(`[连接] MySQL ${mysql.options.database} / PostgreSQL ${pg.options.database}`)

  if (doSync) {
    console.log('[建表] 按实体元数据同步 PG 结构…')
    await pg.synchronize(false)
    console.log('[建表] 完成')
  }

  const metas = pg.entityMetadatas
  // 暂时关闭外键触发器，避免表间复制顺序问题（postgres 超级用户可用）
  await pg.query('SET session_replication_role = replica')
  let total = 0
  try {
    for (const meta of metas) {
      const table = quotePg(meta.tableName)
      const columns = meta.columns.filter(c => !c.isVirtualProperty)
      const names = columns.map(c => c.databaseName)
      const rows = await mysql.query(`SELECT * FROM ${quoteMy(meta.tableName)}`)
      if (rows.length === 0) {
        console.log(`[跳过] ${meta.tableName}（空表）`)
        continue
      }
      await pg.query(`DELETE FROM ${table}`)
      const sql = `INSERT INTO ${table} (${names.map(quotePg).join(', ')}) VALUES (${names.map((_, i) => `$${i + 1}`).join(', ')})`
      for (const row of rows) {
        const values = columns.map(c => normalize(row[c.databaseName], c))
        await pg.query(sql, values)
      }
      total += rows.length
      console.log(`[复制] ${meta.tableName}: ${rows.length} 行`)
    }
  } finally {
    await pg.query('SET session_replication_role = origin')
  }

  console.log('[序列] 修正自增主键…')
  for (const meta of metas) {
    for (const column of meta.columns) {
      if (column.generationStrategy !== 'increment') continue
      const table = quotePg(meta.tableName)
      const col = quotePg(column.databaseName)
      await pg.query(
        `SELECT setval(pg_get_serial_sequence($1, $2), GREATEST(COALESCE((SELECT MAX(${col}) FROM ${table}), 1), 1), true)`,
        [meta.tableName, column.databaseName]
      )
    }
  }

  console.log(`[完成] 共复制 ${total} 行 / ${metas.length} 张表`)
  await mysql.destroy()
  await pg.destroy()
}

main().catch(async error => {
  console.error('[失败]', error)
  await mysql.destroy().catch(() => {})
  await pg.destroy().catch(() => {})
  process.exit(1)
})
