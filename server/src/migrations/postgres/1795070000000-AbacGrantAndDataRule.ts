import { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * 窄口径 ABAC：数据规则 + 授权行 —— PG 版
 *
 * 与 MySQL 版（migrations/mysql/1795070000000）同构。两张表解决两件事，互不重叠：
 *
 * 1. sys_data_rule（数据规则）
 *    JeecgBoot sys_permission_data_rule 的同构物：一条规则 = 资源 + 字段 + 运算符 + 值。
 *    只描述「哪些行可见」，不关心「谁」，可以被多条授权复用。
 *    字段/运算符由后端白名单校验后翻译成 QueryBuilder 条件（参数化，不拼字符串）。
 *
 * 2. sys_grant（授权行）
 *    RBAC 之外的例外授权：主体（用户/部门/岗位/角色）+ 权限点 + 可选的规则约束。
 *    有了它，跨部门临时授权不需要新建角色 —— 角色继续只承载「职能」。
 *
 * 为什么规则挂 grant 而不是直接挂角色：同一权限点在不同资源上需要不同可见范围
 * （小王订单看全部、客户只看自己），角色级 data_scope 表达不了；规则绑定到授权行即可。
 * 未命中任何 grant 时，业务查询回退旧的 data_scope 逻辑，保证存量行为不变。
 */
export class AbacGrantAndDataRule1795070000000 implements MigrationInterface {
  name = 'AbacGrantAndDataRule1795070000000'

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE IF NOT EXISTS "sys_data_rule" (
        "id" varchar(32) NOT NULL,
        "tenant_id" int NOT NULL DEFAULT 0,
        "name" varchar(100) NOT NULL,
        "resource" varchar(64) NOT NULL,
        "rule_field" varchar(64) NOT NULL,
        "rule_operator" varchar(16) NOT NULL,
        "rule_value" varchar(500) DEFAULT NULL,
        "rule_effect" varchar(8) NOT NULL DEFAULT 'allow',
        "priority" int NOT NULL DEFAULT 100,
        "status" smallint NOT NULL DEFAULT 1,
        "del_flag" smallint NOT NULL DEFAULT 0,
        "create_by" varchar(32) DEFAULT NULL,
        "create_time" timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
        "update_by" varchar(32) DEFAULT NULL,
        "update_time" timestamp(3) DEFAULT NULL,
        CONSTRAINT "pk_data_rule" PRIMARY KEY ("id")
      )`
    )
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS "idx_data_rule_res" ON "sys_data_rule" ("tenant_id", "resource", "status")`)
    await queryRunner.query(`COMMENT ON TABLE "sys_data_rule" IS '数据权限规则表（窄口径 ABAC）'`)
    await queryRunner.query(`COMMENT ON COLUMN "sys_data_rule"."resource" IS '资源标识：biz_order / customer / supplier'`)
    await queryRunner.query(`COMMENT ON COLUMN "sys_data_rule"."rule_field" IS '过滤字段（实体属性名，白名单校验）'`)
    await queryRunner.query(
      `COMMENT ON COLUMN "sys_data_rule"."rule_operator" IS '运算符：eq/ne/gt/gte/lt/lte/in/not_in/like/self/dept'`
    )
    await queryRunner.query(`COMMENT ON COLUMN "sys_data_rule"."rule_value" IS '规则值：固定值，或 $user.id / $user.deptIds 上下文变量'`)
    await queryRunner.query(`COMMENT ON COLUMN "sys_data_rule"."rule_effect" IS '效果：allow=放行 / deny=排除'`)

    await queryRunner.query(
      `CREATE TABLE IF NOT EXISTS "sys_grant" (
        "id" varchar(32) NOT NULL,
        "tenant_id" int NOT NULL DEFAULT 0,
        "subject_type" varchar(16) NOT NULL,
        "subject_id" varchar(32) NOT NULL,
        "permission_id" varchar(32) NOT NULL,
        "rule_id" varchar(32) DEFAULT NULL,
        "rule_effect" varchar(8) NOT NULL DEFAULT 'allow',
        "expire_at" timestamp(3) DEFAULT NULL,
        "reason" varchar(255) DEFAULT NULL,
        "status" smallint NOT NULL DEFAULT 1,
        "del_flag" smallint NOT NULL DEFAULT 0,
        "grant_by" varchar(32) DEFAULT NULL,
        "create_time" timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
        "update_time" timestamp(3) DEFAULT NULL,
        CONSTRAINT "pk_grant" PRIMARY KEY ("id")
      )`
    )
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "idx_grant_subject" ON "sys_grant" ("tenant_id", "subject_type", "subject_id", "status")`
    )
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS "idx_grant_permission" ON "sys_grant" ("permission_id")`)
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS "idx_grant_expire" ON "sys_grant" ("expire_at")`)
    await queryRunner.query(`COMMENT ON TABLE "sys_grant" IS '例外授权表（主体级授权，RBAC 的补充）'`)
    await queryRunner.query(`COMMENT ON COLUMN "sys_grant"."subject_type" IS '授权主体：user / dept / position / role'`)
    await queryRunner.query(`COMMENT ON COLUMN "sys_grant"."subject_id" IS '主体 ID（sys_user/sys_depart/sys_position/sys_role 的主键）'`)
    await queryRunner.query(`COMMENT ON COLUMN "sys_grant"."permission_id" IS '权限点 ID（sys_permission.id）'`)
    await queryRunner.query(`COMMENT ON COLUMN "sys_grant"."rule_id" IS '可选：绑定的数据规则（sys_data_rule.id）'`)
    await queryRunner.query(`COMMENT ON COLUMN "sys_grant"."expire_at" IS '过期时间，NULL=永久；过期行在判定时直接忽略'`)
    await queryRunner.query(`COMMENT ON COLUMN "sys_grant"."reason" IS '授权理由（审计用）'`)

    // 授权/规则自身的按钮权限：挂在「角色权限」菜单（menu_40）下，不建前端路由节点，
    // 避免出现点进去 404 的空菜单；scope=tenant 让租户管理员可以给自己的租户配授权。
    await queryRunner.query(
      `INSERT INTO "sys_permission"
        ("id","parent_id","name","menu_type","perms","scope","perms_type","is_route","hidden","del_flag","rule_flag","status","sort_no","create_time")
       VALUES
        ('grant_perm_list','menu_40','授权查看',2,'system:grant:list','tenant','0',1,0,0,0,'1',10,CURRENT_TIMESTAMP),
        ('grant_perm_write','menu_40','授权维护',2,'system:grant:write','tenant','0',1,0,0,0,'1',11,CURRENT_TIMESTAMP),
        ('rule_perm_list','menu_40','规则查看',2,'system:rule:list','tenant','0',1,0,0,0,'1',12,CURRENT_TIMESTAMP),
        ('rule_perm_write','menu_40','规则维护',2,'system:rule:write','tenant','0',1,0,0,0,'1',13,CURRENT_TIMESTAMP)
       ON CONFLICT ("id") DO NOTHING`
    )
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "sys_grant"`)
    await queryRunner.query(`DROP TABLE IF EXISTS "sys_data_rule"`)
  }
}
