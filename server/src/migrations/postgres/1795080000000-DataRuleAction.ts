import { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 数据规则增加动作维度（PG 版）：权限模型的正交维度补齐
 *
 * 权限本来就是 主体 × 资源 × 动作 × 范围 四维，此前 sys_data_rule 只有资源与范围，
 * 导致「部门内都能看、只能改自己的」这类需求无法表达（读写共用一套条件）。
 *
 * action 默认 'all'：**存量规则行为完全不变**——解析时优先取动作精确匹配的规则，
 * 没有精确匹配才回退 all，再没有就回退角色 data_scope。
 * 这样底座先具备表达能力，业务什么时候有需求什么时候配，不用再改代码。
 *
 * 参照：Odoo ir.rule 按 perm_read/perm_write/perm_unlink 分别标记；
 *       Salesforce OWD 的 Public Read-Only 档同样是「读写不同范围」。
 */
export class DataRuleAction1795080000000 implements MigrationInterface {
  name = 'DataRuleAction1795080000000'

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "sys_data_rule" ADD COLUMN IF NOT EXISTS "action" varchar(16) NOT NULL DEFAULT 'all'`
    )
    await queryRunner.query(
      `COMMENT ON COLUMN "sys_data_rule"."action" IS '作用动作：all=读写通用（默认）/ read / write / delete；精确匹配优先，未命中回退 all'`
    )
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "idx_data_rule_action" ON "sys_data_rule" ("tenant_id", "resource", "action", "status")`
    )
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX IF EXISTS "idx_data_rule_action"`)
    await queryRunner.query(`ALTER TABLE "sys_data_rule" DROP COLUMN IF EXISTS "action"`)
  }
}
