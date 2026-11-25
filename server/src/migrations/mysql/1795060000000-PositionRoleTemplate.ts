import { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 岗位默认角色模板（岗位 → 角色模板）
 *
 * 背景：sys_user_role 的绑定此前完全靠管理员逐个勾选，入职/调岗的批量授权成为日常负担。
 * 本表让岗位可以挂一组「默认角色」，用户挂岗即自动获得（写入 sys_user_role 且 source='position'），
 * 调岗/摘岗自动回收岗位来源的角色，管理员手动分配的（source='manual'）永远不动。
 *
 * 设计要点：
 * - sys_user_role 增加 source 列区分绑定来源：manual=管理员手动分配（用户管理界面勾选），
 *   position=岗位模板带入（自动同步）。生效时两者取并集（与多角色并集口径一致）。
 * - (user_id, role_id) 唯一键：同一用户同一角色只允许一行绑定，避免重复行导致
 *   ManyToMany 查询出重复角色；来源互换（手动↔岗位）是「删一行、补一行」而不是并存。
 * - 不新增权限点：配置入口复用 system:post:list / system:post:update，存量租户无需 provision-all。
 */
export class PositionRoleTemplate1795060000000 implements MigrationInterface {
  name = 'PositionRoleTemplate1795060000000'

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE IF NOT EXISTS \`sys_position_role\` (
        \`id\` varchar(32) NOT NULL COMMENT 'ID',
        \`position_id\` varchar(32) NOT NULL COMMENT '岗位ID（sys_position.id）',
        \`role_id\` varchar(32) NOT NULL COMMENT '默认角色ID（sys_role.id）',
        \`tenant_id\` int NOT NULL DEFAULT 0 COMMENT '租户ID(0=平台级)',
        \`create_time\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
        PRIMARY KEY (\`id\`),
        UNIQUE KEY \`uk_position_role\` (\`position_id\`, \`role_id\`),
        KEY \`idx_position_role_role\` (\`role_id\`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='岗位默认角色模板表'`
    )
    await queryRunner.query(
      "ALTER TABLE `sys_user_role` ADD COLUMN `source` varchar(16) NOT NULL DEFAULT 'manual' COMMENT '绑定来源：manual=手动分配 / position=岗位模板带入'"
    )
    await queryRunner.query('CREATE UNIQUE INDEX `uk_user_role` ON `sys_user_role` (`user_id`, `role_id`)')
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP INDEX `uk_user_role` ON `sys_user_role`')
    await queryRunner.query('ALTER TABLE `sys_user_role` DROP COLUMN `source`')
    await queryRunner.query('DROP TABLE IF EXISTS `sys_position_role`')
  }
}
