import type { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 新建用户「默认密码」配置项：
 *
 * security.password.default —— 新建用户未填密码时使用的初始密码。
 * 建号时不走强度校验（该值由管理员在系统配置页维护），但会强制 mustChangePassword=1，
 * 用户首次登录必须自行修改；因此这里预置一个弱口令仅为开箱可用，生产环境务必改掉。
 * 配置留空时，UserService.create 会回退到随机口令（明文不再下发，需管理员重置）。
 *
 * 平台级（allow_tenant=0），与其余 security.* 一致；固定 key + ON CONFLICT DO NOTHING，重复执行安全。
 */
export class DefaultPasswordConfig1795110000000 implements MigrationInterface {
  name = 'DefaultPasswordConfig1795110000000'

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `INSERT INTO sys_config (config_key, config_value, value_type, config_group, name, remark, is_builtin, allow_tenant, del_flag, created_at, updated_at)
       VALUES ('security.password.default', '123456', 'string', 'security', '新建用户默认密码',
               '新建用户未填密码时使用的初始密码；用户首次登录强制修改。留空则回退随机口令。生产环境请务必修改此值', 1, 0, 0, now(), now())
       ON CONFLICT (tenant_id, config_key) DO NOTHING`
    )
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DELETE FROM sys_config WHERE config_key = 'security.password.default'`)
  }
}
