# Bug 修复清单

## 2026-03-20 新增 Bug 修复

- [x] **25. 备忘录-编辑详情页面置顶按钮问题**
  - 问题: 置顶按钮点击后没有切换图标，点击屏幕只有特定区域才能进入编辑页面
  - 完成日期: 2026-03-20
  - 修复:
    - 置顶按钮: 将 `_togglePin()` 改为 `async` 并等待完成，确保状态正确刷新
    - 点击区域: 在 `_buildContentDisplay` 中用 `IgnorePointer` 包裹 `QuillEditor`，使点击事件传递到外层 `GestureDetector`

- [x] **26. 备忘录-列表显示乱码**
  - 问题: 列表页面显示 Delta JSON 格式内容而不是纯文本
  - 完成日期: 2026-03-20
  - 修复:
    - 创建 `lib/core/utils/delta_utils.dart` 工具类，提供 `extractPlainText()` 方法
    - 修改 `memo_card.dart` 使用 `DeltaUtils.extractPlainText()` 显示内容预览

- [x] **27. 日记编辑页面乱码问题**
  - 问题: 同备忘录一样的乱码问题
  - 完成日期: 2026-03-20
  - 修复: 修改 `diary_card.dart` 使用 `DeltaUtils.extractPlainText()` 显示内容预览

- [x] **28. 日记列表去掉心情文字**
  - 问题: 日记列表中心情图标旁边有文字标签
  - 完成日期: 2026-03-20
  - 修复: 修改 `diary_card.dart` 移除 `mood.label` 文字，只保留 emoji

- [x] **29. 日记列表选择日期进入编辑页面**
  - 问题: 点击日历某天时，应该检查是否有日记并跳转到对应页面
  - 完成日期: 2026-03-20
  - 修复:
    - 在 `diary_list_screen.dart` 添加 `_handleDateSelected()` 方法
    - 有日记则跳转到详情编辑页面，无日记则跳转到新建页面并设置选中日期

- [x] **30. 已完成目标的设置菜单**
  - 问题: 已完成目标应该只显示"克隆目标"和"删除目标"选项
  - 完成日期: 2026-03-20
  - 修复: 修改 `goal_detail_screen.dart` 的 `_showSettingsMenu()`，根据 `goal.completed` 条件显示不同菜单项

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

- [x] **19. 备忘录编辑页面格式丢失** - 编辑内容保存后，再次进入格式丢失
  - 完成日期: 2026-03-20
  - 问题: flutter_quill 使用 Delta JSON 格式，需要正确序列化/反序列化
  - 实现: 保存时将 QuillController 的 document 转为 JSON 存储，加载时从 JSON 恢复

- [x] **20. 备忘录编辑框太小** - 正文编辑框要全屏，原来太小
  - 完成日期: 2026-03-20
  - 实现: 使用 Expanded 让 QuillEditor 占满剩余空间

- [x] **21. 日记编辑页面格式丢失 + 编辑框太小** - 同备忘录问题
  - 完成日期: 2026-03-20
  - 实现: 同备忘录方案

- [x] **22. 日记编辑页面去掉天气心情展示** - 已经有点击弹出了，不需要重复展示
  - 完成日期: 2026-03-20
  - 实现: 去掉天气心情的固定展示区域，只在顶部显示图标，点击弹出选择

- [x] **23. 目标详情页重新设计** - 去掉进度更新 UI，改为设置菜单，展示历史进度
  - 完成日期: 2026-03-20
  - 实现:
    - 去掉详情内的进度更新 UI（+/-按钮等）
    - 右上角编辑按钮改为设置按钮，点击弹出菜单：编辑目标/完成目标/删除目标
    - 页面主体展示历史进度列表：时间、进度变化、备注描述
    - 新建 `goal_progress_records` 表存储进度历史

- [x] **24. 目标列表页重新设计** - 去掉快捷进度按钮，改为进度设置弹窗
  - 完成日期: 2026-03-20
  - 实现:
    - 去掉快捷设置进度按钮（+1/+5等）
    - 将完成按钮替换为进度设置按钮
    - 点击后出现弹窗：设置进度增减值(+/-)、当前进度备注
    - 新建 `progress_update_sheet.dart` 组件

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
- `lib/data/database/tables/goal_progress_records.dart` - 目标进度记录表
- `lib/data/repositories/goal_progress_repository.dart` - 目标进度记录仓库
- `lib/providers/goal_progress_provider.dart` - 目标进度记录 Provider
- `lib/ui/screens/goals/widgets/progress_update_sheet.dart` - 进度更新弹窗

## 修改文件

- `pubspec.yaml` - 添加新依赖
- `lib/core/router/app_router.dart` - 更新路由使用新的合并页面
- `lib/ui/screens/diary/diary_list_screen.dart` - 显示历史日期
- `lib/ui/screens/countdown/widgets/countdown_edit_sheet.dart` - 集成农历日期选择器
- `lib/ui/screens/accounting/accounting_screen.dart` - 修复刷新问题和跳转统计页
- `lib/ui/screens/accounting/widgets/category_chart.dart` - 改进图表交互
- `lib/ui/screens/goals/widgets/goal_card.dart` - 重新设计，改为进度更新按钮
- `lib/ui/screens/goals/goals_list_screen.dart` - 集成进度更新弹窗
- `lib/ui/screens/goals/goal_detail_screen.dart` - 重新设计，展示历史进度，设置菜单
- `lib/ui/screens/weight/weight_screen.dart` - 修复自动刷新
- `lib/ui/screens/todo/todo_screen.dart` - 添加筛选功能
- `lib/ui/components/cards/todo_item.dart` - 修改布局
- `lib/ui/screens/calendar/calendar_screen.dart` - 点击跳转到详情
- `lib/ui/screens/profile/widgets/stats_card.dart` - 添加点击跳转
- `lib/ui/screens/memo/memo_detail_edit_screen.dart` - 修复格式丢失，编辑器全屏
- `lib/ui/screens/diary/diary_detail_edit_screen.dart` - 修复格式丢失，编辑器全屏，去掉天气心情展示
- `lib/data/database/app_database.dart` - 添加目标进度记录表，数据库版本升级到 2
- `lib/data/repositories/goal_repository.dart` - updateProgress 返回更新前的值
- `lib/providers/goal_provider.dart` - 集成进度记录功能
