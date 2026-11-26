import { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 窄口径 ABAC：数据规则 + 授权行 —— MySQL 版
 *
 * 与 PG 版（migrations/postgres/1795070000000）同构，字段名/语义完全一致，
 * 差异只在方言：反引号、datetime(3)、内联 KEY、表/列 COMMENT。
 */
export class AbacGrantAndDataRule1795070000000 implements MigrationInterface {
  name = 'AbacGrantAndDataRule1795070000000'

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE IF NOT EXISTS \`sys_data_rule\` (
        \`id\` varchar(32) NOT NULL COMMENT 'ID',
        \`tenant_id\` int NOT NULL DEFAULT 0 COMMENT '租户ID(0=平台级)',
        \`name\` varchar(100) NOT NULL COMMENT '规则名称',
        \`resource\` varchar(64) NOT NULL COMMENT '资源标识：biz_order/customer/supplier',
        \`rule_field\` varchar(64) NOT NULL COMMENT '过滤字段（实体属性名，白名单校验）',
        \`rule_operator\` varchar(16) NOT NULL COMMENT '运算符：eq/ne/gt/gte/lt/lte/in/not_in/like/self/dept',
        \`rule_value\` varchar(500) DEFAULT NULL COMMENT '规则值：固定值或 $user.id / $user.deptIds',
        \`rule_effect\` varchar(8) NOT NULL DEFAULT 'allow' COMMENT '效果：allow=放行 / deny=排除',
        \`priority\` int NOT NULL DEFAULT 100 COMMENT '优先级（数值小的先应用）',
        \`status\` smallint NOT NULL DEFAULT 1 COMMENT '状态：1正常 0停用',
        \`del_flag\` smallint NOT NULL DEFAULT 0 COMMENT '0正常 1已删除',
        \`create_by\` varchar(32) DEFAULT NULL COMMENT '创建人',
        \`create_time\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
        \`update_by\` varchar(32) DEFAULT NULL COMMENT '更新人',
        \`update_time\` datetime(3) DEFAULT NULL COMMENT '更新时间',
        PRIMARY KEY (\`id\`),
        KEY \`idx_data_rule_res\` (\`tenant_id\`, \`resource\`, \`status\`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据权限规则表（窄口径 ABAC）'`
    )

    await queryRunner.query(
      `CREATE TABLE IF NOT EXISTS \`sys_grant\` (
        \`id\` varchar(32) NOT NULL COMMENT 'ID',
        \`tenant_id\` int NOT NULL DEFAULT 0 COMMENT '租户ID(0=平台级)',
        \`subject_type\` varchar(16) NOT NULL COMMENT '授权主体：user/dept/position/role',
        \`subject_id\` varchar(32) NOT NULL COMMENT '主体ID',
        \`permission_id\` varchar(32) NOT NULL COMMENT '权限点ID（sys_permission.id）',
        \`rule_id\` varchar(32) DEFAULT NULL COMMENT '可选：绑定的数据规则（sys_data_rule.id）',
        \`rule_effect\` varchar(8) NOT NULL DEFAULT 'allow' COMMENT '效果：allow/deny',
        \`expire_at\` datetime(3) DEFAULT NULL COMMENT '过期时间，NULL=永久',
        \`reason\` varchar(255) DEFAULT NULL COMMENT '授权理由（审计用）',
        \`status\` smallint NOT NULL DEFAULT 1 COMMENT '状态：1正常 0停用',
        \`del_flag\` smallint NOT NULL DEFAULT 0 COMMENT '0正常 1已删除',
        \`grant_by\` varchar(32) DEFAULT NULL COMMENT '授权人',
        \`create_time\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
        \`update_time\` datetime(3) DEFAULT NULL COMMENT '更新时间',
        PRIMARY KEY (\`id\`),
        KEY \`idx_grant_subject\` (\`tenant_id\`, \`subject_type\`, \`subject_id\`, \`status\`),
        KEY \`idx_grant_permission\` (\`permission_id\`),
        KEY \`idx_grant_expire\` (\`expire_at\`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='例外授权表（主体级授权，RBAC 的补充）'`
    )

    // 授权/规则自身的按钮权限：挂在「角色权限」菜单（menu_40）下，不建前端路由节点
    await queryRunner.query(
      `INSERT IGNORE INTO \`sys_permission\`
        (\`id\`,\`parent_id\`,\`name\`,\`menu_type\`,\`perms\`,\`scope\`,\`perms_type\`,\`is_route\`,\`hidden\`,\`del_flag\`,\`rule_flag\`,\`status\`,\`sort_no\`,\`create_time\`)
       VALUES
        ('grant_perm_list','menu_40','授权查看',2,'system:grant:list','tenant','0',1,0,0,0,'1',10,NOW(3)),
        ('grant_perm_write','menu_40','授权维护',2,'system:grant:write','tenant','0',1,0,0,0,'1',11,NOW(3)),
        ('rule_perm_list','menu_40','规则查看',2,'system:rule:list','tenant','0',1,0,0,0,'1',12,NOW(3)),
        ('rule_perm_write','menu_40','规则维护',2,'system:rule:write','tenant','0',1,0,0,0,'1',13,NOW(3))`
    )
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP TABLE IF EXISTS `sys_grant`')
    await queryRunner.query('DROP TABLE IF EXISTS `sys_data_rule`')
  }
}
