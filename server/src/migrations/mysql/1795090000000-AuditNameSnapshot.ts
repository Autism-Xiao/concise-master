import { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 审计人名字快照（MySQL 版），语义见 postgres 同名迁移。
 *
 * createBy/updateBy 存用户 ID，此前靠拦截器实时翻译名字，用户改名后历史
 * 记录会跟着变。这里给所有有 create_by 列的表加快照列，写入时固化当时的
 * 名字，拦截器仅对快照为空的历史数据回退实时查。表清单运行时动态取。
 */
export class AuditNameSnapshot1795090000000 implements MigrationInterface {
  name = 'AuditNameSnapshot1795090000000'

  private async tablesWithCreateBy(queryRunner: QueryRunner): Promise<string[]> {
    const rows: { table_name: string }[] = await queryRunner.query(
      `SELECT table_name FROM information_schema.columns
       WHERE table_schema = DATABASE() AND column_name = 'create_by'
       ORDER BY table_name`
    )
    return rows.map(row => row.table_name)
  }

  public async up(queryRunner: QueryRunner): Promise<void> {
    const tables = await this.tablesWithCreateBy(queryRunner)
    for (const table of tables) {
      await queryRunner.query(
        `ALTER TABLE \`${table}\` ADD COLUMN \`create_by_name\` varchar(64) NULL COMMENT '创建人名字快照（写入时固化，改名不影响历史）'`
      )
      await queryRunner.query(
        `ALTER TABLE \`${table}\` ADD COLUMN \`update_by_name\` varchar(64) NULL COMMENT '更新人名字快照（写入时固化，改名不影响历史）'`
      )
      // 回填：姓名优先、空则回退账号，两条独立 UPDATE 避免创建人/更新人错配
      await queryRunner.query(
        `UPDATE \`${table}\` c INNER JOIN sys_user u ON u.id = c.create_by
         SET c.create_by_name = COALESCE(NULLIF(TRIM(u.realname), ''), u.username)
         WHERE c.create_by_name IS NULL`
      )
      await queryRunner.query(
        `UPDATE \`${table}\` c INNER JOIN sys_user u ON u.id = c.update_by
         SET c.update_by_name = COALESCE(NULLIF(TRIM(u.realname), ''), u.username)
         WHERE c.update_by_name IS NULL`
      )
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    const tables = await this.tablesWithCreateBy(queryRunner)
    for (const table of tables) {
      await queryRunner.query(`ALTER TABLE \`${table}\` DROP COLUMN \`update_by_name\``)
      await queryRunner.query(`ALTER TABLE \`${table}\` DROP COLUMN \`create_by_name\``)
    }
  }
}
