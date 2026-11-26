import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { Column, Entity, PrimaryColumn } from 'typeorm'

/**
 * 例外授权行（RBAC 的补充）
 *
 * 解决的正是「角色爆炸」：跨部门临时授权不再新建角色，而是给主体挂一条授权。
 *
 * 设计要点：
 * - subject_type 支持 user / dept / position / role：
 *   给「部门」授权可以让整组人继承（人调岗自动失效），比逐人挂角色更贴近组织现实；
 * - permission_id 落到 sys_permission，这样 PermsGuard 与 /auth/permissions 的
 *   功能权限判定可以和角色权限直接取并集，前端不需要改返回结构；
 * - rule_id 可选：绑定数据规则后，这条授权的可见范围按规则走（而不是角色级 data_scope），
 *   于是「订单看全部、客户只看自己」可以同时成立；
 * - expire_at 有值即临时授权，判定时过期的行直接忽略，不用定时任务清理。
 */
@Entity('sys_grant')
export class GrantEntity {
  @ApiProperty({ description: '授权 ID（32 位）' })
  @PrimaryColumn({ type: 'varchar', length: 32 })
  id: string

  @ApiPropertyOptional({ description: '租户 ID（0=平台共享）' })
  @Column({ type: 'int', name: 'tenant_id', default: 0, comment: '租户ID(0=平台级)' })
  tenantId?: number

  @ApiProperty({ description: '授权主体：user / dept / position / role' })
  @Column({ type: 'varchar', length: 16, name: 'subject_type' })
  subjectType: string

  @ApiProperty({ description: '主体 ID' })
  @Column({ type: 'varchar', length: 32, name: 'subject_id' })
  subjectId: string

  @ApiProperty({ description: '权限点 ID（sys_permission.id）' })
  @Column({ type: 'varchar', length: 32, name: 'permission_id' })
  permissionId: string

  @ApiPropertyOptional({ description: '可选：绑定的数据规则（sys_data_rule.id）' })
  @Column({ type: 'varchar', length: 32, name: 'rule_id', nullable: true })
  ruleId?: string | null

  @ApiProperty({ description: '效果：allow / deny' })
  @Column({ type: 'varchar', length: 8, name: 'rule_effect', default: 'allow' })
  ruleEffect: string

  @ApiPropertyOptional({ description: '过期时间，NULL=永久；过期的行判定时忽略' })
  @Column({ type: 'timestamp', name: 'expire_at', nullable: true })
  expireAt?: Date | null

  @ApiPropertyOptional({ description: '授权理由（审计用）' })
  @Column({ type: 'varchar', length: 255, nullable: true })
  reason?: string | null

  @ApiProperty({ description: '状态：1正常 0停用' })
  @Column({ type: 'smallint', default: 1 })
  status: number

  @ApiProperty({ description: '0正常 1已删除' })
  @Column({ type: 'smallint', name: 'del_flag', default: 0 })
  delFlag: number

  @ApiPropertyOptional({ description: '授权人' })
  @Column({ type: 'varchar', length: 32, name: 'grant_by', nullable: true })
  grantBy?: string

  @ApiPropertyOptional({ description: '创建时间' })
  @Column({ type: 'timestamp', name: 'create_time', nullable: true })
  createTime?: Date

  @ApiPropertyOptional({ description: '更新时间' })
  @Column({ type: 'timestamp', name: 'update_time', nullable: true })
  updateTime?: Date
}
