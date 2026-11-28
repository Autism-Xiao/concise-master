import type { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 新建用户「默认密码」配置项（MySQL 侧，与 PG 对齐）。
 * security.password.default —— 建号未填密码时的初始密码，强制首次登录修改。
 * 预置弱口令仅为开箱可用，生产环境务必在系统配置页改掉。
 */
export class DefaultPasswordConfig1795110000000 implements MigrationInterface {
  name = 'DefaultPasswordConfig1795110000000'

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `INSERT INTO sys_config (config_key, config_value, value_type, config_group, name, remark, is_builtin, allow_tenant, del_flag, created_at, updated_at)
       VALUES ('security.password.default', '123456', 'string', 'security', '新建用户默认密码',
               '新建用户未填密码时使用的初始密码；用户首次登录强制修改。留空则回退随机口令。生产环境请务必修改此值', 1, 0, 0, NOW(), NOW())`
    )
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query("DELETE FROM sys_config WHERE config_key = 'security.password.default'")
  }
}
