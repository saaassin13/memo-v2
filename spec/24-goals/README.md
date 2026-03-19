# 24-goals - 目标模块

## 模块说明

目标追踪，支持设置目标值、当前进度、截止日期。

## 依赖模块

- 00-foundation
- 01-ui-components
- 02-data-layer (goalProvider)
- 03-navigation

## Web 对应

- `app/apps/goals/page.tsx`
- `app/apps/goals/[id]/page.tsx`

## 页面

| 页面 | 路由 | 说明 |
|------|------|------|
| GoalsListScreen | `/apps/goals` | 目标列表 |
| GoalDetailScreen | `/apps/goals/:id` | 目标详情 |

## 功能

- 目标列表
- 进度展示 (进度条)
- 更新进度
- 新建/编辑/删除

## 核心文件

```
lib/ui/screens/goals/
├── goals_list_screen.dart
├── goal_detail_screen.dart
└── widgets/
    ├── goal_card.dart
    ├── progress_ring.dart
    └── goal_edit_sheet.dart
```

## 状态

- [x] 设计完成
- [x] 开发完成 (2026-03-19)
- [ ] 测试完成
- [ ] 发布就绪
