const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')
const ts = require('typescript')

/** vm 沙箱里的对象属于另一个 realm，deepStrictEqual 会因原型不同误报，用 JSON 比较 */
const deepEqual = (actual, expected, message) =>
  assert.equal(JSON.stringify(actual), JSON.stringify(expected), message)

/**
 * Redux 数据缓存门面的契约测试
 *
 * 用内存 Storage 模拟浏览器环境，直接执行真实源码（TS 转 CJS 后在 vm 沙箱里跑），
 * 验证：水合、持久化、lib/auth.ts 与 lib/features.ts 门面确实以 store 为数据源。
 */

const ROOT = path.resolve(__dirname, '..')

function memoryStorage() {
  const data = new Map()
  return {
    getItem: key => (data.has(key) ? data.get(key) : null),
    setItem: (key, value) => data.set(key, String(value)),
    removeItem: key => data.delete(key),
    clear: () => data.clear()
  }
}

function createLoader(local, session) {
  const cache = new Map()

  const reactReduxMock = {
    useDispatch: { withTypes: () => () => undefined },
    useSelector: { withTypes: () => () => undefined }
  }
  const extraMocks = {
    '@/lib/settings': { clearLocalSettings: () => undefined },
    '@/lib/remember-token': {
      clearRememberToken: () => undefined,
      getRememberToken: () => ''
    },
    '@/lib/http': {
      getApiResult: () => Promise.resolve({ 'rbac.superviseDept': true })
    },
    // 会话复位本身有独立契约测试；这里只保留它对 auth store 的复位副作用
    '@/lib/session-reset': {
      resetSessionCaches: reason => {
        if (reason !== 'logout' && reason !== 'account') return
        const { store } = load('src/stores/index.ts')
        const { authActions } = load('src/stores/auth-slice.ts')
        store.dispatch(authActions.resetAuth())
      }
    }
  }

  function load(relPath) {
    if (cache.has(relPath)) return cache.get(relPath)
    const source = fs.readFileSync(path.join(ROOT, relPath), 'utf8')
    const { outputText } = ts.transpileModule(source, {
      compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 }
    })
    const module = { exports: {} }
    vm.runInNewContext(outputText, {
      module,
      exports: module.exports,
      require(id) {
        if (id in extraMocks) return extraMocks[id]
        if (id === '@reduxjs/toolkit') return require('@reduxjs/toolkit')
        if (id === 'react') return { useEffect: () => undefined }
        if (id === 'react-redux') return reactReduxMock
        if (id === '@/lib/features') return load('src/lib/features.ts')
        if (id === './auth-slice' || id === '@/stores/auth-slice') {
          return load('src/stores/auth-slice.ts')
        }
        if (id === './features-slice' || id === '@/stores/features-slice') {
          return load('src/stores/features-slice.ts')
        }
        if (id === '@/stores') return load('src/stores/index.ts')
        if (id.startsWith('@/lib/')) return load(`src/${id.slice(2)}.ts`)
        throw new Error(`Unexpected import: ${id}`)
      },
      localStorage: local,
      sessionStorage: session,
      window: { dispatchEvent: () => undefined },
      Event: class EventMock {
        constructor(type) {
          this.type = type
        }
      },
      fetch: () => Promise.resolve({ ok: true }),
      console
    })
    cache.set(relPath, module.exports)
    return module.exports
  }

  return load
}

/** 构造一份预置了登录态的浏览器存储 */
function seededStorage() {
  const local = memoryStorage()
  const session = memoryStorage()
  local.setItem('concise-auth', 'true')
  local.setItem('concise-user', 'alice')
  local.setItem('concise-name', 'Alice')
  local.setItem('concise-role', 'admin')
  local.setItem('concise-token', 'old-access')
  local.setItem('concise-perms', JSON.stringify(['system:user:list', '*']))
  local.setItem('concise-tenant', '7')
  local.setItem('concise-menus', JSON.stringify([{ id: 'dashboard' }]))
  session.setItem('concise-features', JSON.stringify({ 'x.legacy': true }))
  session.setItem('concise-must-change-pwd', '1')
  return { local, session }
}

async function main() {
  // 1. 冷启动水合：store 从存储恢复，首帧即可同步读到登录态
  {
    const { local, session } = seededStorage()
    const { store } = createLoader(local, session)('src/stores/index.ts')
    const s = store.getState().auth
    assert.equal(s.authenticated, true, '登录态应从 localStorage 水合')
    assert.equal(s.username, 'alice', '账号名应水合')
    assert.equal(s.roleCode, 'admin', '角色应水合')
    assert.equal(s.accessToken, 'old-access', 'accessToken 应水合')
    deepEqual(s.permissions, ['system:user:list', '*'], '权限数组应反序列化')
    assert.equal(s.tenantId, 7, '租户 ID 应转成数字')
    assert.equal(s.mustChangePassword, true, '强制改密标记应从 sessionStorage 水合')
    deepEqual(store.getState().features.flags, { 'x.legacy': true }, '特性开关快照应水合')
  }

  // 2. 写操作同步落盘：门面 dispatch 后 store 与存储同时更新
  {
    const { local, session } = seededStorage()
    const load = createLoader(local, session)
    load('src/stores/index.ts')
    const auth = load('src/lib/auth.ts')

    auth.setTokens('new-access', 'new-refresh')
    assert.equal(auth.getAccessToken(), 'new-access', '门面读的是 store 里的新令牌')
    assert.equal(local.getItem('concise-token'), 'new-access', '新令牌应同步落盘')

    auth.setDisplayName(' renamed ')
    assert.equal(auth.getName(), ' renamed ', '显示名应走 store 原样返回')
    assert.equal(local.getItem('concise-name'), ' renamed ', '显示名应同步落盘')

    auth.setTenantId(null)
    assert.equal(auth.getTenantId(), null, 'null 租户表示平台视角')
    assert.equal(local.getItem('concise-tenant'), null, '平台视角应从存储清掉租户 key')

    assert.equal(auth.hasPermission('anything'), true, "超管 '*' 应命中任意权限")
    assert.equal(auth.needsPasswordChange(), true, '强制改密标记应走 store')

    auth.clearMustChangePassword()
    assert.equal(auth.needsPasswordChange(), false, '清标记后应立刻从 store 读到 false')
    assert.equal(session.getItem('concise-must-change-pwd'), null, '标记应从 sessionStorage 清掉')
  }

  // 3. 特性开关门面：拉取结果写 store + 落盘，重置后随租户视角失效
  {
    const { local, session } = seededStorage()
    // 清掉快照，强制走一次真实拉取（否则会命中快照不发请求）
    session.removeItem('concise-features')
    const load = createLoader(local, session)
    const { store } = load('src/stores/index.ts')
    const features = load('src/lib/features.ts')

    const flags = await features.fetchFeatures()
    deepEqual(flags, { 'rbac.superviseDept': true }, '拉取结果应来自后端')
    deepEqual(store.getState().features.flags, flags, '开关应写入 store')
    deepEqual(
      JSON.parse(session.getItem('concise-features')),
      flags,
      '开关应同步落盘到 sessionStorage'
    )

    features.notifyFeaturesReset()
    assert.equal(store.getState().features.flags, null, '重置后 store 应回到未加载态')
    assert.equal(session.getItem('concise-features'), null, '重置应清掉快照')
  }

  // 4. 登出：store 一次性复位，所有认证 key 从存储清除
  {
    const { local, session } = seededStorage()
    const load = createLoader(local, session)
    load('src/stores/index.ts')
    const auth = load('src/lib/auth.ts')

    auth.logout()
    assert.equal(auth.isAuthenticated(), false, '登出后应为未认证')
    assert.equal(auth.getUsername(), 'admin', '账号名回退默认值')
    assert.equal(auth.getAccessToken(), '', '令牌应清空')
    deepEqual(auth.getPermissions(), [], '权限应清空')
    assert.equal(local.getItem('concise-auth'), null, '登录标记应从存储删除')
    assert.equal(local.getItem('concise-token'), null, '令牌应从存储删除')
    assert.equal(local.getItem('concise-menus'), null, '菜单快照应从存储删除')
    assert.equal(session.getItem('concise-must-change-pwd'), null, '强制改密标记应删除')
  }

  console.log('PASS: Redux 数据缓存门面（水合 / 持久化 / 门面读写 / 登出复位）')
}

main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
