# Bug 修复清单

## 已修复 (2026-03-20)

- [x] 备忘录页面，点击进入详情页面后，点击一下就进入编辑模式，而不是再进入一个跳转页面，详情也与编辑页面是同一个页面。在详情模式下，上下滑动则是浏览。点击一下则可以编辑。编辑器是一个markdown编辑器。
- [x] 日记页面详情,与备忘录详情一样，点击进入详情页面后，点击一下就进入编辑模式，不用再跳转一个编辑页面。编辑器是一个markdown编辑器。
- [x] 日记详情/编辑页面，顶部左侧展示日期，右侧展示天气和心情，点击天气心情图标则出现弹窗选择。
- [x] 日记页面，历史记录展示需要带上日期。
- [x] 纪念日页面，新建纪念日需要支持农历日历选择
- [x] 记账页面，添加一条信息后，总账单没有刷新，需要左右切换下日期才能刷新。
- [x] 记账页面，图表功能点击没有反应。
- [x] 记账页面需要年度统计，月度统计。
- [x] 目标页面，添加目标后，无法设置进度。
- [x] 目标页面，需要快捷设置进度。
- [x] 目标页面, 点击目标进入详情，可以设置进度，以及每次进度的备注，同时展示历史进度备注情况。
- [x] 目标页面，目标完成后可以克隆目标，快速重启一个目标, 不需要克隆目标历史记录。
- [x] 体重页面，设置体重后需要退出重新进来才能刷新。
- [x] 页面右下角的+号需要可以悬浮移动，会挡住页面内容。
- [x] todo页面，列表页面，右上角的筛选没有功能。
- [x] todo页面，列表内容，删除右边三个点的功能:编辑与删除。将类型和日期放在右边展示。点击todo项可以进入编辑页面。
- [x] 日历页面，点击对应事项直接进入对应的详情或者编辑页面。
- [x] 我的页面，点击备忘，待办，日记进入对应的功能页面。

## 修复说明

### 新增文件
- `lib/ui/screens/memo/memo_detail_edit_screen.dart` - 备忘录详情/编辑合并页面
- `lib/ui/screens/diary/diary_detail_edit_screen.dart` - 日记详情/编辑合并页面
- `lib/ui/screens/countdown/widgets/lunar_date_picker.dart` - 农历日期选择器
- `lib/ui/screens/accounting/accounting_stats_screen.dart` - 年度/月度统计页面
- `lib/ui/screens/todo/widgets/todo_filter_sheet.dart` - Todo 筛选功能
- `lib/ui/components/buttons/draggable_fab.dart` - 可拖拽 FAB 组件

### 新增依赖
- `flutter_quill: ^11.0.0-dev` - WYSIWYG Markdown 编辑器
- `lunar: ^1.3.0` - 农历日历支持
- `shared_preferences: ^2.2.0` - FAB 位置持久化
