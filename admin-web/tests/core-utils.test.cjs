const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')
const ts = require('typescript')

/** 用 transpileModule + vm 沙箱加载单个 TS 模块，require 由调用方按 id 显式提供 */
function loadTs(relPath, mocks = {}) {
  const filename = path.resolve(__dirname, '..', relPath)
  const source = fs.readFileSync(filename, 'utf8')
  const { outputText } = ts.transpileModule(source, {
    compilerOptions: {
      module: ts.ModuleKind.CommonJS,
      target: ts.ScriptTarget.ES2022,
      jsx: ts.JsxEmit.ReactJSX
    }
  })
  const module = { exports: {} }
  vm.runInNewContext(outputText, {
    module,
    exports: module.exports,
    require(id) {
      if (Object.prototype.hasOwnProperty.call(mocks, id)) return mocks[id]
      throw new Error(`Unexpected import: ${id}`)
    }
  })
  return module.exports
}

async function main() {
  // ---------- form-validation：必填 / 整数范围 / 批量校验 ----------
  const formValidation = loadTs('src/lib/form-validation.tsx', {
    react: { useState: () => [{}, () => {}] },
    'react/jsx-runtime': { jsx: () => null, jsxs: () => null, Fragment: 'Fragment' }
  })
  assert.equal(typeof formValidation.validateFields, 'function', '缺少 validateFields')
  assert.equal(formValidation.required('姓名')(''), '请填写姓名')
  assert.equal(formValidation.required('姓名')('   '), '请填写姓名')
  assert.equal(formValidation.required('姓名')('张三'), null)
  const intRange = formValidation.intRange(1, 10, '排序')
  assert.equal(intRange('3'), null)
  assert.equal(intRange('0'), '排序须在 1 ~ 10 之间')
  assert.equal(intRange('2.5'), '排序须为整数')
  const formErrors = formValidation.validateFields(
    { name: [formValidation.required('姓名')], sort: [formValidation.intRange(1, 10, '排序')] },
    { name: '', sort: 3 }
  )
  assert.deepEqual({ ...formErrors }, { name: '请填写姓名' }, '批量校验应只返回第一条错误')
  const zero = formValidation.validateFields({ sort: [formValidation.intRange(0, 10, '排序')] }, { sort: 0 })
  assert.deepEqual({ ...zero }, {}, '数字 0 转成字符串后不应被误判为空')
  console.log('PASS: form-validation 的 required / intRange / validateFields')

  // ---------- theme-color util：hex→OKLCH 与主题 CSS ----------
  const themeData = loadTs('src/lib/theme-colors.data.ts')
  const themeUtil = loadTs('src/lib/theme-color.util.ts', { './theme-colors.data': themeData })
  assert.equal(typeof themeUtil.hexToOklch, 'function', '缺少 hexToOklch')
  assert.equal(themeUtil.hexToOklch('不是颜色'), null)
  const red = themeUtil.hexToOklch('#ff0000')
  assert.ok(red && typeof red.l === 'number' && typeof red.c === 'number' && typeof red.h === 'number')
  assert.ok(red.c > 0, '红色应有彩度')
  assert.ok(red.h >= 0 && red.h < 360, '色相应落在 0~360')
  const white = themeUtil.hexToOklch('#ffffff')
  assert.ok(white && white.c < 0.01, '白色彩度应接近 0')
  assert.equal(themeUtil.buildThemeColorCss('default'), '')
  assert.equal(themeUtil.buildThemeColorCss('custom'), '', '未指定自定义颜色时不应生成 CSS')
  const presetCss = themeUtil.buildThemeColorCss('tangerine')
  assert.ok(presetCss.startsWith('html:root{') && presetCss.includes('html.dark{'))
  assert.ok(presetCss.includes('--primary:oklch('), '预设主题应输出主色变量')
  const customCss = themeUtil.buildThemeColorCss('custom', '#ff0000')
  assert.ok(customCss.startsWith('html:root{') && customCss.includes('--primary:oklch('))
  console.log('PASS: theme-color util 的 hexToOklch / buildThemeColorCss')

  // ---------- dept-tree util：组树与子树 id 收集 ----------
  const deptTree = loadTs('src/lib/dept-tree.util.ts')
  assert.equal(typeof deptTree.buildTree, 'function', '缺少 buildTree')
  const items = [
    { id: 'b', parentId: 'a', sortNo: 2 },
    { id: 'a', parentId: null, sortNo: 1 },
    { id: 'c', parentId: 'a', sortNo: 1 },
    { id: 'd', parentId: 'b', sortNo: 1 },
    { id: 'self', parentId: 'self', sortNo: 0 }
  ]
  const tree = deptTree.buildTree(items, (x, y) => x.sortNo - y.sortNo)
  assert.deepEqual([...tree.map(n => n.id)].sort(), ['a', 'self'], '顶级节点应为 a 与自环节点')
  const root = tree.find(n => n.id === 'a')
  assert.deepEqual([...root.children.map(n => n.id)], ['c', 'b'], '同级应按 sortNo 升序')
  assert.deepEqual([...root.children[1].children.map(n => n.id)], ['d'], '孙节点应挂到父节点下')
  const ids = deptTree.collectSubtreeIds('a', items)
  assert.deepEqual([...ids].sort(), ['a', 'b', 'c', 'd'], '应收集自身与全部后代')
  assert.equal(deptTree.formatDateTime(''), '-')
  console.log('PASS: dept-tree util 的 buildTree / collectSubtreeIds')
}

main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
