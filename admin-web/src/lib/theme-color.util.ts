// 主题颜色纯函数：hex→OKLCH 转换、自定义主题变量、CSS 覆盖规则与滤镜
import { THEME_COLORS, type ThemeColorPreset } from './theme-colors.data'

export function getThemeColorPreset(name: string): ThemeColorPreset {
  return THEME_COLORS.find(p => p.name === name) ?? THEME_COLORS[0]
}

// ---------- 自定义颜色 ----------
// 把 #rrggbb 转成 OKLCH（sRGB → linear → OKLab → OKLCH），供自定义主题色生成整套变量
export function hexToOklch(hex: string): { l: number; c: number; h: number } | null {
  const m = /^#?([0-9a-f]{6})$/i.exec(hex.trim())
  if (!m) return null
  const n = parseInt(m[1], 16)
  const toLin = (v: number) => {
    const s = v / 255
    return s <= 0.04045 ? s / 12.92 : Math.pow((s + 0.055) / 1.055, 2.4)
  }
  const lr = toLin((n >> 16) & 255)
  const lg = toLin((n >> 8) & 255)
  const lb = toLin(n & 255)
  const l_ = 0.4122214708 * lr + 0.5363325363 * lg + 0.0514459929 * lb
  const m_ = 0.2119034982 * lr + 0.6806995451 * lg + 0.1073969566 * lb
  const s_ = 0.0883024619 * lr + 0.2817188376 * lg + 0.6299787005 * lb
  const l3 = Math.cbrt(l_)
  const m3 = Math.cbrt(m_)
  const s3 = Math.cbrt(s_)
  const l = 0.2104542553 * l3 + 0.793617785 * m3 - 0.0040720468 * s3
  const a = 1.9779984951 * l3 - 2.428592205 * m3 + 0.4505937099 * s3
  const b = 0.0259040371 * l3 + 0.7827717662 * m3 - 0.808675766 * s3
  let h = (Math.atan2(b, a) * 180) / Math.PI
  if (h < 0) h += 360
  return { l, c: Math.sqrt(a * a + b * b), h }
}

const clampNum = (v: number, min: number, max: number) => Math.min(Math.max(v, min), max)
const round4 = (v: number) => Math.round(v * 10000) / 10000

// 由任意颜色生成整套主题变量：明度按角色取固定阶梯（与内置预设一致），色相/彩度跟随所选颜色
export function buildCustomThemeVars(hex: string): { light: Record<string, string>; dark: Record<string, string> } | null {
  const ok = hexToOklch(hex)
  if (!ok) return null
  const H = Math.round(ok.h * 100) / 100
  // 彩度限制在可读范围内，避免选了灰色/荧光色导致界面脏或刺眼
  const C = clampNum(ok.c, 0.05, 0.2)
  const p = (l: number, c: number, h = H) => `oklch(${round4(l)} ${round4(Math.max(c, 0))} ${round4(h)})`
  const primaryLight = p(clampNum(ok.l, 0.45, 0.68), C)
  const primaryDark = p(clampNum(ok.l + 0.12, 0.55, 0.75), C * 0.9)
  const light: Record<string, string> = {
    '--background': p(0.985, C * 0.05),
    '--foreground': p(0.15, C * 0.15),
    '--card': 'oklch(1 0 0)',
    '--card-foreground': p(0.15, C * 0.15),
    '--popover': 'oklch(1 0 0)',
    '--popover-foreground': p(0.15, C * 0.15),
    '--primary': primaryLight,
    '--primary-foreground': p(0.98, C * 0.05),
    '--secondary': p(0.93, C * 0.15),
    '--secondary-foreground': p(0.22, C * 0.25),
    '--muted': p(0.95, C * 0.06),
    '--muted-foreground': p(0.47, C * 0.15),
    '--accent': p(0.9, C * 0.25),
    '--accent-foreground': p(0.22, C * 0.25),
    '--destructive': 'oklch(0.55 0.22 25)',
    '--border': p(0.91, C * 0.11),
    '--input': p(0.91, C * 0.11),
    '--ring': primaryLight,
    '--chart-1': primaryLight,
    '--chart-2': p(0.6, C * 0.85, H + 30),
    '--chart-3': p(0.62, C * 0.8, H - 30),
    '--chart-4': p(0.68, C * 0.7, H + 60),
    '--chart-5': p(0.52, C * 0.9, H - 60),
    '--sidebar': p(0.975, C * 0.06),
    '--sidebar-foreground': p(0.26, C * 0.18),
    '--sidebar-primary': primaryLight,
    '--sidebar-primary-foreground': p(0.98, C * 0.05),
    '--sidebar-accent': p(0.93, C * 0.15),
    '--sidebar-accent-foreground': p(0.22, C * 0.25),
    '--sidebar-border': p(0.91, C * 0.11),
    '--sidebar-ring': primaryLight
  }
  const dark: Record<string, string> = {
    '--background': p(0.12, C * 0.13),
    '--foreground': p(0.92, C * 0.05),
    '--card': p(0.16, C * 0.15),
    '--card-foreground': p(0.92, C * 0.05),
    '--popover': p(0.16, C * 0.15),
    '--popover-foreground': p(0.92, C * 0.05),
    '--primary': primaryDark,
    '--primary-foreground': p(0.1, C * 0.1),
    '--secondary': p(0.22, C * 0.2),
    '--secondary-foreground': p(0.9, C * 0.06),
    '--muted': p(0.2, C * 0.1),
    '--muted-foreground': p(0.65, C * 0.12),
    '--accent': p(0.26, C * 0.25),
    '--accent-foreground': p(0.88, C * 0.06),
    '--destructive': 'oklch(0.55 0.22 25)',
    '--border': p(0.26, C * 0.18),
    '--input': p(0.26, C * 0.18),
    '--ring': primaryDark,
    '--chart-1': primaryDark,
    '--chart-2': p(0.6, C * 0.85, H + 30),
    '--chart-3': p(0.62, C * 0.8, H - 30),
    '--chart-4': p(0.68, C * 0.7, H + 60),
    '--chart-5': p(0.55, C * 0.9, H - 60),
    '--sidebar': p(0.1, C * 0.12),
    '--sidebar-foreground': p(0.85, C * 0.06),
    '--sidebar-primary': primaryDark,
    '--sidebar-primary-foreground': p(0.1, C * 0.1),
    '--sidebar-accent': p(0.2, C * 0.2),
    '--sidebar-accent-foreground': p(0.85, C * 0.06),
    '--sidebar-border': p(0.22, C * 0.16),
    '--sidebar-ring': primaryDark
  }
  return { light, dark }
}

// 生成覆盖 CSS 变量的 style 内容；default 返回空串（使用默认主题），custom 由所选颜色实时生成
// 选择器带 html 前缀提升优先级：html:root(0,1,1) > :root(0,1,0)、html.dark > .dark。
// 必须这样做：dev 模式下 index.css 由 JS 在运行时注入 head 末尾，晚于 transformIndexHtml
// 注入的主题 style，同优先级会按顺序被 index.css 的默认变量覆盖，导致刷新时「先默认色再主题色」闪烁
export function buildThemeColorCss(name: string, customColor?: string): string {
  if (name === 'custom') {
    if (!customColor) return ''
    const vars = buildCustomThemeVars(customColor)
    if (!vars) return ''
    const toCustomRules = (v: Record<string, string>) =>
      Object.entries(v)
        .map(([k, val]) => `${k}:${val}`)
        .join(';')
    return `html:root{${toCustomRules(vars.light)}}html.dark{${toCustomRules(vars.dark)}}`
  }
  const preset = getThemeColorPreset(name)
  if (preset.name === 'default') return ''
  const toRules = (vars: Record<string, string>) =>
    Object.entries(vars)
      .map(([k, v]) => `${k}:${v}`)
      .join(';')
  return `html:root{${toRules(preset.vars.light)}}html.dark{${toRules(preset.vars.dark)}}`
}

// 灰色 / 色弱模式滤镜
export function buildFilterCss(grayscale: boolean, colorWeak: boolean): string {
  const filters: string[] = []
  if (grayscale) filters.push('grayscale(1)')
  if (colorWeak) filters.push('invert(0.8)')
  return filters.length ? `html{filter:${filters.join(' ')}}` : ''
}
