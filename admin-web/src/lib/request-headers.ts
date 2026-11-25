import { AUTH_STORAGE_KEYS } from '@/stores/auth-slice'

/**
 * 所有「绕过 getApiResult 的裸请求」共用的鉴权头构造
 *
 * 下载是原生 fetch 拿 blob、上传是 XHR 拿进度，都不能走 JSON 封装，
 * 过去各自读 localStorage 拼 Authorization，结果漏了 X-Tenant-Id：
 * 后端按该头做租户隔离，缺头会按平台视角导出/上传，属于数据串台风险。
 * 这里统一构造，新增请求头时只改一处。
 */
export function buildAuthHeaders(extra?: Record<string, string>): Record<string, string> {
  const token = localStorage.getItem(AUTH_STORAGE_KEYS.accessToken) ?? ''
  const tenantId = localStorage.getItem(AUTH_STORAGE_KEYS.tenantId) ?? ''
  return {
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...(tenantId ? { 'X-Tenant-Id': tenantId } : {}),
    ...extra
  }
}
