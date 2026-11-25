/**
 * 会话代次
 *
 * 登出、换号、切租户都会让「上一会话发出的异步请求」失去写入资格。
 * 各模块在请求发起时记下当前代次，结果回来时若代次已变就直接丢弃，
 * 避免旧的权限/开关/字典/令牌结果回填到新会话里（串号与幽灵登录）。
 *
 * 这个文件刻意不依赖任何模块，供所有缓存层安全引用。
 */
let epoch = 0

/** 当前会话代次 */
export function getSessionEpoch(): number {
  return epoch
}

/** 开启新会话，返回新代次 */
export function nextSessionEpoch(): number {
  epoch += 1
  return epoch
}
