const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')
const ts = require('typescript')

const ROOT = path.resolve(__dirname, '..')

function memoryStorage(seed = {}) {
  const data = new Map(Object.entries(seed).map(([k, v]) => [k, String(v)]))
  return {
    getItem: key => (data.has(key) ? data.get(key) : null),
    setItem: (key, value) => data.set(key, String(value)),
    removeItem: key => data.delete(key),
    clear: () => data.clear()
  }
}

/** 直接执行真实 TS 源码的轻量沙箱，按依赖表注入浏览器环境与 mock */
function createLoader(local, session, mocks) {
  const cache = new Map()
  const events = []

  const reactReduxMock = {
    useDispatch: { withTypes: () => () => undefined },
    useSelector: { withTypes: () => () => undefined }
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
        if (id in mocks) return mocks[id]
        if (id === '@reduxjs/toolkit') return require('@reduxjs/toolkit')
        if (id === 'react') return { useEffect: () => undefined }
        if (id === 'react-redux') return reactReduxMock
        if (id === '@/stores') return load('src/stores/index.ts')
        if (id === '@/stores/auth-slice' || id === './auth-slice') return load('src/stores/auth-slice.ts')
        if (id === '@/stores/features-slice' || id === './features-slice') return load('src/stores/features-slice.ts')
        if (id.startsWith('@/lib/')) return load(`src/${id.slice(2)}.ts`)
        throw new Error(`Unexpected import: ${id}`)
      },
      localStorage: local,
      sessionStorage: session,
      window: {
        dispatchEvent: event => events.push(event.type),
        addEventListener: () => undefined,
        removeEventListener: () => undefined
      },
      Event: class EventMock {
        constructor(type) {
          this.type = type
        }
      },
      CustomEvent: class CustomEventMock {
        constructor(type, init) {
          this.type = type
          this.detail = init && init.detail
        }
      },
      console
    })
    cache.set(relPath, module.exports)
    return module.exports
  }

  return { load, events }
}

async function main() {
  const local = memoryStorage({
    'concise-auth': 'true',
    'concise-user': 'alice',
    'concise-perms': JSON.stringify(['system:user:list']),
    'concise-tenant': '7',
    'concise-tabs': '[]',
    'concise-tenant-info': '{}'
  })
  const session = memoryStorage({ 'concise-locked': 'true' })

  let permissionResets = 0
  const fetchCalls = []
  const { load, events } = createLoader(local, session, {
    '@/lib/api-error': { reportRecovered: () => undefined },
    '@/lib/settings': { clearLocalSettings: () => undefined },
    '@/lib/http': {
      getApiResult: url => {
        fetchCalls.push(url)
        return Promise.resolve({ items: [{ itemText: '一', itemValue: '1' }] })
      }
    },
    '@/lib/permissions': {
      resetPermissionCache: () => {
        permissionResets += 1
      }
    }
  })

  const { store } = load('src/stores/index.ts')
  const epoch = load('src/lib/session-epoch.ts')
  const reset = load('src/lib/session-reset.ts')
  const features = load('src/lib/features.ts')
  const dict = load('src/lib/dict.ts')
  const lock = load('src/lib/lock-screen.ts')
  const auth = load('src/lib/auth.ts')

  // 1. 登出复位：会话代次推进、权限/字典/开关缓存、锁屏、租户与标签缓存全部清理
  const beforeEpoch = epoch.getSessionEpoch()
  reset.resetSessionCaches('logout')
  assert.ok(epoch.getSessionEpoch() > beforeEpoch, '复位必须推进会话代次')
  assert.equal(permissionResets, 1, '权限对账标记应复位')
  assert.equal(store.getState().features.flags, null, '特性开关快照应清空')
  assert.equal(lock.isLocked(), false, '锁屏标志应清除')
  assert.equal(local.getItem('concise-tabs'), null, '标签页缓存应清除')
  assert.equal(local.getItem('concise-tenant-info'), null, '租户信息缓存应清除')
  assert.equal(store.getState().auth.authenticated, false, 'auth store 应复位')

  // 2. 在途特性开关请求遇到复位时不得回填旧租户数据
  session.removeItem('concise-features')
  let resolveFlags
  const pending = new Promise(resolve => {
    resolveFlags = resolve
  })
  const httpMock = {
    getApiResult: () => pending
  }
  const isolated = createLoader(memoryStorage(), memoryStorage(), {
    '@/lib/api-error': { reportRecovered: () => undefined },
    '@/lib/settings': { clearLocalSettings: () => undefined },
    '@/lib/http': httpMock,
    '@/lib/permissions': { resetPermissionCache: () => undefined }
  })
  const isolatedStore = isolated.load('src/stores/index.ts').store
  const isolatedFeatures = isolated.load('src/lib/features.ts')
  const isolatedReset = isolated.load('src/lib/session-reset.ts')
  const task = isolatedFeatures.fetchFeatures()
  isolatedReset.resetSessionCaches('logout')
  resolveFlags({ 'old.tenant': true })
  await task
  assert.equal(isolatedStore.getState().features.flags, null, '旧会话的开关响应必须丢弃')

  // 3. 字典缓存被清后，旧在途结果不能回填（下次读取必须重新发请求）
  const fresh = createLoader(memoryStorage(), memoryStorage(), {
    '@/lib/api-error': { reportRecovered: () => undefined },
    '@/lib/settings': { clearLocalSettings: () => undefined },
    '@/lib/http': {
      getApiResult: url => {
        fetchCalls.push(url)
        return Promise.resolve({ items: [{ itemText: '一', itemValue: '1' }] })
      }
    },
    '@/lib/permissions': { resetPermissionCache: () => undefined }
  })
  const freshDict = fresh.load('src/lib/dict.ts')
  const callsBefore = fetchCalls.length
  await freshDict.loadDict('sys_test')
  assert.equal(fetchCalls.length, callsBefore + 1, '首次加载应发请求')
  fresh.load('src/lib/session-reset.ts').resetSessionCaches('logout')
  await freshDict.loadDict('sys_test')
  assert.equal(fetchCalls.length, callsBefore + 2, '复位后旧缓存必须失效并重新拉取')

  // 4. 换号：即使不经过登出，也复位上一账号的权限/租户/缓存
  local.setItem('concise-auth', 'true')
  local.setItem('concise-user', 'alice')
  auth.login({ username: 'alice', name: 'Alice', role: 'viewer' })
  reset.resetSessionCaches('logout')
  auth.login({ username: 'alice', name: 'Alice', role: 'viewer' })
  auth.setTenantId(9)
  const accountEpoch = epoch.getSessionEpoch()
  auth.login({ username: 'bob', name: 'Bob', role: 'viewer' })
  assert.equal(auth.getUsername(), 'bob', '新账号应写入')
  assert.equal(auth.getTenantId(), null, '换号后不应继承旧租户视角')
  assert.ok(epoch.getSessionEpoch() > accountEpoch, '换号必须推进代次')
  assert.equal(events.length > 0, true, '复位/登录应广播事件')

  console.log('PASS: 会话级缓存复位（代次失效 / 在途丢弃 / 换号隔离）')
}

main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
