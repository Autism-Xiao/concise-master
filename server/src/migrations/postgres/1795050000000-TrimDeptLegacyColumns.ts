import { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * PostgreSQL 同步精简 sys_depart（对应 MySQL 1795050000000）。
 *
 * 删除 11 个无代码引用、当前数据全 NULL 的遗留字段；
 * 保留 depart_name_en / depart_name_abbr（用户要求保留，前端非必填）。
 * 用 IF EXISTS 保证幂等，避免两边迁移进度不一致时报错。
 */
export class TrimDeptLegacyColumns1795050000000 implements MigrationInterface {
  name = 'TrimDeptLegacyColumns1795050000000'

  private readonly columns = [
    'org_type',
    'mobile',
    'fax',
    'address',
    'memo',
    'iz_leaf',
    'qywx_identifier',
    'ding_identifier',
    'feishu_identifier',
    'position_id',
    'dep_post_parent_id'
  ]

  public async up(queryRunner: QueryRunner): Promise<void> {
    for (const col of this.columns) {
      await queryRunner.query(`ALTER TABLE sys_depart DROP COLUMN IF EXISTS "${col}"`)
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE sys_depart
         ADD COLUMN IF NOT EXISTS org_type varchar(10),
         ADD COLUMN IF NOT EXISTS mobile varchar(32),
         ADD COLUMN IF NOT EXISTS fax varchar(32),
         ADD COLUMN IF NOT EXISTS address varchar(100),
         ADD COLUMN IF NOT EXISTS memo varchar(500),
         ADD COLUMN IF NOT EXISTS iz_leaf smallint NOT NULL DEFAULT 0,
         ADD COLUMN IF NOT EXISTS qywx_identifier varchar(100),
         ADD COLUMN IF NOT EXISTS ding_identifier varchar(100),
         ADD COLUMN IF NOT EXISTS feishu_identifier varchar(100),
         ADD COLUMN IF NOT EXISTS position_id varchar(32),
         ADD COLUMN IF NOT EXISTS dep_post_parent_id varchar(32)`
    )
  }
}
