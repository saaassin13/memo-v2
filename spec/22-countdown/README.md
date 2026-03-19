# 22-countdown - 倒数纪念日模块

## 模块说明

倒数日/纪念日管理，支持正数(纪念日)和倒数(未来日期)。

## 依赖模块

- 00-foundation
- 01-ui-components
- 02-data-layer (countdownProvider)
- 03-navigation

## Web 对应

- `app/apps/countdown/page.tsx`

## 页面

| 页面 | 路由 | 说明 |
|------|------|------|
| CountdownScreen | `/apps/countdown` | 倒数日列表 |

## 功能

- 倒数日列表 (按日期排序)
- 分类: 生日/节日/重要日
- 每年重复选项
- 新建/编辑/删除
- 显示剩余天数 (未来) 或已过天数 (过去)

## 核心文件

```
lib/ui/screens/countdown/
├── countdown_screen.dart
└── widgets/
    ├── countdown_card.dart
    └── countdown_edit_sheet.dart
```

## 状态

- [x] 设计完成
- [x] 开发完成 (2026-03-19)
- [ ] 测试完成
- [ ] 发布就绪
