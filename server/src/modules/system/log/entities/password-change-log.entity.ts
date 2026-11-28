import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { Column, Entity, PrimaryColumn } from 'typeorm'

/**
 * 密码修改记录（审计用）
 *
 * 独立于 sys_log：操作日志会被定期清理，而改密流水需要长期留痕。
 * 只存账号快照、不存密码或哈希。
 */
@Entity('sys_password_change_log')
export class PasswordChangeLogEntity {
  @PrimaryColumn({ type: 'varchar', length: 32, comment: '主键id' })
  id: string

  @Column({ type: 'int', default: 0, name: 'tenant_id', comment: '租户ID(0=平台级)' })
  tenantId: number

  @ApiProperty({ description: '被改密的用户 ID' })
  @Column({ type: 'varchar', length: 32, name: 'user_id', comment: '被改密用户ID' })
  userId: string

  @ApiProperty({ description: '被改密用户账号快照（改名后仍可读）' })
  @Column({ type: 'varchar', length: 100, comment: '用户账号快照' })
  username: string

  @ApiProperty({ description: '改密类型：self / admin_reset / forgot / admin_update', example: 'admin_reset' })
  @Column({ type: 'varchar', length: 16, name: 'change_type', comment: '改密类型' })
  changeType: string

  @ApiPropertyOptional({ description: '操作人 ID（自助改密时等于本人）', nullable: true })
  @Column({ type: 'varchar', length: 32, name: 'operator_id', nullable: true, comment: '操作人ID' })
  operatorId?: string | null

  @ApiPropertyOptional({ description: '操作人账号快照', nullable: true })
  @Column({ type: 'varchar', length: 100, name: 'operator_name', nullable: true, comment: '操作人账号' })
  operatorName?: string | null

  @ApiPropertyOptional({ description: '来源 IP', nullable: true })
  @Column({ type: 'varchar', length: 100, nullable: true, comment: '来源IP' })
  ip?: string | null

  @ApiPropertyOptional({ description: '来源 UA', nullable: true })
  @Column({ type: 'varchar', length: 255, name: 'user_agent', nullable: true, comment: '来源UA' })
  userAgent?: string | null

  @ApiPropertyOptional({ description: '备注', nullable: true })
  @Column({ type: 'varchar', length: 255, nullable: true, comment: '备注' })
  remark?: string | null

  @ApiProperty({ description: '改密时间' })
  @Column({ type: 'timestamp', precision: 3, name: 'create_time', comment: '改密时间' })
  createTime: Date
}
