# 10-home - 首页模块

## 模块说明

应用首页，展示功能入口网格 (AppsGrid)。

## 依赖模块

- 00-foundation
- 01-ui-components
- 03-navigation

## Web 对应

- `app/page.tsx`
- `components/apps-grid.tsx`

## 页面

| 页面 | 路由 | 说明 |
|------|------|------|
| HomeScreen | `/` | 首页 |

## 功能入口

| 功能 | 图标 | 路由 |
|------|------|------|
| 备忘录 | FileText | `/apps/memo` |
| 倒数纪念日 | CalendarHeart | `/apps/countdown` |
| 日记 | BookOpen | `/apps/diary` |
| 记账 | Wallet | `/apps/accounting` |
| 目标 | Target | `/apps/goals` |
| 体重 | Scale | `/apps/weight` |

## 核心文件

```
lib/ui/screens/home/
├── home_screen.dart
└── widgets/
    └── apps_grid.dart
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
