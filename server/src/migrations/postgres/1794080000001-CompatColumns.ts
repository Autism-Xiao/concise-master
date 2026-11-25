import type { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * PG 基线补齐：历史上由 MySQL 迁移追加、但实体未声明的列。
 *
 * 这些列不在 entity 里（老代码遗留/原生 SQL 使用），用 schema:sync 建库时不会生成。
 * 全部用 IF NOT EXISTS，重复执行安全。
 */
export class Migration1794080000001 implements MigrationInterface {
  name = 'Migration1794080000001'

  public async up(queryRunner: QueryRunner): Promise<void> {
    const alter = async (table: string, column: string, definition: string) => {
      await queryRunner.query(`ALTER TABLE "${table}" ADD COLUMN IF NOT EXISTS "${column}" ${definition}`)
    }

    // 组织/岗位标识（历史 jeecg 兼容列）
    await alter('sys_depart', 'qywx_identifier', 'varchar(100)')
    await alter('sys_depart', 'ding_identifier', 'varchar(100)')
    await alter('sys_depart', 'feishu_identifier', 'varchar(100)')
    await alter('sys_depart', 'position_id', 'varchar(32)')
    await alter('sys_depart', 'dep_post_parent_id', 'varchar(32)')

    // 角色权限关联表历史列
    await alter('sys_role_permission', 'id', "varchar(32) NOT NULL DEFAULT ''")
    await alter('sys_role_permission', 'data_rule_ids', 'varchar(1000)')
    await alter('sys_role_permission', 'operate_date', 'timestamp')
    await alter('sys_role_permission', 'operate_ip', 'varchar(100)')

    await alter('sys_tenant_usage', 'created_at', 'timestamp NOT NULL DEFAULT now()')

    // 用户表历史扩展列：第三方登录、流程引擎、签到、组织岗位等
    await alter('sys_user', 'third_id', 'varchar(100)')
    await alter('sys_user', 'third_type', 'varchar(100)')
    await alter('sys_user', 'activiti_sync', 'smallint')
    await alter('sys_user', 'user_identity', 'smallint')
    await alter('sys_user', 'client_id', 'varchar(64)')
    await alter('sys_user', 'login_tenant_id', 'integer')
    await alter('sys_user', 'bpm_status', 'varchar(2)')
    await alter('sys_user', 'sign_enable', 'smallint')
    await alter('sys_user', 'sign', 'varchar(500)')
    await alter('sys_user', 'main_dep_post_id', 'varchar(32)')
    await alter('sys_user', 'position_type', 'varchar(32)')
    await alter('sys_user', 'last_pwd_update_time', 'timestamp')
    await alter('sys_user', 'sort', 'integer')
    await alter('sys_user', 'iz_hide_contact', 'varchar(1)')

    await alter('sys_user_depart', 'ID', "varchar(32) NOT NULL DEFAULT ''")
    await alter('sys_user_role', 'id', "varchar(32) NOT NULL DEFAULT ''")
    await alter('sys_user_role', 'tenant_id', 'integer')
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // 基线兼容列不做回滚（数据可能已写入）
    void queryRunner
  }
}
