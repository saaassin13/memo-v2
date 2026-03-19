# 23-accounting 变更记录

## [1.0.0] - 2026-03-19

### 新增
- AccountingScreen 主页面，支持月份切换和收入/支出 Tab 切换
- MonthlySummary 月度汇总组件，展示收入/支出/结余
- TransactionList 交易记录列表组件，支持按日期分组、分类图标显示、滑动删除
- CategoryChart 分类饼图组件，使用 fl_chart 实现分类占比可视化
- AddTransactionSheet 新增交易记录弹窗，支持类型切换、金额输入、分类选择、日期选择、备注输入
- CategoryConfig 分类配置，包含支出 8 类（餐饮、交通、购物、娱乐、住房、医疗、教育、其他）和收入 5 类（工资、奖金、投资、礼金、其他）

### 依赖
- 使用已有的 transactionProvider 和 TransactionRepository
- 集成 fl_chart 包用于图表展示
