import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { IsIn, IsInt, IsOptional, IsString, Length, MaxLength, Min } from 'class-validator'

export class CreateDeptDto {
  @ApiProperty({ description: '机构/部门名称', example: '研发部', maxLength: 100 })
  @IsString()
  @Length(1, 100, { message: '部门名称长度须在 1~100 位之间' })
  departName: string

  @ApiPropertyOptional({ description: '英文名（非必填）', example: 'R&D Department', nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  departNameEn?: string

  @ApiPropertyOptional({ description: '英文简写（非必填）', example: 'RD', nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  departNameAbbr?: string

  @ApiPropertyOptional({ description: '父机构 ID，不传为顶级', example: 'dept_1' })
  @IsOptional()
  @IsString()
  parentId?: string | null

  @ApiPropertyOptional({ description: '排序号，越小越靠前', example: 0 })
  @IsOptional()
  @IsInt()
  @Min(0)
  departOrder?: number

  @ApiPropertyOptional({ description: '机构编码（唯一，不传则按层级自动生成，如 A01 / A01A01）', example: 'A01' })
  @IsOptional()
  @IsString()
  @MaxLength(64)
  orgCode?: string

  @ApiPropertyOptional({ description: '机构类别：1 公司 / 2 部门 / 4 子公司', example: '2', enum: ['1', '2', '4'] })
  @IsOptional()
  @IsString()
  @IsIn(['1', '2', '4'])
  orgCategory?: string

  @ApiPropertyOptional({ description: '描述 / 负责人', example: '负责人：李工' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string

  @ApiPropertyOptional({ description: '状态：1 启用 / 0 不启用', example: '1', enum: ['0', '1'] })
  @IsOptional()
  @IsString()
  @IsIn(['0', '1'])
  status?: string
}
