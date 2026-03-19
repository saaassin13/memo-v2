# 12-calendar - 日历模块

## 模块说明

日历视图，展示 Todo 截止日期、日记、倒数日等事件。

## 依赖模块

- 00-foundation
- 01-ui-components (EventCard)
- 02-data-layer (todoProvider, diaryProvider, countdownProvider)
- 03-navigation

## Web 对应

- `app/calendar/page.tsx`
- `components/calendar-view.tsx`
- `components/event-card.tsx`

## 页面

| 页面 | 路由 | 说明 |
|------|------|------|
| CalendarScreen | `/calendar` | 日历主页面 |
| CalendarEventScreen | `/calendar/event/:id` | 事件详情 |

## 视图模式

- 日视图: 单日事件列表
- 周视图: 一周概览
- 月视图: 月历 + 事件指示

## 事件来源

| 来源 | 类型 | 颜色 |
|------|------|------|
| Todo | todo | primary |
| 日记 | diary | accent |
| 倒数日 | countdown | chart4 |

## 核心文件

```
lib/ui/screens/calendar/
├── calendar_screen.dart
├── calendar_event_screen.dart
└── widgets/
    ├── calendar_header.dart
    ├── day_view.dart
    ├── week_view.dart
    └── month_view.dart

lib/providers/
└── calendar_event_provider.dart
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
