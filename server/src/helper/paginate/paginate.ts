import type { ObjectLiteral, SelectQueryBuilder } from 'typeorm'

import { Pagination } from './pagination'

/** 单页硬上限：即使内部调用绕过 DTO 的 @Max(100)，也不可能一次性拉走整张表 */
export const MAX_PAGE_SIZE = 200

/** 把列表 DTO 的 skipCount 开关转换成 paginate 的 count 参数（字符串 'true' 与布尔 true 都认） */
export function countFromSkipCount(skipCount?: boolean | string): boolean {
  return !(skipCount === true || skipCount === 'true')
}

export interface PaginateOptions {
  /** 页码，从 1 开始 */
  page?: number
  /** 每页条数（内部硬上限 200，防止绕过 DTO 校验的调用拖垮库） */
  pageSize?: number
  /**
   * 是否统计总数（默认 true）
   *
   * 传 false 时不发 `SELECT COUNT(*)`，改为「多取 1 条」判断还有没有下一页，
   * 返回的 total / pages 都是 -1。千万行表上的 COUNT 要走全索引扫描（实测 17.8 秒），
   * 而列表页往往只需要知道「能不能翻下一页」。
   *
   * 大表（日志/消息/订单）建议显式传 false，并在前端用 hasNext 翻页。
   */
  count?: boolean
  /**
   * 游标分页（可选）：传入后忽略 page，改为 `WHERE alias.cursorColumn < :cursor`，
   * 避免深分页 offset 随页码线性放大。调用方需保证该列为递增主键/唯一索引且已按它倒序。
   * 返回 total = -1（无 COUNT），通过 hasNext 判断翻页。
   */
  cursor?: string | number
  /** 游标列名（默认 'id'，相对主别名） */
  cursorColumn?: string
}

/**
 * 基于 QueryBuilder 的通用分页执行器
 *
 * 硬上限：pageSize 统一夹到 [1, MAX_PAGE_SIZE]；页码至少 1；非法值回落默认，不会得到 NaN/负 offset。
 * 用法：await paginate(qb, { page: 1, pageSize: 10 })
 */
export async function paginate<T extends ObjectLiteral>(qb: SelectQueryBuilder<T>, options: PaginateOptions = {}): Promise<Pagination<T>> {
  const rawPage = Math.trunc(options.page ?? 1)
  const rawSize = Math.trunc(options.pageSize ?? 10)
  const page = Number.isFinite(rawPage) && rawPage > 0 ? rawPage : 1
  const pageSize = Math.min(Number.isFinite(rawSize) && rawSize > 0 ? rawSize : 10, MAX_PAGE_SIZE)

  // 游标分页：无 COUNT，多取 1 条判 hasNext，彻底避开深分页 offset
  if (options.cursor !== undefined && options.cursor !== null && options.cursor !== '') {
    const column = options.cursorColumn ?? 'id'
    const rows = await qb
      .andWhere(`${qb.alias}.${column} < :cursor`, { cursor: options.cursor })
      .take(pageSize + 1)
      .getMany()
    return new Pagination(rows.slice(0, pageSize), -1, page, pageSize, rows.length > pageSize)
  }

  // 不统计总数：多取 1 条，够判断有没有下一页就停
  if (options.count === false) {
    const rows = await qb
      .skip((page - 1) * pageSize)
      .take(pageSize + 1)
      .getMany()
    return new Pagination(rows.slice(0, pageSize), -1, page, pageSize, rows.length > pageSize)
  }

  const [records, total] = await qb
    .skip((page - 1) * pageSize)
    .take(pageSize)
    .getManyAndCount()

  return new Pagination(records, total, page, pageSize)
}
