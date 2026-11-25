import { useContext, useEffect, type ReactNode } from 'react'
import { createHmrSafeContext } from '@/lib/hmr-context'
import { dictionaries, type TranslationKey } from '@/config/i18n'

/**
 * 文案入口
 *
 * 业务页面（200+ 文件）都是中文硬编码，只有导航/登录/设置外壳走词典，
 * 过去提供「切换 English」会变成中英混杂的半成品。现在统一以中文为唯一事实源，
 * 保留 t(key, params) 的类型检查和插值能力，界面不再提供误导性的语言开关。
 */
interface LocaleContextValue {
  t: (key: TranslationKey, params?: Record<string, string | number>) => string
}

const LocaleContext = createHmrSafeContext<LocaleContextValue | null>('concise.context.locale', null)

export function LocaleProvider({ children }: { children: ReactNode }) {
  useEffect(() => {
    document.documentElement.lang = 'zh-CN'
  }, [])

  const t = (key: TranslationKey, params?: Record<string, string | number>) => {
    const text = dictionaries.zh[key]
    if (!params) return text
    return text.replace(/\{(\w+)\}/g, (match, name: string) => (name in params ? String(params[name]) : match))
  }

  return <LocaleContext.Provider value={{ t }}>{children}</LocaleContext.Provider>
}

export function useLocale() {
  const ctx = useContext(LocaleContext)
  if (!ctx) throw new Error('useLocale 必须在 LocaleProvider 内使用')
  return ctx
}
