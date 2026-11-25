import type { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 补齐前端页面登记表里已有、但 sys_permission 从未落库的菜单：
 * 角色/菜单/租户/岗位/职级/文件/区域/日程、登录/操作日志、运维监控整组。
 * 用固定 id + ON CONFLICT DO NOTHING，重复执行安全；MySQL 侧由对应迁移同步。
 */
interface MenuSeed {
  id: string
  parentId: string | null
  name: string
  url: string
  menuType: number
  sort: number
  icon: string
  scope: string
}

const GROUPS: MenuSeed[] = [{ id: 'menu_ops', parentId: null, name: '运维监控', url: '/ops', menuType: 0, sort: 70, icon: 'Activity', scope: 'platform' }]

const LEAVES: MenuSeed[] = [
  // 系统管理
  { id: 'menu_role', parentId: 'menu_1', name: '角色管理', url: '/system/role', menuType: 1, sort: 3, icon: 'ShieldCheck', scope: 'tenant' },
  { id: 'menu_menu', parentId: 'menu_1', name: '菜单管理', url: '/system/menu', menuType: 1, sort: 5, icon: 'ListTree', scope: 'platform' },
  { id: 'menu_post', parentId: 'menu_1', name: '岗位管理', url: '/system/post', menuType: 1, sort: 7, icon: 'Briefcase', scope: 'tenant' },
  { id: 'menu_level', parentId: 'menu_1', name: '职级管理', url: '/system/level', menuType: 1, sort: 8, icon: 'Medal', scope: 'tenant' },
  { id: 'menu_tenant', parentId: 'menu_1', name: '租户管理', url: '/system/tenant', menuType: 1, sort: 11, icon: 'Building2', scope: 'platform' },
  { id: 'menu_file', parentId: 'menu_1', name: '文件管理', url: '/system/file', menuType: 1, sort: 12, icon: 'FolderOpen', scope: 'tenant' },
  { id: 'menu_region', parentId: 'menu_1', name: '区域管理', url: '/system/region', menuType: 1, sort: 13, icon: 'MapPin', scope: 'tenant' },
  { id: 'menu_calendar', parentId: 'menu_1', name: '日程管理', url: '/system/calendar', menuType: 1, sort: 14, icon: 'CalendarDays', scope: 'tenant' },
  // 数据管理
  { id: 'menu_log_login', parentId: 'menu_data', name: '登录日志', url: '/system/log/login', menuType: 1, sort: 2, icon: 'LogIn', scope: 'tenant' },
  {
    id: 'menu_log_operation',
    parentId: 'menu_data',
    name: '操作日志',
    url: '/system/log/operation',
    menuType: 1,
    sort: 3,
    icon: 'ScrollText',
    scope: 'tenant'
  },
  // 运维监控
  { id: 'menu_ops_server', parentId: 'menu_ops', name: '服务监控', url: '/ops/server', menuType: 1, sort: 1, icon: 'Activity', scope: 'platform' },
  { id: 'menu_ops_cache', parentId: 'menu_ops', name: '缓存监控', url: '/ops/cache', menuType: 1, sort: 2, icon: 'Database', scope: 'platform' },
  { id: 'menu_ops_job', parentId: 'menu_ops', name: '定时任务', url: '/ops/job', menuType: 1, sort: 3, icon: 'Clock', scope: 'platform' },
  { id: 'menu_ops_online', parentId: 'menu_ops', name: '在线用户', url: '/ops/online', menuType: 1, sort: 4, icon: 'Users', scope: 'platform' }
]

export class Migration1794080000004 implements MigrationInterface {
  name = 'Migration1794080000004'

  public async up(queryRunner: QueryRunner): Promise<void> {
    for (const menu of [...GROUPS, ...LEAVES]) {
      await queryRunner.query(
        `INSERT INTO "sys_permission"
          ("id", "parent_id", "name", "url", "is_route", "menu_type", "scope", "perms_type", "sort_no", "always_show", "icon", "is_leaf", "hidden", "del_flag", "rule_flag", "status", "internal_or_external", "create_time", "update_time")
         VALUES ($1, $2, $3, $4, 1, $5, $6, '0', $7, 1, $8, 1, 0, 0, 0, '1', 0, now(), now())
         ON CONFLICT ("id") DO NOTHING`,
        [menu.id, menu.parentId, menu.name, menu.url, menu.menuType, menu.scope, menu.sort, menu.icon]
      )
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    const ids = [...GROUPS, ...LEAVES].map(menu => menu.id)
    await queryRunner.query(`DELETE FROM "sys_permission" WHERE "id" = ANY($1::varchar[])`, [ids])
  }
}
