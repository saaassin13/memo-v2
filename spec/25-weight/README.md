# 25-weight - 体重模块

## 模块说明

体重记录追踪，支持图表展示趋势。

## 依赖模块

- 00-foundation
- 01-ui-components
- 02-data-layer (weightProvider)
- 03-navigation
- fl_chart (图表)

## Web 对应

- `app/apps/weight/page.tsx`

## 页面

| 页面 | 路由 | 说明 |
|------|------|------|
| WeightScreen | `/apps/weight` | 体重记录主页 |

## 功能

- 最新体重显示
- 体重趋势图 (折线图)
- 记录列表
- 是否运动标记
- 新建/删除记录
- 统计数据 (最高/最低/平均)

## 核心文件

```
lib/ui/screens/weight/
├── weight_screen.dart
└── widgets/
    ├── weight_summary.dart
    ├── weight_chart.dart
    ├── weight_record_list.dart
    └── add_weight_sheet.dart
```

## 状态

- [x] 设计完成
- [x] 开发完成
- [ ] 测试完成
- [ ] 发布就绪
