# 03-navigation - 导航系统

## 模块说明

底部导航栏、页面路由配置、导航守卫等。

## 依赖模块

- 00-foundation
- 01-ui-components

## 被依赖模块

- 所有页面模块

## 核心文件

```
lib/core/router/
├── app_router.dart              # go_router 配置
├── routes.dart                  # 路由常量
└── page_transitions.dart        # 页面转场动画

lib/ui/layouts/
└── mobile_layout.dart           # 底部导航布局

lib/ui/screens/calendar/
└── calendar_event_screen.dart   # 日历事件详情页
```

## 路由结构

| 路由 | 页面 | Tab |
|------|------|-----|
| `/` | 首页 (AppsGrid) | 应用 |
| `/todo` | Todo 列表 | Todo |
| `/calendar` | 日历视图 | 日历 |
| `/calendar/event/:id` | 事件详情 | - |
| `/profile` | 我的 | 我的 |
| `/settings` | 设置 | - |
| `/apps/memo` | 备忘录列表 | - |
| `/apps/memo/new` | 新建备忘录 | - |
| `/apps/memo/:id` | 备忘录详情 | - |
| `/apps/diary` | 日记列表 | - |
| `/apps/diary/new` | 新建日记 | - |
| `/apps/diary/:id` | 日记详情 | - |
| `/apps/countdown` | 倒数日 | - |
| `/apps/accounting` | 记账 | - |
| `/apps/goals` | 目标列表 | - |
| `/apps/goals/:id` | 目标详情 | - |
| `/apps/weight` | 体重记录 | - |

## 底部导航

| Tab | 图标 | 路由 |
|-----|------|------|
| 应用 | LayoutGrid | `/` |
| Todo | CheckSquare | `/todo` |
| 日历 | Calendar | `/calendar` |
| 我的 | User | `/profile` |

## 转场动画

| 动画类型 | 说明 | 使用场景 |
|----------|------|----------|
| slideFromRight | 从右侧滑入 | 默认 push 导航 |
| slideFromBottom | 从底部滑入 | 新建/编辑页面 |
| fade | 淡入淡出 | 轻量级页面切换 |
| fadeScale | 淡入缩放 | 详情页面 |

## 深度链接

### URL Scheme
- `memoapp://` (Android & iOS)

### Universal Links / App Links
- `https://memoapp.example.com/*`

### 示例
- `memoapp://todo` - 打开 Todo 列表
- `memoapp://apps/memo/123` - 打开指定备忘录
- `https://memoapp.example.com/calendar` - 打开日历

## 状态

- [x] 设计完成
- [x] 开发完成
- [ ] 测试完成
- [ ] 发布就绪

## 相关文档

- [设计文档](./design.md)
- [任务明细](./tasks.md)
- [变更记录](./changelog.md)
