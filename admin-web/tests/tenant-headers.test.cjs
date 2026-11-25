const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')
const ts = require('typescript')

const ROOT = path.resolve(__dirname, '..')
const read = rel => fs.readFileSync(path.join(ROOT, rel), 'utf8')

function load(rel, context) {
  const { outputText } = ts.transpileModule(read(rel), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 }
  })
  const module = { exports: {} }
  vm.runInNewContext(outputText, {
    module,
    exports: module.exports,
    require(id) {
      if (id === '@/stores/auth-slice') {
        return { AUTH_STORAGE_KEYS: { accessToken: 'concise-token', tenantId: 'concise-tenant' } }
      }
      throw new Error(`Unexpected import: ${id}`)
    },
    ...context
  })
  return module.exports
}

async function main() {
  // 1. 公共头构造：令牌 + 租户同时存在时必须同时下发
  const store = new Map([
    ['concise-token', 'access-1'],
    ['concise-tenant', '7']
  ])
  const headers = load('src/lib/request-headers.ts', {
    localStorage: { getItem: key => store.get(key) ?? null }
  }).buildAuthHeaders()
  assert.equal(headers.Authorization, 'Bearer access-1')
  assert.equal(headers['X-Tenant-Id'], '7', '租户头必须随裸请求下发')

  // 平台视角（无租户）不发送该头
  store.delete('concise-tenant')
  const platformHeaders = load('src/lib/request-headers.ts', {
    localStorage: { getItem: key => store.get(key) ?? null }
  }).buildAuthHeaders()
  assert.equal('X-Tenant-Id' in platformHeaders, false, '平台视角不应发送租户头')

  // 2. 下载封装把公共头交给 fetch
  let captured
  const download = load('src/lib/download.ts', {
    localStorage: { getItem: () => null },
    fetch: async (url, init) => {
      captured = { url, init }
      return {
        ok: true,
        headers: { get: () => '' },
        blob: async () => ({ size: 0 })
      }
    },
    require(id) {
      if (id === '@/lib/request-headers') return { buildAuthHeaders: () => ({ Authorization: 'Bearer x', 'X-Tenant-Id': '9' }) }
      if (id === '@/lib/api-error') {
        return {
          ApiError: class ApiError extends Error {},
          reportRecovered: () => undefined,
          reportUnavailable: () => undefined
        }
      }
      throw new Error(`Unexpected import: ${id}`)
    }
  })
  await download.downloadFromApi('/v1/roles/export', 'roles.xlsx')
  assert.equal(captured.init.headers['X-Tenant-Id'], '9', '导出请求必须带租户头')

  // 3. 静态契约：role/notice 不再自建 downloadFile，上传 XHR 复用公共头
  for (const rel of ['src/features/system/role/api.ts', 'src/features/system/notice/api.ts']) {
    const source = read(rel)
    assert.equal(/async function downloadFile/.test(source), false, `${rel} 不应保留本地 downloadFile`)
    assert.match(source, /downloadFromApi\(/, `${rel} 应复用公共下载封装`)
  }
  const uploadSource = read('src/features/system/file/api.ts')
  assert.match(uploadSource, /buildAuthHeaders\(\)/, '上传 XHR 应复用公共头构造')
  assert.equal(/setRequestHeader\('Authorization'/.test(uploadSource), false, '不应再手写 Authorization 头')

  console.log('PASS: 下载/上传请求统一携带租户头，本地重复下载实现已删除')
}

main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
