import { PartialType } from '@nestjs/swagger'

import { CreateUserDto } from './create-user.dto'

/**
 * 更新时所有字段均可选，roleIds 语义与新建一致：
 * 不传 = 不改动角色；空数组 = 清空全部角色；非空数组 = 重绑为指定角色。
 * CreateUserDto 已移除 ArrayMinSize，无需 OmitType 绕开校验。
 */
export class UpdateUserDto extends PartialType(CreateUserDto) {}
