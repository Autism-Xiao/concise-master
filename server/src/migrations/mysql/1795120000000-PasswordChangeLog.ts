import { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 密码修改记录表 + 操作日志按用户过滤所需索引（MySQL 版）
 */
export class PasswordChangeLog1795120000000 implements MigrationInterface {
  name = 'PasswordChangeLog1795120000000'

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE IF NOT EXISTS \`sys_password_change_log\` (
        \`id\` varchar(32) NOT NULL COMMENT 'ID',
        \`tenant_id\` int NOT NULL DEFAULT 0 COMMENT '租户ID(0=平台级)',
        \`user_id\` varchar(32) NOT NULL COMMENT '被改密用户ID',
        \`username\` varchar(100) NOT NULL COMMENT '被改密用户账号快照（改名不影响历史）',
        \`change_type\` varchar(16) NOT NULL COMMENT 'self/admin_reset/forgot/admin_update',
        \`operator_id\` varchar(32) DEFAULT NULL COMMENT '操作人ID',
        \`operator_name\` varchar(100) DEFAULT NULL COMMENT '操作人账号快照',
        \`ip\` varchar(100) DEFAULT NULL COMMENT '来源IP',
        \`user_agent\` varchar(255) DEFAULT NULL COMMENT '来源UA',
        \`remark\` varchar(255) DEFAULT NULL COMMENT '备注',
        \`create_time\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '改密时间',
        PRIMARY KEY (\`id\`),
        KEY \`idx_pwd_log_user_time\` (\`user_id\`,\`create_time\`),
        KEY \`idx_pwd_log_tenant_time\` (\`tenant_id\`,\`create_time\`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='密码修改记录'`
    )
    await queryRunner.query(
      `ALTER TABLE \`sys_log\` ADD INDEX \`idx_sys_log_oper_user\` (\`tenant_id\`,\`log_type\`,\`operate_user_id\`,\`create_time\`)`
    )
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE \`sys_log\` DROP INDEX \`idx_sys_log_oper_user\``)
    await queryRunner.query(`DROP TABLE IF EXISTS \`sys_password_change_log\``)
  }
}
