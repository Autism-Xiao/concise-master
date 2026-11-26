import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common'
import { Observable, mergeMap } from 'rxjs'

import { UserDictService } from '../../shared/user-dict/user-dict.service'

type PlainObject = Record<string, unknown>
const isObject = (value: unknown): value is PlainObject => !!value && typeof value === 'object' && !Buffer.isBuffer(value) && !Array.isArray(value)

/** 从 handler 返回值里挑出要处理的对象：分页的 records / 数组 / 单个对象 */
function responseObjects(data: unknown): PlainObject[] {
  if (Array.isArray(data)) return data.filter(isObject)
  if (!isObject(data)) return []
  if (Array.isArray(data.records)) return data.records.filter(isObject)
  return [data]
}

const AUDIT_FIELDS = ['createBy', 'updateBy'] as const

/**
 * 审计人名字段补全（响应层）
 *
 * createBy/updateBy 存的是用户 ID（32 位），本拦截器批量翻译成展示名后
 * 附加 createByName/updateByName，**保留原字段不动**（前端仍可拿 ID）。
 * 查不到对应用户时（如历史数据用户已删）不附加，前端回退显示原 ID。
 *
 * 与 SensitiveInterceptor 同属"改原始数据"型拦截器，注册在它内侧（更靠后）。
 */
@Injectable()
export class AuditNameInterceptor implements NestInterceptor {
  constructor(private readonly userDict: UserDictService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    return next.handle().pipe(
      mergeMap(async data => {
        const objects = responseObjects(data)
        if (!objects.length) return data

        // 收集所有需要翻译的 ID（去重）
        const ids = new Set<string>()
        for (const item of objects) {
          for (const field of AUDIT_FIELDS) {
            const value = item[field]
            if (typeof value === 'string' && value.trim()) ids.add(value.trim())
          }
        }
        if (!ids.size) return data

        const names = await this.userDict.getNames([...ids])
        for (const item of objects) {
          for (const field of AUDIT_FIELDS) {
            const value = item[field]
            if (typeof value !== 'string') continue
            const name = names.get(value.trim())
            if (name) item[`${field}Name`] = name
          }
        }
        return data
      })
    )
  }
}
