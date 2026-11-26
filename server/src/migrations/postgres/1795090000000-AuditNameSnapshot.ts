import { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 审计人名字快照（PG 版）
 *
 * 背景：createBy/updateBy 存的是用户 ID，此前靠响应层拦截器实时查 sys_user
 * 翻译成名字。用户改名后，所有历史记录的"创建人/更新人"会跟着变，
 * 审计留痕被追溯修改——这是错的。
 *
 * 方案：给**所有有 create_by 列的表**加 create_by_name / update_by_name 两列，
 * 写入时把当时的名字固化进去；拦截器只在快照为空（历史数据）时回退实时查。
 * 表清单运行时从 information_schema 动态取（不硬编码），新表也能覆盖到。
 *
 * 回填策略：用 create_by 关联 sys_user，把**当前**名字写入快照作为初始值。
 * 历史数据无法还原"当时叫什么"，这是唯一可行的近似；回填后名字即冻结，
 * 今后改名不再影响这些记录。
 */
export class AuditNameSnapshot1795090000000 implements MigrationInterface {
  name = 'AuditNameSnapshot1795090000000'

  /** 运行时查出所有有 create_by 列的表（public schema），避免硬编码清单遗漏 */
  private async tablesWithCreateBy(queryRunner: QueryRunner): Promise<string[]> {
    const rows: { table_name: string }[] = await queryRunner.query(
      `SELECT table_name FROM information_schema.columns
       WHERE table_schema = 'public' AND column_name = 'create_by'
         AND table_name <> 'migrations'
       ORDER BY table_name`
    )
    return rows.map(row => row.table_name)
  }

  public async up(queryRunner: QueryRunner): Promise<void> {
    const tables = await this.tablesWithCreateBy(queryRunner)
    for (const table of tables) {
      await queryRunner.query(
        `ALTER TABLE "${table}" ADD COLUMN IF NOT EXISTS "create_by_name" varchar(64) NULL`
      )
      await queryRunner.query(
        `ALTER TABLE "${table}" ADD COLUMN IF NOT EXISTS "update_by_name" varchar(64) NULL`
      )
      await queryRunner.query(
        `COMMENT ON COLUMN "${table}"."create_by_name" IS '创建人名字快照（写入时固化，改名不影响历史）'`
      )
      await queryRunner.query(
        `COMMENT ON COLUMN "${table}"."update_by_name" IS '更新人名字快照（写入时固化，改名不影响历史）'`
      )
      // 回填历史数据：姓名优先、空则回退账号。两条独立 UPDATE，避免创建人/更新人
      // 不同时被同一行 u 错配；仅回填仍为空的快照，不覆盖已有值。
      // 部分表的 create_by 存的不是 user.id（如 sys_log 存账号），关联不到自然留空，无害。
      await queryRunner.query(
        `UPDATE "${table}" c
         SET create_by_name = COALESCE(NULLIF(TRIM(u.realname), ''), u.username)
         FROM sys_user u
         WHERE u.id = c.create_by AND c.create_by_name IS NULL`
      )
      // 只在表确实有 update_by 列时回填（个别表只有 create_by）
      const hasUpdateBy: { n: number }[] = await queryRunner.query(
        `SELECT count(*)::int AS n FROM information_schema.columns
         WHERE table_schema = 'public' AND table_name = $1 AND column_name = 'update_by'`,
        [table]
      )
      if (Number(hasUpdateBy[0]?.n ?? 0) > 0) {
        await queryRunner.query(
          `UPDATE "${table}" c
           SET update_by_name = COALESCE(NULLIF(TRIM(u.realname), ''), u.username)
           FROM sys_user u
           WHERE u.id = c.update_by AND c.update_by_name IS NULL`
        )
      }
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    const tables = await this.tablesWithCreateBy(queryRunner)
    for (const table of tables) {
      await queryRunner.query(`ALTER TABLE "${table}" DROP COLUMN IF EXISTS "update_by_name"`)
      await queryRunner.query(`ALTER TABLE "${table}" DROP COLUMN IF EXISTS "create_by_name"`)
    }
  }
}
