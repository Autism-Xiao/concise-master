import { Column, CreateDateColumn, Entity, PrimaryColumn } from 'typeorm'

/** 岗位默认角色模板：岗位挂一组默认角色，用户挂岗即自动获得（sys_user_role.source='position'） */
@Entity('sys_position_role')
export class PositionRoleEntity {
  @PrimaryColumn({ type: 'varchar', length: 32, comment: '主键id' })
  id!: string

  @Column({ name: 'position_id', type: 'varchar', length: 32, comment: '岗位ID（sys_position.id）' })
  positionId!: string

  @Column({ name: 'role_id', type: 'varchar', length: 32, comment: '默认角色ID（sys_role.id）' })
  roleId!: string

  @Column({ name: 'tenant_id', type: 'int', default: 0, comment: '租户ID(0=平台级)' })
  tenantId!: number

  @CreateDateColumn({ name: 'create_time', type: 'timestamp', precision: 3, comment: '创建时间' })
  createTime!: Date
}
