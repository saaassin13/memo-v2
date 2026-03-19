# 21-diary - 日记模块

## 模块说明

日记记录，以日历视图为主，支持写日记、查看历史。

## 依赖模块

- 00-foundation
- 01-ui-components
- 02-data-layer (diaryProvider)
- 03-navigation

## Web 对应

- `app/apps/diary/page.tsx`
- `app/apps/diary/new/page.tsx`
- `app/apps/diary/[id]/page.tsx`

## 页面

| 页面 | 路由 | 说明 |
|------|------|------|
| DiaryListScreen | `/apps/diary` | 日记日历/列表 |
| DiaryEditScreen | `/apps/diary/new` | 新建日记 |
| DiaryDetailScreen | `/apps/diary/:id` | 日记详情/编辑 |

## 功能

- 日历选择日期
- 查看选中日期的日记
- 历史日记列表
- 天气选择 (晴/多云/雨/雪/雷雨/风)
- 心情选择 (开心/喜悦/爱/平静/难过/愤怒)
- 新建/编辑/删除

## 核心文件

```
lib/ui/screens/diary/
├── diary_list_screen.dart
├── diary_edit_screen.dart
├── diary_detail_screen.dart
└── widgets/
    ├── diary_calendar.dart
    ├── weather_selector.dart
    ├── mood_selector.dart
    └── diary_card.dart
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
