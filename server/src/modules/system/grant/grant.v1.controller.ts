import { Body, Controller, Delete, Get, Param, Post, Put, Query, Req } from '@nestjs/common'
import { ApiBearerAuth, ApiOperation, ApiProperty, ApiPropertyOptional, ApiTags } from '@nestjs/swagger'
import { Type } from 'class-transformer'
import { IsIn, IsInt, IsNotEmpty, IsOptional, IsString } from 'class-validator'

import { OperLog } from '../../../common/decorators/oper-log.decorator'
import { Perms } from '../../../common/decorators/perms.decorator'
import { GrantService, SUBJECT_TYPES } from './grant.service'

/** 登录用户的最小形态（jwt.strategy 挂到 req.user 的就是 UserEntity） */
interface GrantRequestUser {
  id: string
  departIds?: string | null
  roles?: Array<{ id: string }> | null
}

class CreateGrantDto {
  @ApiProperty({ description: '主体类型：user / dept / position / role', enum: SUBJECT_TYPES })
  @IsIn(SUBJECT_TYPES as unknown as string[], { message: '主体类型只能是 user/dept/position/role' })
  subjectType: string

  @ApiProperty({ description: '主体 ID' })
  @IsNotEmpty({ message: '主体 ID 不能为空' })
  @IsString()
  subjectId: string

  @ApiProperty({ description: '权限点 ID（sys_permission.id）' })
  @IsNotEmpty({ message: '权限点不能为空' })
  @IsString()
  permissionId: string

  @ApiPropertyOptional({ description: '绑定的数据规则 ID（不传则不受规则约束）' })
  @IsOptional()
  @IsString()
  ruleId?: string | null

  @ApiPropertyOptional({ description: '过期时间（ISO 字符串），不传=永久' })
  @IsOptional()
  @IsString()
  expireAt?: string | null

  @ApiPropertyOptional({ description: '授权理由（审计用）' })
  @IsOptional()
  @IsString()
  reason?: string | null
}

class UpdateGrantDto {
  @ApiPropertyOptional({ description: '绑定的数据规则 ID' })
  @IsOptional()
  @IsString()
  ruleId?: string | null

  @ApiPropertyOptional({ description: '过期时间（ISO 字符串）' })
  @IsOptional()
  @IsString()
  expireAt?: string | null

  @ApiPropertyOptional({ description: '授权理由' })
  @IsOptional()
  @IsString()
  reason?: string | null

  @ApiPropertyOptional({ description: '状态：1正常 0停用' })
  @IsOptional()
  @IsInt()
  @Type(() => Number)
  status?: number
}

class CreateDataRuleDto {
  @ApiProperty({ description: '规则名称' })
  @IsNotEmpty({ message: '规则名称不能为空' })
  @IsString()
  name: string

  @ApiProperty({ description: '资源标识：biz_order / customer / supplier' })
  @IsNotEmpty({ message: '资源不能为空' })
  @IsString()
  resource: string

  @ApiProperty({ description: '过滤字段（实体属性名）' })
  @IsNotEmpty({ message: '过滤字段不能为空' })
  @IsString()
  ruleField: string

  @ApiProperty({ description: '运算符：eq/ne/gt/gte/lt/lte/in/not_in/like/self/dept' })
  @IsNotEmpty({ message: '运算符不能为空' })
  @IsString()
  ruleOperator: string

  @ApiPropertyOptional({ description: '规则值，支持 $user.id / $user.deptIds' })
  @IsOptional()
  @IsString()
  ruleValue?: string | null

  @ApiPropertyOptional({ description: '效果：allow / deny' })
  @IsOptional()
  @IsIn(['allow', 'deny'])
  ruleEffect?: string

  @ApiPropertyOptional({ description: '优先级（数值小的先应用）' })
  @IsOptional()
  @IsInt()
  @Type(() => Number)
  priority?: number
}

class UpdateDataRuleDto {
  @ApiPropertyOptional({ description: '规则名称' })
  @IsOptional()
  @IsString()
  name?: string

  @ApiPropertyOptional({ description: '过滤字段' })
  @IsOptional()
  @IsString()
  ruleField?: string

  @ApiPropertyOptional({ description: '运算符' })
  @IsOptional()
  @IsString()
  ruleOperator?: string

  @ApiPropertyOptional({ description: '规则值' })
  @IsOptional()
  @IsString()
  ruleValue?: string | null

  @ApiPropertyOptional({ description: '效果：allow / deny' })
  @IsOptional()
  @IsIn(['allow', 'deny'])
  ruleEffect?: string

  @ApiPropertyOptional({ description: '优先级' })
  @IsOptional()
  @IsInt()
  @Type(() => Number)
  priority?: number

  @ApiPropertyOptional({ description: '状态：1正常 0停用' })
  @IsOptional()
  @IsInt()
  @Type(() => Number)
  status?: number
}

/**
 * 授权与数据规则接口
 *
 * 权限点设计：授权/规则属于「权限体系自身」的配置，写操作只有平台/租户管理员可用。
 * 刻意不新建菜单路由节点（前端页面后续再补），只挂按钮级权限，避免出现点进去 404 的空菜单。
 */
@ApiTags('授权与数据规则')
@ApiBearerAuth('jwt')
@Controller('v1')
export class GrantV1Controller {
  constructor(private readonly grantService: GrantService) {}

  /* ---------------------------- 授权行 ---------------------------- */

  @ApiOperation({ summary: '授权列表', description: '需 system:grant:list' })
  @Perms('system:grant:list')
  @Get('grants')
  listGrants(
    @Query() query: { subjectType?: string; subjectId?: string; permissionId?: string }
  ) {
    return this.grantService.listGrants(query)
  }

  @ApiOperation({ summary: '新增授权', description: '需 system:grant:write' })
  @Perms('system:grant:write')
  @OperLog('授权')
  @Post('grants')
  createGrant(@Body() dto: CreateGrantDto, @Req() req: { user: GrantRequestUser }) {
    return this.grantService.createGrant(dto, req.user?.id)
  }

  @ApiOperation({ summary: '修改授权', description: '需 system:grant:write' })
  @Perms('system:grant:write')
  @OperLog('授权')
  @Put('grants/:id')
  updateGrant(@Param('id') id: string, @Body() dto: UpdateGrantDto, @Req() req: { user: GrantRequestUser }) {
    return this.grantService.updateGrant(id, dto, req.user?.id)
  }

  @ApiOperation({ summary: '删除授权（软删，保留审计）', description: '需 system:grant:write' })
  @Perms('system:grant:write')
  @OperLog('授权')
  @Delete('grants/:id')
  async removeGrant(@Param('id') id: string) {
    await this.grantService.removeGrant(id)
    return { success: true }
  }

  /* ---------------------------- 数据规则 ---------------------------- */

  @ApiOperation({ summary: '数据规则列表', description: '需 system:rule:list' })
  @Perms('system:rule:list')
  @Get('data-rules')
  listRules(@Query() query: { resource?: string }) {
    return this.grantService.listRules(query.resource)
  }

  @ApiOperation({ summary: '新增数据规则', description: '需 system:rule:write' })
  @Perms('system:rule:write')
  @OperLog('数据规则')
  @Post('data-rules')
  createRule(@Body() dto: CreateDataRuleDto, @Req() req: { user: GrantRequestUser }) {
    return this.grantService.createRule(dto, req.user?.id)
  }

  @ApiOperation({ summary: '修改数据规则', description: '需 system:rule:write' })
  @Perms('system:rule:write')
  @OperLog('数据规则')
  @Put('data-rules/:id')
  updateRule(@Param('id') id: string, @Body() dto: UpdateDataRuleDto, @Req() req: { user: GrantRequestUser }) {
    return this.grantService.updateRule(id, dto, req.user?.id)
  }

  @ApiOperation({ summary: '删除数据规则（被授权引用时拒绝）', description: '需 system:rule:write' })
  @Perms('system:rule:write')
  @OperLog('数据规则')
  @Delete('data-rules/:id')
  async removeRule(@Param('id') id: string) {
    await this.grantService.removeRule(id)
    return { success: true }
  }
}
