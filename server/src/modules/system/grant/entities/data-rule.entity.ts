import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { Column, Entity, PrimaryColumn } from 'typeorm'

/**
 * 数据权限规则（窄口径 ABAC）
 *
 * 一条规则只回答「哪些行可见」，不关心「谁可见」——主体由 sys_grant 绑定。
 * 这样同一条「仅本人」规则可以被多个用户/部门复用，避免规则表按人膨胀。
 *
 * 翻译成 SQL 由 data-policy.util 负责，三条安全约束：
 * 1. rule_field 必须是资源实体的真实列（白名单，防注入到 order by / 子查询）；
 * 2. rule_operator 必须是枚举内的值（不支持任意表达式，也就不存在表达式注入）；
 * 3. rule_value 一律走 QueryBuilder 参数绑定，不做字符串拼接。
 */
@Entity('sys_data_rule')
export class DataRuleEntity {
  @ApiProperty({ description: '规则 ID（32 位）' })
  @PrimaryColumn({ type: 'varchar', length: 32 })
  id: string

  @ApiPropertyOptional({ description: '租户 ID（0=平台共享）' })
  @Column({ type: 'int', name: 'tenant_id', default: 0, comment: '租户ID(0=平台级)' })
  tenantId?: number

  @ApiProperty({ description: '规则名称' })
  @Column({ type: 'varchar', length: 100 })
  name: string

  @ApiProperty({ description: '资源标识：biz_order / customer / supplier' })
  @Column({ type: 'varchar', length: 64 })
  resource: string

  @ApiProperty({ description: '作用动作：all=读写通用（默认）/ read / write / delete' })
  @Column({ type: 'varchar', length: 16, default: 'all' })
  action: string

  @ApiProperty({ description: '过滤字段（实体属性名，如 createBy / amount / status）' })
  @Column({ type: 'varchar', length: 64, name: 'rule_field' })
  ruleField: string

  @ApiProperty({ description: '运算符：eq/ne/gt/gte/lt/lte/in/not_in/like/self/dept' })
  @Column({ type: 'varchar', length: 16, name: 'rule_operator' })
  ruleOperator: string

  @ApiPropertyOptional({ description: '规则值：固定值，或 $user.id / $user.deptIds 上下文变量' })
  @Column({ type: 'varchar', length: 500, name: 'rule_value', nullable: true })
  ruleValue?: string | null

  @ApiProperty({ description: '效果：allow=放行 / deny=排除' })
  @Column({ type: 'varchar', length: 8, name: 'rule_effect', default: 'allow' })
  ruleEffect: string

  @ApiProperty({ description: '优先级（数值小的先应用）' })
  @Column({ type: 'int', default: 100 })
  priority: number

  @ApiProperty({ description: '状态：1正常 0停用' })
  @Column({ type: 'smallint', default: 1 })
  status: number

  @ApiProperty({ description: '0正常 1已删除' })
  @Column({ type: 'smallint', name: 'del_flag', default: 0 })
  delFlag: number

  @ApiPropertyOptional({ description: '创建人' })
  @Column({ type: 'varchar', length: 32, name: 'create_by', nullable: true })
  createBy?: string

  @ApiPropertyOptional({ description: '创建时间' })
  @Column({ type: 'timestamp', name: 'create_time', nullable: true })
  createTime?: Date

  @ApiPropertyOptional({ description: '更新人' })
  @Column({ type: 'varchar', length: 32, name: 'update_by', nullable: true })
  updateBy?: string

  @ApiPropertyOptional({ description: '更新时间' })
  @Column({ type: 'timestamp', name: 'update_time', nullable: true })
  updateTime?: Date
}
