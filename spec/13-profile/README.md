# 13-profile - 我的模块

## 模块说明

用户个人中心和设置页面。

## 依赖模块

- 00-foundation
- 01-ui-components
- 03-navigation

## Web 对应

- `app/profile/page.tsx`
- `app/settings/page.tsx`

## 页面

| 页面 | 路由 | 说明 |
|------|------|------|
| ProfileScreen | `/profile` | 我的页面 |
| SettingsScreen | `/settings` | 设置页面 |

## 功能

### ProfileScreen
- 用户信息展示 (头像、昵称)
- 统计数据 (Todo完成数、日记篇数等)
- 快捷入口

### SettingsScreen
- 主题切换 (深色/浅色/跟随系统)
- 数据管理 (导出/导入/清除)
- 关于应用

## 核心文件

```
lib/ui/screens/profile/
├── profile_screen.dart
└── widgets/
    ├── user_header.dart
    └── stats_card.dart

lib/ui/screens/settings/
├── settings_screen.dart
└── widgets/
    ├── theme_selector.dart
    └── data_management.dart
```

## 状态

- [x] 设计完成
- [x] 开发完成
- [ ] 测试完成
- [ ] 发布就绪

## 相关文档

- [设计文档](./design.md)
- [任务明细](./tasks.md)
- [变更记录](./changelog.md)
