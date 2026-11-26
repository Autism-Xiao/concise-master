import { OmitType, PartialType } from '@nestjs/swagger'
import { ApiPropertyOptional } from '@nestjs/swagger'
import { IsArray, IsOptional, IsString } from 'class-validator'

import { CreateUserDto } from './create-user.dto'

/**
 * 更新时所有字段均可选。
 *
 * roleIds 需要从继承链里摘掉再单独声明：
 * PartialType 会把 CreateUserDto 的校验元数据整体复制过来（子类同名字段是叠加而非替换），
 * 而新建时的 @ArrayMinSize(1) 会让编辑「传空数组清空角色」报错。
 * 这里用 OmitType 先去掉 roleIds，再声明允许空数组的版本。
 */
export class UpdateUserDto extends PartialType(OmitType(CreateUserDto, ['roleIds'] as const)) {
  @ApiPropertyOptional({ description: '角色 ID 列表；空数组表示清空该用户的全部角色', type: [String] })
  @IsOptional()
  @IsArray({ message: '角色必须是数组' })
  @IsString({ each: true, message: '每个角色 ID 必须是字符串' })
  roleIds?: string[]
}
