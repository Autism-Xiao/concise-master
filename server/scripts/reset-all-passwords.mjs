/**
 * 重置 sys_user 全部用户密码，并同步更新 MySQL + PostgreSQL。
 *
 * 用法：
 *   node scripts/reset-all-passwords.mjs <admin密码> <其他用户密码>
 * 示例：
 *   node scripts/reset-all-passwords.mjs admin123 123456
 *
 * 说明：
 *   - 使用库中现有 argon2 哈希的参数（算法/版本/memory/time/parallelism）生成新哈希，
 *     保证与后端登录校验完全兼容。
 *   - 同时写入 MySQL 与 PG 的 sys_user.password。
 *   - 脚本自身不含任何明文密码，密码只通过命令行参数传入。
 */
import 'dotenv/config'
import mysql from 'mysql2/promise'
import pg from 'pg'
import { hash, verify, Algorithm, Version } from '@node-rs/argon2'

const [adminPlain, otherPlain] = process.argv.slice(2)
if (!adminPlain || !otherPlain) {
  console.error('缺少参数。用法: node scripts/reset-all-passwords.mjs <admin密码> <其他用户密码>')
  process.exit(1)
}

const db = process.env.DB_DATABASE || 'concise_server'
const my = await mysql.createConnection({
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.MYSQL_PORT || 3306),
  user: process.env.MYSQL_USERNAME || 'root',
  password: process.env.MYSQL_PASSWORD || '',
  database: db
})
const pc = new pg.Client({
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.PG_PORT || 5432),
  user: process.env.PG_USERNAME || 'postgres',
  password: process.env.PG_PASSWORD || '',
  database: db
})

try {
  await pc.connect()
  const [users] = await my.query('SELECT id, username, password FROM `sys_user` ORDER BY username')
  if (!users.length) throw new Error('sys_user 为空，未找到用户')

  // 用现有哈希作为模板解析 argon2 参数，确保与后端校验一致
  const parts = users[0].password.split('$')
  const params = {}
  for (const kv of (parts[3] || '').split(',')) {
    const [k, v] = kv.split('=')
    params[k] = Number(v)
  }
  const algorithm = parts[1] === 'argon2id' ? Algorithm.Argon2id : parts[1] === 'argon2i' ? Algorithm.Argon2i : Algorithm.Argon2d
  const version = Number((parts[2] || 'v=19').replace('v=', '')) === 16 ? Version.V0x10 : Version.V0x13
  const opts = {
    algorithm,
    version,
    memoryCost: params.m || 19456,
    timeCost: params.t || 2,
    parallelism: params.p || 1
  }
  console.log(`argon2 参数: ${parts[1]} v=${version} m=${opts.memoryCost} t=${opts.timeCost} p=${opts.parallelism}`)

  let adminCount = 0
  let otherCount = 0
  for (const u of users) {
    const plain = u.username === 'admin' ? adminPlain : otherPlain
    const h = await hash(plain, opts)
    if (!verify(h, plain)) throw new Error(`哈希自校验失败: ${u.username}`)
    await my.query('UPDATE `sys_user` SET password=? WHERE id=?', [h, u.id])
    await pc.query('UPDATE "sys_user" SET password=$1 WHERE id=$2', [h, u.id])
    if (u.username === 'admin') adminCount++
    else otherCount++
    console.log(`已重置: ${u.username}`)
  }
  console.log(`完成: admin ${adminCount} 个，其他用户 ${otherCount} 个；MySQL + PG 均已更新。`)
} finally {
  await my.end()
  await pc.end()
}
