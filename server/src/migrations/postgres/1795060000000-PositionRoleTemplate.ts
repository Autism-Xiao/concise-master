import { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 岗位默认角色模板（岗位 → 角色模板）—— PG 版
 *
 * 与 MySQL 版（migrations/mysql/1795060000000）同构：
 * - 新建 sys_position_role（岗位挂默认角色）
 * - sys_user_role 增加 source 列（manual=手动分配 / position=岗位模板带入）
 * - (user_id, role_id) 唯一键防止重复绑定行（ManyToMany 查询会因重复行返回重复角色）
 */
export class PositionRoleTemplate1795060000000 implements MigrationInterface {
  name = 'PositionRoleTemplate1795060000000'

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE IF NOT EXISTS "sys_position_role" (
        "id" varchar(32) NOT NULL,
        "position_id" varchar(32) NOT NULL,
        "role_id" varchar(32) NOT NULL,
        "tenant_id" int NOT NULL DEFAULT 0,
        "create_time" timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT "pk_position_role" PRIMARY KEY ("id")
      )`
    )
    await queryRunner.query(`CREATE UNIQUE INDEX IF NOT EXISTS "uk_position_role" ON "sys_position_role" ("position_id", "role_id")`)
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS "idx_position_role_role" ON "sys_position_role" ("role_id")`)
    await queryRunner.query(`COMMENT ON TABLE "sys_position_role" IS '岗位默认角色模板表'`)
    await queryRunner.query(`COMMENT ON COLUMN "sys_position_role"."position_id" IS '岗位ID（sys_position.id）'`)
    await queryRunner.query(`COMMENT ON COLUMN "sys_position_role"."role_id" IS '默认角色ID（sys_role.id）'`)
    await queryRunner.query(`COMMENT ON COLUMN "sys_position_role"."tenant_id" IS '租户ID(0=平台级)'`)
    // 已有绑定行一律视为手动分配；DEFAULT 保证未来裸 INSERT 也不会丢来源
    await queryRunner.query(`ALTER TABLE "sys_user_role" ADD COLUMN IF NOT EXISTS "source" varchar(16) NOT NULL DEFAULT 'manual'`)
    await queryRunner.query(`COMMENT ON COLUMN "sys_user_role"."source" IS '绑定来源：manual=手动分配 / position=岗位模板带入'`)
    await queryRunner.query(`CREATE UNIQUE INDEX IF NOT EXISTS "uk_user_role" ON "sys_user_role" ("user_id", "role_id")`)
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX IF EXISTS "uk_user_role"`)
    await queryRunner.query(`ALTER TABLE "sys_user_role" DROP COLUMN IF EXISTS "source"`)
    await queryRunner.query(`DROP TABLE IF EXISTS "sys_position_role"`)
  }
}
