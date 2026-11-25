const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')
const ts = require('typescript')

const ROOT = path.resolve(__dirname, '..')
const source = fs.readFileSync(path.join(ROOT, 'src/lib/toast-error.ts'), 'utf8')
const { outputText } = ts.transpileModule(source, {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 }
})

const messages = []
const sandboxModule = { exports: {} }
vm.runInNewContext(outputText, {
  module: sandboxModule,
  exports: sandboxModule.exports,
  require(id) {
    if (id === 'sonner') return { toast: { error: message => messages.push(message) } }
    if (id === '@/lib/api-error') {
      return {
        userMessageOf: (error, fallback) => {
          if (error && typeof error === 'object' && error.myMessage) return error.myMessage
          return fallback
        }
      }
    }
    throw new Error(`Unexpected import: ${id}`)
  }
})

sandboxModule.exports.toastError({ myMessage: '后端返回的中文原因' })
sandboxModule.exports.toastError(new TypeError('Failed to fetch'), '默认兜底')
assert.deepEqual(messages, ['后端返回的中文原因', '默认兜底'], '错误提示必须走统一文案出口')

console.log('PASS: 错误提示统一走 userMessageOf 中文兜底')
