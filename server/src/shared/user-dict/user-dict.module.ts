import { Global, Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'

import { UserEntity } from '../../modules/user/entities/user.entity'
import { UserDictService } from './user-dict.service'

/**
 * 用户名字典模块（全局）
 *
 * @Global 原因：审计名拦截器在 app.module 全局注册，而缓存失效点分散在用户模块。
 * 全局后各处注入 UserDictService 无需重复 imports。
 */
@Global()
@Module({
  imports: [TypeOrmModule.forFeature([UserEntity])],
  providers: [UserDictService],
  exports: [UserDictService]
})
export class UserDictModule {}
