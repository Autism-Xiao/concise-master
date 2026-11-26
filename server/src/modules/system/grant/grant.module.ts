import { Global, Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'

import { DataRuleEntity } from './entities/data-rule.entity'
import { GrantEntity } from './entities/grant.entity'
import { GrantService } from './grant.service'
import { GrantV1Controller } from './grant.v1.controller'

/**
 * 例外授权与数据规则模块（全局）
 *
 * 声明为 @Global 的原因与 PermissionCacheModule 相同：
 * PermsGuard 是全局守卫、AuthService 在登录后汇总权限，两处都要注入 GrantService；
 * 做成全局模块后，各业务 service（biz_order/customer/supplier）也能直接取规则，
 * 不必每个 module 补一条 imports。
 */
@Global()
@Module({
  imports: [TypeOrmModule.forFeature([GrantEntity, DataRuleEntity])],
  controllers: [GrantV1Controller],
  providers: [GrantService],
  exports: [GrantService]
})
export class GrantModule {}
