# 12-calendar 变更记录

## [1.0.0] - 2026-03-19

### 新增
- CalendarScreen 主页面，支持日/周/月三种视图模式切换
- CalendarHeader 组件，包含标题和视图模式切换按钮
- MonthView 月视图组件，显示月历网格和事件指示点
- WeekView 周视图组件，显示一周七天的事件
- DayView 日视图组件，显示单日详细事件列表
- CalendarEvent Provider，聚合 Todo、Diary、Countdown 三种事件源
- CalendarEventScreen 事件详情页，支持跳转到对应模块

### 功能特性
- 月份/周/日期导航，点击标题可快速回到今天
- 事件按类型显示不同颜色指示点（待办-蓝色、日记-绿色、倒数日-粉色）
- 空状态友好提示
- 支持周年重复的纪念日在日历中显示
- 事件详情页根据类型提供跳转到原模块的入口
