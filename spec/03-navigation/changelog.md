# 03-navigation 变更记录

## [1.0.0] - 2026-03-19

### Added
- N-001: 路由常量定义 (`lib/core/router/routes.dart`)
  - 主 Tab 路由 (home, todo, calendar, profile)
  - 设置页面路由
  - 备忘录、日记、倒数日、记账、目标、体重模块路由
  - 日历事件详情路由

- N-002: go_router 路由配置 (`lib/core/router/app_router.dart`)
  - ShellRoute 底部导航 Shell
  - 各功能模块路由配置
  - 嵌套路由支持
  - 动态参数路由 (:id)

- N-003: MobileLayout 底部导航布局 (`lib/ui/layouts/mobile_layout.dart`)
  - 4 个 Tab (应用、Todo、日历、我的)
  - Lucide 图标集成
  - 选中状态高亮
  - 自动识别当前路由

- N-004: 页面转场动画 (`lib/core/router/page_transitions.dart`)
  - slideFromRight: 从右侧滑入 (默认 push)
  - slideFromBottom: 从底部滑入 (新建页面)
  - fade: 淡入淡出
  - fadeScale: 淡入缩放
  - none: 无动画

- N-005: 深度链接支持
  - Android Deep Links (memoapp:// scheme)
  - Android App Links (https://memoapp.example.com)
  - iOS Custom URL Scheme (memoapp://)
  - iOS Universal Links (Associated Domains)
  - Flutter Deep Linking 启用

- 新增日历事件详情页 (`lib/ui/screens/calendar/calendar_event_screen.dart`)

### Changed
- 无

### Impact
- 所有页面模块现可通过路由访问
- 支持从外部链接打开应用指定页面

---

## 变更模板

### [版本号] - YYYY-MM-DD

#### Added
- 新增路由

#### Changed
- 路由变更

#### Impact
- 影响的页面
