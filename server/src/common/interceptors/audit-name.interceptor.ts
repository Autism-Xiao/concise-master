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

/** [ID 列, 快照列] 配对：快照列已有值就跳过，只给空快照补名字 */
const AUDIT_FIELDS = [
  ['createBy', 'createByName'],
  ['updateBy', 'updateByName']
] as const

/**
 * 审计人名字段补全（响应层，历史数据兜底）
 *
 * 新方案：createByName/updateByName 是数据库里的**快照列**，写入时固化当时的
 * 名字，用户改名不影响历史记录。实体查出来自带这两列，本拦截器不再覆盖。
 *
 * 本拦截器只处理快照为空的历史数据（迁移前创建的记录）：拿 createBy/updateBy
 * 的 ID 实时查当前名字补上。查不到对应用户（如历史数据用户已删）则不补，
 * 前端回退显示原 ID。这样既保证新数据留痕不可变，旧数据也不至于显示一串 ID。
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

        // 只收集"快照为空"的 ID（新数据已有快照列，直接跳过，不查库）
        const ids = new Set<string>()
        for (const item of objects) {
          for (const [idField, nameField] of AUDIT_FIELDS) {
            const snapshot = item[nameField]
            if (typeof snapshot === 'string' && snapshot.trim()) continue
            const value = item[idField]
            if (typeof value === 'string' && value.trim()) ids.add(value.trim())
          }
        }
        if (!ids.size) return data

        const names = await this.userDict.getNames([...ids])
        for (const item of objects) {
          for (const [idField, nameField] of AUDIT_FIELDS) {
            const snapshot = item[nameField]
            if (typeof snapshot === 'string' && snapshot.trim()) continue
            const value = item[idField]
            if (typeof value !== 'string') continue
            const name = names.get(value.trim())
            if (name) item[nameField] = name
          }
        }
        return data
      })
    )
  }
}
