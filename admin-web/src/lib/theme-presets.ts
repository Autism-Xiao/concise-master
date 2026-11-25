// 主题预设 barrel：保持原有 @/lib/theme-presets 导入路径不变，
// 内部拆分为纯数据（theme-colors.data）与纯函数（theme-color.util）。
export type { ThemeColorPreset } from './theme-colors.data'
export { THEME_COLORS } from './theme-colors.data'
export { getThemeColorPreset, hexToOklch, buildCustomThemeVars, buildThemeColorCss, buildFilterCss } from './theme-color.util'
