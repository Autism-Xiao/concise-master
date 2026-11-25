import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { Column, CreateDateColumn, Entity, Index, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm'

/**
 * 旧版「附件」记录表 tool_storage
 *
 * 只记「谁上传了哪些图片」（头像 / 富文本插图），没有 parent_id / is_folder / 软删，
 * 撑不起目录树，也无法做按字节的配额统计（size 存的是 "23.4 KB" 这种可读字符串）。
 * 网盘/文件管理走 sys_file（FileEntity），这张表仅为兼容旧上传接口保留。
 */
@Entity('tool_storage')
@Index('idx_tool_storage_tenant', ['tenantId'])
export class StorageEntity {
  @ApiProperty({ description: '主键 ID', example: 1 })
  @PrimaryGeneratedColumn({ comment: '主键' })
  id: number

  @ApiProperty({ description: '落盘文件名（已重命名、含随机后缀）', example: 'avatar-20261125103000123-a1b2c3d4.png' })
  @Column({ type: 'varchar', length: 200, comment: '存储文件名' })
  name: string

  @ApiPropertyOptional({ description: '上传时的原始文件名', example: '我的头像.png' })
  @Column({ type: 'varchar', length: 200, nullable: true, comment: '原始文件名' })
  fileName?: string | null

  @ApiPropertyOptional({ description: '扩展名（不含点）', example: 'png' })
  @Column({ type: 'varchar', length: 32, nullable: true, comment: '扩展名' })
  extName?: string | null

  @ApiProperty({ description: '访问路径（公开附件形如 /upload/2026-11-25/图片/xxx.png）', example: '/upload/2026-11-25/图片/xxx.png' })
  @Column({ type: 'varchar', length: 255, comment: '访问路径' })
  path: string

  @ApiPropertyOptional({ description: '文件分类：图片/文档/音乐/视频/其他', example: '图片' })
  @Column({ type: 'varchar', length: 16, nullable: true, comment: '文件分类' })
  type?: string | null

  @ApiPropertyOptional({ description: '可读大小', example: '23.4 KB' })
  @Column({ type: 'varchar', length: 32, nullable: true, comment: '可读大小' })
  size?: string | null

  @ApiPropertyOptional({ description: '上传人 ID', example: 'e9ca23d68d884d4ebb19d07889727dae' })
  @Column({ type: 'varchar', length: 32, nullable: true, comment: '上传人ID' })
  userId?: string | null

  @ApiPropertyOptional({ description: '租户 ID（0=平台共享）', example: 1 })
  @Column({ type: 'int', default: 0, comment: '租户ID(0=平台共享)' })
  tenantId?: number

  @ApiPropertyOptional({ description: '创建时间' })
  @CreateDateColumn({ name: 'created_at', comment: '创建时间' })
  createdAt?: Date

  @ApiPropertyOptional({ description: '更新时间' })
  @UpdateDateColumn({ name: 'updated_at', comment: '更新时间' })
  updatedAt?: Date
}
