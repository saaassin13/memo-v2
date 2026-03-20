# Hotfix Buglist

## 2026-03-20 日记模块改动

### 改动1: 日记页面点击日期行为优化
- **模块**: 21-diary
- **类型**: 需求修改
- **改动内容**:
  - 点击日历上的日期，不再跳转到日记详情页，改为在日历下方展示该日期的日记
  - 若该日期没有日记，则显示「新建日记」按钮，点击进入新建日记页面（日期自动填充为选中的日期）
  - 右上角按钮从「写日记」改为「管理日记」
- **涉及文件**:
  - `memo_app/lib/ui/screens/diary/diary_list_screen.dart` - 修改 onDateSelected 行为和 header 按钮
  - `memo_app/lib/core/router/routes.dart` - 新增 diaryManagement 路由
  - `memo_app/lib/core/router/app_router.dart` - 注册管理页面路由
- **状态**: 已完成

### 改动2: 日记管理页面
- **模块**: 21-diary
- **类型**: 新功能
- **改动内容**:
  - 新增 DiaryManagementScreen 页面
  - 显示日记总数
  - 支持周视图/月视图切换（TabBar）
  - 周视图：按周导航，展示该周所有日记
  - 月视图：按月导航，展示该月所有日记
  - 点击日记卡片进入日记详情页面
- **涉及文件**:
  - `memo_app/lib/ui/screens/diary/diary_management_screen.dart` - 新建页面
  - `memo_app/lib/data/repositories/diary_repository.dart` - 新增 getByWeek、getCount 方法
  - `memo_app/lib/providers/diary_provider.dart` - 新增 diariesByWeekProvider、diaryCountProvider
  - `memo_app/lib/core/router/routes.dart` - 新增 diaryManagement 路由
  - `memo_app/lib/core/router/app_router.dart` - 注册管理页面路由
- **状态**: 已完成
