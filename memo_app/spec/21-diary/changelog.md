# Diary Changelog

## 2026-03-20 (Hotfix)

### Bug Fixes

- **[27] 列表显示乱码**
  - 问题：日记卡片显示 Delta JSON 格式而非纯文本
  - 修复：修改 DiaryCard 使用 `DeltaUtils.extractPlainText()` 提取纯文本显示
  - 修改文件：`lib/ui/screens/diary/widgets/diary_card.dart`

- **[28] 去掉心情文字标签**
  - 问题：日记列表中心情图标旁边有文字标签
  - 修复：移除 `mood.label` 文字，只保留 emoji 图标
  - 修改文件：`lib/ui/screens/diary/widgets/diary_card.dart`

- **[29] 选择日期进入编辑页面**
  - 问题：点击日历某天时，未正确跳转到对应日记
  - 修复：
    - 新增 `_handleDateSelected()` 方法
    - 有日记则跳转到详情编辑页面，无日记则跳转到新建页面并设置选中日期
  - 修改文件：`lib/ui/screens/diary/diary_list_screen.dart`

## 2026-03-20

### Bug Fixes

- **[21] 编辑页面格式丢失 + 编辑框太小** - 同备忘录问题修复
  - 修复：保存时将 QuillController 的 document 转为 Delta JSON 存储，加载时从 JSON 恢复
  - 修复：使用 Expanded 让 QuillEditor 占满剩余空间
  - 修改文件：`lib/ui/screens/diary/diary_detail_edit_screen.dart`

- **[22] 去掉天气心情固定展示** - 编辑模式下去掉天气心情的固定展示区域
  - 原因：顶部已有天气心情图标，点击可弹出选择，不需要重复展示
  - 修复：去掉 WeatherSelector 和 MoodSelector 的固定展示，只在顶部显示图标
  - 修改文件：`lib/ui/screens/diary/diary_detail_edit_screen.dart`

### Technical Changes

- 添加 `dart:convert` 导入用于 JSON 序列化/反序列化
- 新增 `_deltaJsonContent` getter 获取 Delta JSON 格式内容
- 新增 `_buildContentDisplay` 方法用于渲染富文本内容
- 重构 `_buildEditMode` 方法：
  - 去掉天气心情固定展示区域
  - 编辑器改为全屏布局
  - 标题输入框简化
