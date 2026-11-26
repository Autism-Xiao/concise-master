import type { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 授权管理 / 数据规则两个配置页的菜单节点。语义见 postgres 同名迁移。
 */
const MENUS = [
  { id: 'menu_grant', parent: 'menu_1', name: '授权管理', url: '/system/grant', perms: 'system:grant:list', type: 1, sort: 92, icon: 'ShieldCheck' },
  { id: 'menu_grant_write', parent: 'menu_grant', name: '授权维护', url: null, perms: 'system:grant:write', type: 2, sort: 1, icon: null },
  { id: 'menu_data_rule', parent: 'menu_1', name: '数据规则', url: '/system/data-rule', perms: 'system:rule:list', type: 1, sort: 93, icon: 'ListTree' },
  { id: 'menu_data_rule_write', parent: 'menu_data_rule', name: '规则维护', url: null, perms: 'system:rule:write', type: 2, sort: 1, icon: null }
]

export class AddGrantMenu1795100000000 implements MigrationInterface {
  name = 'AddGrantMenu1795100000000'

  public async up(queryRunner: QueryRunner): Promise<void> {
    for (const menu of MENUS) {
      await queryRunner.query(
        `INSERT IGNORE INTO \`sys_permission\`
          (\`id\`, \`parent_id\`, \`name\`, \`url\`, \`is_route\`, \`menu_type\`, \`perms\`, \`scope\`, \`perms_type\`, \`sort_no\`, \`always_show\`, \`icon\`, \`is_leaf\`, \`hidden\`, \`del_flag\`, \`rule_flag\`, \`status\`, \`internal_or_external\`, \`create_time\`, \`update_time\`)
         VALUES (?, ?, ?, ?, 1, ?, ?, 'tenant', '0', ?, 0, ?, ?, 0, 0, 0, '1', 0, NOW(), NOW())`,
        [menu.id, menu.parent, menu.name, menu.url, menu.type, menu.perms, menu.sort, menu.icon, menu.type === 2 ? 1 : 0]
      )
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    const ids = MENUS.map(menu => menu.id)
    const marks = ids.map(() => '?').join(',')
    await queryRunner.query(`DELETE FROM \`sys_role_permission\` WHERE \`permission_id\` IN (${marks})`, ids)
    await queryRunner.query(`DELETE FROM \`sys_permission\` WHERE \`id\` IN (${marks})`, ids)
  }
}
