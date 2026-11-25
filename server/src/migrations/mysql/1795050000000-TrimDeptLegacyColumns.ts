import { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 精简 sys_depart：删除 11 个无业务价值的遗留字段。
 *
 * 保留 depart_name_en / depart_name_abbr（按用户要求保留，前端非必填录入）。
 * 删除的字段全库无代码引用、当前数据全为 NULL：
 * - org_type：与 org_category 语义重复
 * - mobile / fax / address / memo：部门不是联系人，联系方式挂人或岗位；memo 与 description 重复
 * - iz_leaf：可由 parent_id 实时推导，冗余
 * - qywx_identifier / ding_identifier / feishu_identifier：未接第三方同步
 * - position_id / dep_post_parent_id：岗位走独立 sys_post 表
 *
 * 用 DROP COLUMN 而非重建表，保留全部索引与数据。
 */
export class TrimDeptLegacyColumns1795050000000 implements MigrationInterface {
  name = 'TrimDeptLegacyColumns1795050000000'

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE sys_depart
         DROP COLUMN org_type,
         DROP COLUMN mobile,
         DROP COLUMN fax,
         DROP COLUMN address,
         DROP COLUMN memo,
         DROP COLUMN iz_leaf,
         DROP COLUMN qywx_identifier,
         DROP COLUMN ding_identifier,
         DROP COLUMN feishu_identifier,
         DROP COLUMN position_id,
         DROP COLUMN dep_post_parent_id`
    )
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE sys_depart
         ADD COLUMN org_type varchar(10) NULL COMMENT '树深度层级',
         ADD COLUMN mobile varchar(32) NULL COMMENT '手机号',
         ADD COLUMN fax varchar(32) NULL COMMENT '传真',
         ADD COLUMN address varchar(100) NULL COMMENT '地址',
         ADD COLUMN memo varchar(500) NULL COMMENT '备注',
         ADD COLUMN iz_leaf smallint NOT NULL DEFAULT 0 COMMENT '是否有叶子节点',
         ADD COLUMN qywx_identifier varchar(100) NULL COMMENT '企业微信ID',
         ADD COLUMN ding_identifier varchar(100) NULL COMMENT '钉钉ID',
         ADD COLUMN feishu_identifier varchar(100) NULL COMMENT '飞书ID',
         ADD COLUMN position_id varchar(32) NULL COMMENT '岗位ID',
         ADD COLUMN dep_post_parent_id varchar(32) NULL COMMENT '岗位父ID'`
    )
  }
}
