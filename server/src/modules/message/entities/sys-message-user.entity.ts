import { Column, CreateDateColumn, Entity, Index, PrimaryGeneratedColumn } from 'typeorm'

/** 用户消息关联：一条消息 × 一个接收人一行，已读状态挂在这里 */
@Index('uk_message_user', ['messageId', 'userId'], { unique: true })
@Index('idx_message_user_user', ['userId', 'isRead'])
@Entity('sys_message_user')
export class SysMessageUserEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string

  // PG 下 sys_message.id 是 uuid；这里必须同为 uuid，否则 join 报
  // "operator does not exist: uuid = character varying"。MySQL 驱动会把 uuid 映射为 varchar(36)。
  @Column({ type: 'uuid', comment: '消息ID' })
  messageId: string

  @Column({ length: 32, comment: '接收人用户ID' })
  userId: string

  /** 0 未读 / 1 已读 */
  @Column({ type: 'smallint', default: 0, comment: '0未读 1已读' })
  isRead: number

  @Column({ name: 'read_at', type: 'timestamp', nullable: true, comment: '阅读时间' })
  readAt?: Date | null

  @CreateDateColumn({ name: 'created_at', comment: '创建时间' })
  createdAt: Date
}
