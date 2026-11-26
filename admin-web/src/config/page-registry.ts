import { lazy, type ComponentType } from 'react'
import type { LucideIcon } from 'lucide-react'
import {
  Bell,
  BookOpen,
  Briefcase,
  Bug,
  Building2,
  CalendarDays,
  Database,
  Droplets,
  FolderOpen,
  HelpCircle,
  History,
  LayoutDashboard,
  ListTodo,
  ListTree,
  LogIn,
  Mail,
  MapPin,
  Medal,
  Megaphone,
  Keyboard,
  Monitor,
  Network,
  Palette,
  ScrollText,
  Server,
  Settings,
  Stamp,
  ShieldCheck,
  Timer,
  UserCheck,
  UserCog,
  Users,
  Wrench
} from 'lucide-react'
import type { TranslationKey } from '@/config/i18n'

// 页签栏/页面渲染共用的路由登记表：path → 页面组件 + 标题 + 图标
// 组件全部按需加载：这里只保留标题/图标等元数据，页面 JS 在进入页签时才下载。
// 注意：这里的组件绕过了路由 Outlet 直接渲染，新增页面时需要在此登记。
export interface PageEntry {
  component: ComponentType
  /** 走 i18n 的标题 key（导航项） */
  titleKey?: TranslationKey
  /** 固定中文标题（设置子页，与设置中心子导航一致） */
  label?: string
  icon: LucideIcon
  /** 为 true 时页面渲染在设置中心布局内（左侧带子导航） */
  settings?: boolean
}

export const HOME_PATH = '/dashboard'

export const PAGE_REGISTRY: Record<string, PageEntry> = {
  '/system/biz_orders': {
    component: lazy(() => import('@/features/biz_order').then(m => ({ default: m.BizOrderPage }))),
    titleKey: 'nav.system.bizOrder',
    icon: Briefcase
  },
  '/system/customers': {
    component: lazy(() => import('@/features/customer').then(m => ({ default: m.CustomerPage }))),
    titleKey: 'nav.system.customer',
    icon: Briefcase
  },
  '/system/codegen': {
    component: lazy(() => import('@/features/system/codegen').then(m => ({ default: m.CodegenPage }))),
    titleKey: 'nav.system.codegen',
    icon: Wrench
  },
  '/dashboard': {
    component: lazy(() => import('@/features/dashboard').then(m => ({ default: m.DashboardPage }))),
    titleKey: 'nav.dashboard',
    icon: LayoutDashboard
  },
  '/help-center': {
    component: lazy(() => import('@/features/help-center').then(m => ({ default: m.HelpCenterPage }))),
    titleKey: 'nav.helpCenter',
    icon: HelpCircle
  },
  '/system/users': {
    component: lazy(() => import('@/features/users').then(m => ({ default: m.UsersPage }))),
    titleKey: 'nav.system.users',
    icon: Users
  },
  '/system/menu': {
    component: lazy(() => import('@/features/system/menu').then(m => ({ default: m.MenuPage }))),
    titleKey: 'nav.system.menu',
    icon: ListTree
  },
  '/system/role': {
    component: lazy(() => import('@/features/system/role').then(m => ({ default: m.RolePage }))),
    titleKey: 'nav.system.role',
    icon: ShieldCheck
  },
  '/system/grant': {
    component: lazy(() => import('@/features/system/grant').then(m => ({ default: m.GrantPage }))),
    titleKey: 'nav.system.grant',
    icon: ShieldCheck
  },
  '/system/data-rule': {
    component: lazy(() => import('@/features/system/data-rule').then(m => ({ default: m.DataRulePage }))),
    titleKey: 'nav.system.dataRule',
    icon: ListTree
  },
  '/system/dept': {
    component: lazy(() => import('@/features/system/dept').then(m => ({ default: m.DeptPage }))),
    titleKey: 'nav.system.dept',
    icon: Network
  },
  '/system/level': {
    component: lazy(() => import('@/features/system/level').then(m => ({ default: m.LevelPage }))),
    titleKey: 'nav.system.level',
    icon: Medal
  },
  '/system/post': {
    component: lazy(() => import('@/features/system/post').then(m => ({ default: m.PostPage }))),
    titleKey: 'nav.system.post',
    icon: Briefcase
  },
  '/system/task': {
    component: lazy(() => import('@/features/system/task').then(m => ({ default: m.TaskPage }))),
    titleKey: 'nav.system.task',
    icon: ListTodo
  },
  '/system/tenant': {
    component: lazy(() => import('@/features/system/tenant').then(m => ({ default: m.TenantPage }))),
    titleKey: 'nav.system.tenant',
    icon: Building2
  },
  '/system/file': {
    component: lazy(() => import('@/features/system/file').then(m => ({ default: m.FilePage }))),
    titleKey: 'nav.system.file',
    icon: FolderOpen
  },
  '/system/calendar': {
    component: lazy(() => import('@/features/system/calendar').then(m => ({ default: m.CalendarPage }))),
    titleKey: 'nav.system.calendar',
    icon: CalendarDays
  },
  '/system/dict': {
    component: lazy(() => import('@/features/system/dict').then(m => ({ default: m.DictPage }))),
    titleKey: 'nav.system.dict',
    icon: BookOpen
  },
  '/system/notice': {
    component: lazy(() => import('@/features/system/notice').then(m => ({ default: m.NoticePage }))),
    titleKey: 'nav.system.notice',
    icon: Megaphone
  },
  '/system/message': {
    component: lazy(() => import('@/features/system/message').then(m => ({ default: m.MessagePage }))),
    titleKey: 'nav.system.message',
    icon: Mail
  },
  '/system/suppliers': {
    component: lazy(() => import('@/features/supplier').then(m => ({ default: m.SupplierPage }))),
    titleKey: 'nav.system.supplier',
    icon: Briefcase
  },
  '/system/region': {
    component: lazy(() => import('@/features/system/region').then(m => ({ default: m.RegionPage }))),
    titleKey: 'nav.system.region',
    icon: MapPin
  },
  '/system/log/login': {
    component: lazy(() => import('@/features/system/log/login').then(m => ({ default: m.LoginLogPage }))),
    titleKey: 'nav.system.logLogin',
    icon: LogIn
  },
  '/system/log/operation': {
    component: lazy(() => import('@/features/system/log/operation').then(m => ({ default: m.OperationLogPage }))),
    titleKey: 'nav.system.logOperation',
    icon: ScrollText
  },
  '/system/log/change': {
    component: lazy(() => import('@/features/system/log/change').then(m => ({ default: m.ChangeLogPage }))),
    titleKey: 'nav.system.logChange',
    icon: History
  },
  '/system/config': {
    component: lazy(() => import('@/features/system/config').then(m => ({ default: m.ConfigPage }))),
    titleKey: 'nav.system.config',
    icon: Settings
  },
  '/system/app': {
    component: lazy(() => import('@/features/system/app').then(m => ({ default: m.OpenPlatformPage }))),
    titleKey: 'nav.system.openapp',
    icon: Network
  },
  '/ops/job': {
    component: lazy(() => import('@/features/ops/job').then(m => ({ default: m.JobPage }))),
    titleKey: 'nav.ops.job',
    icon: Timer
  },
  '/ops/online': {
    component: lazy(() => import('@/features/ops/online').then(m => ({ default: m.OnlineUsersPage }))),
    titleKey: 'nav.ops.online',
    icon: UserCheck
  },
  '/ops/server': {
    component: lazy(() => import('@/features/ops/server').then(m => ({ default: m.ServerMonitorPage }))),
    titleKey: 'nav.ops.server',
    icon: Server
  },
  '/ops/cache': {
    component: lazy(() => import('@/features/ops/cache').then(m => ({ default: m.CacheMonitorPage }))),
    titleKey: 'nav.ops.cache',
    icon: Database
  },
  '/errors/401': {
    component: lazy(() => import('@/features/errors').then(m => ({ default: m.UnauthorizedError }))),
    titleKey: 'nav.errors.401',
    icon: Bug
  },
  '/errors/403': {
    component: lazy(() => import('@/features/errors').then(m => ({ default: m.ForbiddenError }))),
    titleKey: 'nav.errors.403',
    icon: Bug
  },
  '/errors/404': {
    component: lazy(() => import('@/features/errors').then(m => ({ default: m.NotFoundError }))),
    titleKey: 'nav.errors.404',
    icon: Bug
  },
  '/errors/500': {
    component: lazy(() => import('@/features/errors').then(m => ({ default: m.InternalServerError }))),
    titleKey: 'nav.errors.500',
    icon: Bug
  },
  '/errors/503': {
    component: lazy(() => import('@/features/errors').then(m => ({ default: m.MaintenanceError }))),
    titleKey: 'nav.errors.503',
    icon: Bug
  },
  '/settings': {
    component: lazy(() => import('@/features/settings/profile').then(m => ({ default: m.ProfilePage }))),
    label: '个人资料',
    icon: UserCog,
    settings: true
  },
  '/settings/account': {
    component: lazy(() => import('@/features/settings/account').then(m => ({ default: m.AccountPage }))),
    label: '账户',
    icon: Wrench,
    settings: true
  },
  '/settings/appearance': {
    component: lazy(() => import('@/features/settings/appearance').then(m => ({ default: m.AppearancePage }))),
    label: '外观',
    icon: Palette,
    settings: true
  },
  '/settings/watermark': {
    component: lazy(() => import('@/features/settings/watermark').then(m => ({ default: m.WatermarkSettingPage }))),
    label: '水印策略',
    icon: Droplets,
    settings: true
  },
  '/settings/notifications': {
    component: lazy(() => import('@/features/settings/notifications').then(m => ({ default: m.NotificationsPage }))),
    label: '通知',
    icon: Bell,
    settings: true
  },
  '/settings/display': {
    component: lazy(() => import('@/features/settings/display').then(m => ({ default: m.DisplayPage }))),
    label: '显示',
    icon: Monitor,
    settings: true
  },
  '/settings/shortcuts': {
    component: lazy(() => import('@/features/settings/shortcuts').then(m => ({ default: m.ShortcutsPage }))),
    label: '快捷键',
    icon: Keyboard,
    settings: true
  },
  '/settings/my-watermark': {
    component: lazy(() => import('@/features/settings/my-watermark').then(m => ({ default: m.MyWatermarkPage }))),
    label: '我的水印',
    icon: Stamp,
    settings: true
  }
}

export function isRegisteredPage(path: string): boolean {
  return path in PAGE_REGISTRY
}
