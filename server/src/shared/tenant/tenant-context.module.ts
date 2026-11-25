import { Global, Module, type OnModuleInit } from '@nestjs/common'
import { JwtModule } from '@nestjs/jwt'
import { TypeOrmModule } from '@nestjs/typeorm'

import { jwtConfig, type JwtConfig } from '../../config'
import { TenantAccessService } from './tenant-access.service'
import { installTenantAutoScope } from './tenant-auto-scope'

/**
 * 租户基础设施（全局）
 *
 * - TenantAccessService：用户归属解析（供中间件与租户接口共用）
 * - TenantMiddleware 由 AppModule 的 configure() 注册到所有 /api 路由
 * - onModuleInit 安装 QueryBuilder 层的租户过滤兜底（tenant-auto-scope.ts），
 *   手写 applyTenantScope 的存量代码不受影响（重复 AND 同语义条件，无害）
 * - 上下文本身是无状态模块（AsyncLocalStorage），不需要 provider
 */
@Global()
@Module({
  imports: [
    TypeOrmModule.forFeature([]),
    JwtModule.registerAsync({
      inject: [jwtConfig.KEY],
      useFactory: (jwt: JwtConfig) => ({ secret: jwt.secret, signOptions: { expiresIn: jwt.expiresIn } })
    })
  ],
  providers: [TenantAccessService],
  exports: [TenantAccessService, JwtModule]
})
export class TenantContextModule implements OnModuleInit {
  onModuleInit(): void {
    installTenantAutoScope()
  }
}
