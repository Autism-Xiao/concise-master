import { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 角色/权限关联表去重并加唯一索引
 *
 * 背景：sys_user_role、sys_role_permission 采用带独立主键的结构，
 * 只有普通索引，重复执行「授权」会插入重复关联行（同一角色同一菜单多行）。
 * 无唯一约束时权限查询结果虽然正确但数据脏，这里先清理重复再补唯一键。
 */
export class Migration1793767136137 implements MigrationInterface {
  name = 'Migration1793767136137'

  /**
   * 仅当索引存在时才 DROP（幂等）：
   * 全新库的建表迁移（1793766529976）已直接带 uniq 唯一键，旧索引根本不存在，
   * 硬 DROP 会让「空库全新安装」在链上此处中断。
   */
  private async dropIndexIfExists(queryRunner: QueryRunner, table: string, index: string): Promise<void> {
    const [row] = (await queryRunner.query(
      'SELECT COUNT(*) AS cnt FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = ? AND index_name = ?',
      [table, index]
    )) as Array<{ cnt: number }>
    if (Number(row?.cnt ?? 0) > 0) {
      await queryRunner.query(`ALTER TABLE \`${table}\` DROP INDEX \`${index}\``)
    }
  }

  /** 仅当唯一键不存在时才 ADD（全新库的建表迁移已带 uniq，重复 ADD 会报 Duplicate key name） */
  private async addUniqueKeyIfNotExists(queryRunner: QueryRunner, table: string, index: string, columns: string): Promise<void> {
    const [row] = (await queryRunner.query(
      'SELECT COUNT(*) AS cnt FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = ? AND index_name = ?',
      [table, index]
    )) as Array<{ cnt: number }>
    if (Number(row?.cnt ?? 0) === 0) {
      await queryRunner.query(`ALTER TABLE \`${table}\` ADD UNIQUE KEY \`${index}\` (${columns})`)
    }
  }

  public async up(queryRunner: QueryRunner): Promise<void> {
    // sys_user_role：保留每组 (user_id, role_id) 中 id 最小的一行
    await queryRunner.query(`DELETE u1 FROM \`sys_user_role\` u1
      JOIN \`sys_user_role\` u2
        ON u1.\`user_id\` = u2.\`user_id\` AND u1.\`role_id\` = u2.\`role_id\` AND u1.\`id\` > u2.\`id\``)
    await this.dropIndexIfExists(queryRunner, 'sys_user_role', 'idx_sur_user_role_id')
    await this.addUniqueKeyIfNotExists(queryRunner, 'sys_user_role', 'uniq_sur_user_role', '`user_id`, `role_id`')

    // sys_role_permission：同上
    await queryRunner.query(`DELETE r1 FROM \`sys_role_permission\` r1
      JOIN \`sys_role_permission\` r2
        ON r1.\`role_id\` = r2.\`role_id\` AND r1.\`permission_id\` = r2.\`permission_id\` AND r1.\`id\` > r2.\`id\``)
    await this.dropIndexIfExists(queryRunner, 'sys_role_permission', 'idx_srp_role_per_id')
    await this.addUniqueKeyIfNotExists(queryRunner, 'sys_role_permission', 'uniq_srp_role_permission', '`role_id`, `permission_id`')
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE `sys_role_permission` DROP INDEX `uniq_srp_role_permission`')
    await queryRunner.query('ALTER TABLE `sys_role_permission` ADD KEY `idx_srp_role_per_id` (`role_id`, `permission_id`)')
    await queryRunner.query('ALTER TABLE `sys_user_role` DROP INDEX `uniq_sur_user_role`')
    await queryRunner.query('ALTER TABLE `sys_user_role` ADD KEY `idx_sur_user_role_id` (`user_id`, `role_id`)')
  }
}
