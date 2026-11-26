import { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 数据规则增加动作维度（MySQL 版），与 PG 版（1795080000000）同构。
 * action 默认 'all'，存量规则行为不变；精确匹配优先，未命中回退 all。
 */
export class DataRuleAction1795080000000 implements MigrationInterface {
  name = 'DataRuleAction1795080000000'

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`sys_data_rule\` ADD COLUMN \`action\` varchar(16) NOT NULL DEFAULT 'all' COMMENT '作用动作：all=读写通用（默认）/read/write/delete；精确匹配优先，未命中回退 all' AFTER \`resource\`, ADD INDEX \`idx_data_rule_action\` (\`tenant_id\`,\`resource\`,\`action\`,\`status\`)`
    )
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`sys_data_rule\` DROP INDEX \`idx_data_rule_action\`, DROP COLUMN \`action\``
    )
  }
}
