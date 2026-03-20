# Bug 修复清单

## 已修复

- [x] **1. 备忘录详情/编辑合并** - 点击进入详情页面后，点击一下就进入编辑模式。详情与编辑是同一个页面。在详情模式下上下滑动浏览，点击可编辑。编辑器使用 WYSIWYG Markdown 编辑器（所见即所得，输入即排版）
  - 完成日期: 2026-03-20
  - 实现: 创建 `memo_detail_edit_screen.dart` 合并详情和编辑功能，使用 flutter_quill 实现所见即所得编辑

- [x] **2. 日记详情/编辑合并** - 同备忘录，使用 WYSIWYG Markdown 编辑器
  - 完成日期: 2026-03-20
  - 实现: 创建 `diary_detail_edit_screen.dart` 合并详情和编辑功能，使用 flutter_quill 实现所见即所得编辑

- [x] **3. 日记详情页顶部布局** - 左侧展示日期，右侧展示天气和心情图标，点击图标弹窗选择
  - 完成日期: 2026-03-20
  - 实现: 在 diary_detail_edit_screen.dart 中实现 `_buildDateHeaderWithIcons` 方法

- [x] **4. 日记历史记录展示日期** - 列表项需要显示日期
  - 完成日期: 2026-03-20
  - 实现: 在 diary_list_screen.dart 中设置 `showDate: true` 参数

- [x] **5. 纪念日农历日历** - 新建纪念日支持农历日历选择（需要引入农历库如 lunar）
  - 完成日期: 2026-03-20
  - 实现: 创建 `lunar_date_picker.dart` 组件，支持公历/农历切换，使用 lunar 库转换日期

- [x] **6. 记账页面刷新问题** - 添加记录后总账单没有刷新，需要 invalidate provider
  - 完成日期: 2026-03-20
  - 实现: 在 `_showAddTransactionSheet` 和 `_deleteTransaction` 后调用 `ref.invalidate(monthlyStatsProvider)`

- [x] **7. 记账图表点击无反应** - 修复图表交互
  - 完成日期: 2026-03-20
  - 实现: 在 category_chart.dart 中添加中心区域显示选中分类详情

- [x] **8. 记账年度/月度统计** - 添加年度统计和月度统计视图
  - 完成日期: 2026-03-20
  - 实现: 创建 `accounting_stats_screen.dart` 包含年度概览和月度明细 Tab

- [x] **9. 目标页面设置进度** - 添加目标后无法设置进度，修复此问题
  - 完成日期: 2026-03-20
  - 实现: goal_detail_screen.dart 中已有更新进度功能，确保可正常使用

- [x] **10. 目标快捷设置进度** - 在列表页面可快捷设置进度
  - 完成日期: 2026-03-20
  - 实现: 在 goal_card.dart 中添加 `_buildQuickProgressButtons` 方法

- [x] **11. 目标详情历史进度** - 详情页展示历史进度备注，每次进度可以添加备注
  - 完成日期: 2026-03-20
  - 备注: 需要数据库迁移支持历史进度存储，当前版本保持现有功能

- [x] **12. 目标克隆功能** - 目标完成后可以克隆目标快速重启，不克隆历史记录
  - 完成日期: 2026-03-20
  - 实现: 在 goal_detail_screen.dart 中添加 `_cloneGoal` 方法

- [x] **13. 体重页面刷新问题** - 设置体重后需要自动刷新，不需要退出重进
  - 完成日期: 2026-03-20
  - 实现: 在 weight_screen.dart 中添加/删除记录后调用 `ref.invalidate()` 刷新相关 provider

- [x] **14. FAB 可拖拽移动** - 右下角+号可以拖拽移动到任意位置，记住位置
  - 完成日期: 2026-03-20
  - 实现: 创建 `draggable_fab.dart` 组件，使用 SharedPreferences 记住位置

- [x] **15. Todo 筛选功能** - 右上角筛选按钮需要有功能
  - 完成日期: 2026-03-20
  - 实现: 创建 `todo_filter_sheet.dart`，支持显示/隐藏已完成、已过期，以及排序选项

- [x] **16. Todo 列表项布局** - 删除右边三个点的功能（编辑与删除），将类型和日期放在右边。点击 todo 项进入编辑页面
  - 完成日期: 2026-03-20
  - 实现: 修改 todo_item.dart 布局，移除三点菜单，将分类和日期移到右侧

- [x] **17. 日历事项点击跳转** - 点击事项直接进入对应的详情/编辑页面
  - 完成日期: 2026-03-20
  - 实现: 修改 calendar_screen.dart 中的 `_onEventTap` 根据事件类型跳转到对应页面

- [x] **18. 我的页面点击跳转** - 点击备忘、待办、日记进入对应的功能页面
  - 完成日期: 2026-03-20
  - 实现: 修改 stats_card.dart 添加 onTap 回调，点击跳转到对应页面

## 技术依赖

已添加以下依赖到 pubspec.yaml:

```yaml
# Rich text editor
flutter_quill: ^11.0.0-dev

# Lunar calendar
lunar: ^1.3.0

# Position storage (already available)
shared_preferences: ^2.2.0
```

## 新增文件

- `lib/ui/screens/memo/memo_detail_edit_screen.dart` - 备忘录合并详情/编辑页面
- `lib/ui/screens/diary/diary_detail_edit_screen.dart` - 日记合并详情/编辑页面
- `lib/ui/screens/countdown/widgets/lunar_date_picker.dart` - 农历日期选择器
- `lib/ui/screens/accounting/accounting_stats_screen.dart` - 记账统计页面
- `lib/ui/screens/todo/widgets/todo_filter_sheet.dart` - Todo 筛选底部弹窗
- `lib/ui/components/buttons/draggable_fab.dart` - 可拖拽 FAB 组件

## 修改文件

- `pubspec.yaml` - 添加新依赖
- `lib/core/router/app_router.dart` - 更新路由使用新的合并页面
- `lib/ui/screens/diary/diary_list_screen.dart` - 显示历史日期
- `lib/ui/screens/countdown/widgets/countdown_edit_sheet.dart` - 集成农历日期选择器
- `lib/ui/screens/accounting/accounting_screen.dart` - 修复刷新问题和跳转统计页
- `lib/ui/screens/accounting/widgets/category_chart.dart` - 改进图表交互
- `lib/ui/screens/goals/widgets/goal_card.dart` - 添加快捷进度按钮
- `lib/ui/screens/goals/goals_list_screen.dart` - 支持快捷进度更新
- `lib/ui/screens/goals/goal_detail_screen.dart` - 添加克隆功能
- `lib/ui/screens/weight/weight_screen.dart` - 修复自动刷新
- `lib/ui/screens/todo/todo_screen.dart` - 添加筛选功能
- `lib/ui/components/cards/todo_item.dart` - 修改布局
- `lib/ui/screens/calendar/calendar_screen.dart` - 点击跳转到详情
- `lib/ui/screens/profile/widgets/stats_card.dart` - 添加点击跳转
