# 23-accounting - 记账模块

## 模块说明

收支记账，支持按月统计、分类统计。

## 依赖模块

- 00-foundation
- 01-ui-components
- 02-data-layer (transactionProvider)
- 03-navigation
- fl_chart (图表)

## Web 对应

- `app/apps/accounting/page.tsx`

## 页面

| 页面 | 路由 | 说明 |
|------|------|------|
| AccountingScreen | `/apps/accounting` | 记账主页 |

## 功能

- 月度收支概览 (收入/支出/结余)
- 交易记录列表
- 分类统计图表
- 收入/支出分类
- 新建/删除记录

## 分类

**支出分类**: 餐饮, 交通, 购物, 娱乐, 住房, 医疗, 教育, 其他
**收入分类**: 工资, 奖金, 投资, 礼金, 其他

## 核心文件

```
lib/ui/screens/accounting/
├── accounting_screen.dart
└── widgets/
    ├── monthly_summary.dart
    ├── transaction_list.dart
    ├── category_chart.dart
    └── add_transaction_sheet.dart
```

## 状态

- [x] 设计完成
- [x] 开发完成 (2026-03-19)
- [ ] 测试完成
- [ ] 发布就绪
