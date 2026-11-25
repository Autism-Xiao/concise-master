const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')
const ts = require('typescript')

const ROOT = path.resolve(__dirname, '..')
const source = fs.readFileSync(path.join(ROOT, 'src/lib/tabs-model.ts'), 'utf8')
const { outputText } = ts.transpileModule(source, {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 }
})
const sandboxModule = { exports: {} }
vm.runInNewContext(outputText, { module: sandboxModule, exports: sandboxModule.exports, require: () => ({}), Date })
const { touchTab, evictLru, insertTabLru } = sandboxModule.exports

{
  const tabs = [
    { path: '/dashboard', pinned: true, lastActive: 0 },
    { path: '/a', lastActive: 10 },
    { path: '/b', lastActive: 20 }
  ]
  assert.equal(touchTab(tabs, '/missing', 99), tabs, '不存在的标签不应创建新数组')
  assert.deepEqual(touchTab(tabs, '/a', 99).find(t => t.path === '/a').lastActive, 99, '再次访问应刷新时间')
}

{
  const tabs = [
    { path: '/dashboard', pinned: true, lastActive: 0 },
    { path: '/b', lastActive: 20 },
    { path: '/a', lastActive: 10 },
    { path: '/c', lastActive: 30 }
  ]
  const next = evictLru(tabs, '/c', 3)
  assert.equal(
    JSON.stringify(next.map(t => t.path)),
    JSON.stringify(['/dashboard', '/b', '/c']),
    '应淘汰最久未访问的 /a，固定标签与当前标签保留'
  )
  assert.equal(tabs.length, 4, '纯函数不应修改入参')
}

{
  const tabs = [
    { path: '/dashboard', pinned: true, lastActive: 0 },
    { path: '/a', lastActive: 10 },
    { path: '/b', lastActive: 20 }
  ]
  assert.equal(insertTabLru(tabs, '/a', 99, 3).find(t => t.path === '/a').lastActive, 99, '重开已有标签视为访问')
  const next = insertTabLru(tabs, '/c', 30, 3)
  assert.equal(
    JSON.stringify(next.map(t => t.path)),
    JSON.stringify(['/dashboard', '/b', '/c']),
    '新标签超上限时按 LRU 淘汰'
  )
}

console.log('PASS: 标签页 LRU（访问刷新 / 固定页保护 / 超上限淘汰）')
