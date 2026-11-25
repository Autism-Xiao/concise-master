import { Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'

import { UserModule } from '../../user/user.module'
import { PositionRoleEntity } from './entities/position-role.entity'
import { PostEntity } from './entities/post.entity'
import { PostService } from './post.service'
import { PostV1Controller } from './post.v1.controller'

@Module({
  // UserModule 提供 syncPositionRolesForPost：岗位模板变更后为持有者重算「岗位来源」角色；
  // UserModule 只注册 PostEntity 仓库、不依赖本模块，方向单一无循环
  imports: [TypeOrmModule.forFeature([PostEntity, PositionRoleEntity]), UserModule],
  controllers: [PostV1Controller],
  providers: [PostService],
  exports: [PostService, TypeOrmModule]
})
export class PostModule {}
