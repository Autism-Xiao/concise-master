import { Global, Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'

import { PasswordChangeLogEntity } from './entities/password-change-log.entity'
import { PasswordChangeLogService } from './password-change-log.service'

/**
 * 密码修改记录：全局模块
 *
 * 改密汇聚点分散在 UserModule / AuthModule，做成全局模块避免两两互相 imports。
 * 与 GrantModule 同一模式——只暴露 service，不挂独立 controller（查询走用户详情接口）。
 */
@Global()
@Module({
  imports: [TypeOrmModule.forFeature([PasswordChangeLogEntity])],
  providers: [PasswordChangeLogService],
  exports: [PasswordChangeLogService]
})
export class PasswordChangeLogModule {}
