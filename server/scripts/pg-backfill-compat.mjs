/**
 * PostgreSQL 兼容列回填脚本
 *
 * 背景：PG 首次引导（pg-bootstrap.mjs）只复制实体里声明的列，
 * 而 login_tenant_id / last_pwd_update_time / sort / bpm_status / user_identity /
 * sys_user_depart.ID 这些历史列是迁移 CompatColumns 之后才加进 PG 的，
 * 因此首次复制时全部为 NULL/空串，造成两边数据对不上。
 *
 * 用法：
 *   node scripts/pg-backfill-compat.mjs --dry-run   # 只看会改哪些，不写入
 *   node scripts/pg-backfill-compat.mjs             # 回填 PG 中空值，MySQL 只读
 */
import 'dotenv/config'

import mysql from 'mysql2/promise'
import pg from 'pg'

const dryRun = process.argv.includes('--dry-run')

const db = process.env.DB_DATABASE || 'concise_server'
const host = process.env.DB_HOST || '127.0.0.1'
const mysqlClient = await mysql.createConnection({
  host,
  port: Number(process.env.MYSQL_PORT || 3306),
  user: process.env.MYSQL_USERNAME || 'root',
  password: process.env.MYSQL_PASSWORD || '',
  database: db
})
const pgClient = new pg.Client({
  host,
  port: Number(process.env.DB_PORT || 5432),
  user: process.env.DB_USERNAME || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: db
})

const qMy = name => '`' + String(name).replace(/`/g, '``') + '`'
const qPg = name => '"' + String(name).replace(/"/g, '""') + '"'

/** 需要回填的表：keys 用于在 PG 定位同一行，columns 为历史兼容列 */
const TARGETS = [
  {
    table: 'sys_depart',
    keys: ['id'],
    columns: ['qywx_identifier', 'ding_identifier', 'feishu_identifier', 'position_id', 'dep_post_parent_id']
  },
  {
    table: 'sys_role_permission',
    keys: ['role_id', 'permission_id'],
    columns: ['id', 'data_rule_ids', 'operate_date', 'operate_ip']
  },
  {
    table: 'sys_tenant_usage',
    keys: ['tenant_id', 'metric', 'period'],
    columns: ['created_at']
  },
  {
    table: 'sys_user',
    keys: ['id'],
    columns: [
      'third_id', 'third_type', 'activiti_sync', 'user_identity', 'client_id',
      'login_tenant_id', 'bpm_status', 'sign_enable', 'sign', 'main_dep_post_id',
      'position_type', 'last_pwd_update_time', 'sort', 'iz_hide_contact',
      'is_tenant_admin'
    ]
  },
  { table: 'sys_user_depart', keys: ['user_id', 'dep_id'], columns: ['ID'] },
  { table: 'sys_user_role', keys: ['user_id', 'role_id'], columns: ['id', 'tenant_id'] },
  { table: 'tool_storage', keys: ['id'], columns: ['tenant_id'] },
  { table: 'sys_dict_item', keys: ['id'], columns: ['color'] },
  { table: 'sys_log', keys: ['id'], columns: ['seq', 'prev_hash', 'entry_hash'] }
]

const isEmpty = value => value === null || value === undefined || value === ''

try {
  await pgClient.connect()
  let totalRows = 0

  for (const target of TARGETS) {
    const selected = [...target.keys, ...target.columns]
    const [myRows] = await mysqlClient.query(
      'SELECT ' + selected.map(qMy).join(', ') + ' FROM ' + qMy(target.table)
    )
    let updatedRows = 0
    const columnHits = Object.fromEntries(target.columns.map(column => [column, 0]))

    for (const row of myRows) {
      const keyValues = target.keys.map(key => row[key])
      const pgResult = await pgClient.query(
        'SELECT ' + target.columns.map(qPg).join(', ') + ' FROM ' + qPg(target.table) +
        ' WHERE ' + target.keys.map((key, i) => qPg(key) + ' = $' + (i + 1)).join(' AND '),
        keyValues
      )
      const pgRow = pgResult.rows[0]
      if (!pgRow) continue

      // 只补 PG 侧为空、且 MySQL 侧有值的单元格，不覆盖 PG 的新数据
      const need = target.columns.filter(column => isEmpty(pgRow[column]) && !isEmpty(row[column]))
      if (need.length === 0) continue
      for (const column of need) columnHits[column]++

      if (!dryRun) {
        await pgClient.query(
          'UPDATE ' + qPg(target.table) +
          ' SET ' + need.map((column, i) => qPg(column) + ' = $' + (target.keys.length + i + 1)).join(', ') +
          ' WHERE ' + target.keys.map((key, i) => qPg(key) + ' = $' + (i + 1)).join(' AND '),
          [...keyValues, ...need.map(column => row[column])]
        )
      }
      updatedRows++
    }

    totalRows += updatedRows
    console.log(
      (dryRun ? '[预演] ' : '[回填] ') + target.table +
      '：需更新 ' + updatedRows + ' 行 / 共 ' + myRows.length + ' 行；' +
      JSON.stringify(columnHits)
    )
  }

  console.log(dryRun ? '预演完成，未写入 PG。' : '回填完成，共更新 ' + totalRows + ' 行。')
} finally {
  await mysqlClient.end()
  await pgClient.end()
}
