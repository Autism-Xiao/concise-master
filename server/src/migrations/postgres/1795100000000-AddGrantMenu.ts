import type { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 授权管理 / 数据规则两个配置页的菜单节点
 *
 * 归属「系统管理」menu_1 下，权限码沿用 controller 里已有的常量：
 * - 授权管理：system:grant:list / system:grant:write
 * - 数据规则：system:rule:list   / system:rule:write
 *
 * scope=tenant：这是租户内的日常权限配置（与角色管理同口径），不是改全平台唯一资源。
 * 平台管理员全量可见；租户用户需由角色授予对应权限码。
 * 只加菜单和按钮节点，不预置任何角色绑定。
 * 固定 id + ON CONFLICT DO NOTHING，重复执行安全。
 */
const MENUS = [
  // 授权管理已内嵌到「用户管理 → 个人权限」Tab，菜单节点隐藏但保留权限码与底座
  { id: 'menu_grant', parent: 'menu_1', name: '授权管理', url: '/system/grant', perms: 'system:grant:list', type: 1, sort: 92, icon: 'ShieldCheck', hidden: 1 },
  { id: 'menu_grant_write', parent: 'menu_grant', name: '授权维护', url: null, perms: 'system:grant:write', type: 2, sort: 1, icon: null, hidden: 1 },
  { id: 'menu_data_rule', parent: 'menu_1', name: '数据规则', url: '/system/data-rule', perms: 'system:rule:list', type: 1, sort: 93, icon: 'ListTree', hidden: 0 },
  { id: 'menu_data_rule_write', parent: 'menu_data_rule', name: '规则维护', url: null, perms: 'system:rule:write', type: 2, sort: 1, icon: null, hidden: 0 }
]

export class AddGrantMenu1795100000000 implements MigrationInterface {
  name = 'AddGrantMenu1795100000000'

  public async up(queryRunner: QueryRunner): Promise<void> {
    for (const menu of MENUS) {
      await queryRunner.query(
        `INSERT INTO "sys_permission"
          ("id", "parent_id", "name", "url", "is_route", "menu_type", "perms", "scope", "perms_type", "sort_no", "always_show", "icon", "is_leaf", "hidden", "del_flag", "rule_flag", "status", "internal_or_external", "create_time", "update_time")
         VALUES ($1, $2, $3, $4, 1, $5, $6, 'tenant', '0', $7, 0, $8, $9, $10, 0, 0, '1', 0, now(), now())
         ON CONFLICT ("id") DO NOTHING`,
        [menu.id, menu.parent, menu.name, menu.url, menu.type, menu.perms, menu.sort, menu.icon, menu.type === 2 ? 1 : 0, menu.hidden]
      )
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    const ids = MENUS.map(menu => menu.id)
    await queryRunner.query(`DELETE FROM "sys_role_permission" WHERE "permission_id" = ANY($1::varchar[])`, [ids])
    await queryRunner.query(`DELETE FROM "sys_permission" WHERE "id" = ANY($1::varchar[])`, [ids])
  }
}
