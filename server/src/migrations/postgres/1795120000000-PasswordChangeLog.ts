import { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 密码修改记录表 + 操作日志按用户过滤所需索引
 *
 * 改密记录覆盖：自助改密 / 管理员重置 / 邮箱验证码找回 / 管理员编辑改密。
 * 成功率极高但只作审计用途，写失败由 service 吞掉，不影响改密主流程。
 */
export class PasswordChangeLog1795120000000 implements MigrationInterface {
  name = 'PasswordChangeLog1795120000000'

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE IF NOT EXISTS "sys_password_change_log" (
        "id" varchar(32) NOT NULL,
        "tenant_id" int NOT NULL DEFAULT 0,
        "user_id" varchar(32) NOT NULL,
        "username" varchar(100) NOT NULL,
        "change_type" varchar(16) NOT NULL,
        "operator_id" varchar(32) DEFAULT NULL,
        "operator_name" varchar(100) DEFAULT NULL,
        "ip" varchar(100) DEFAULT NULL,
        "user_agent" varchar(255) DEFAULT NULL,
        "remark" varchar(255) DEFAULT NULL,
        "create_time" timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT "pk_password_change_log" PRIMARY KEY ("id")
      )`
    )
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "idx_pwd_log_user_time" ON "sys_password_change_log" ("user_id", "create_time")`
    )
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "idx_pwd_log_tenant_time" ON "sys_password_change_log" ("tenant_id", "create_time")`
    )
    await queryRunner.query(`COMMENT ON TABLE "sys_password_change_log" IS '密码修改记录（自助改密/管理员重置/邮箱找回）'`)
    await queryRunner.query(
      `COMMENT ON COLUMN "sys_password_change_log"."change_type" IS 'self=自助改密 / admin_reset=管理员重置 / forgot=邮箱验证码找回 / admin_update=管理员编辑改密'`
    )
    // 操作日志按「操作人 ID」精确过滤（用户详情日志区用），原仅有按名字的索引
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "idx_sys_log_oper_user" ON "sys_log" ("tenant_id", "log_type", "operate_user_id", "create_time")`
    )
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX IF EXISTS "idx_sys_log_oper_user"`)
    await queryRunner.query(`DROP TABLE IF EXISTS "sys_password_change_log"`)
  }
}
