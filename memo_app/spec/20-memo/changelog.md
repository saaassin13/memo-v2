# Memo Changelog

## 2026-03-20 (Hotfix)

### Bug Fixes

- **[25] 置顶按钮和点击区域问题**
  - 问题：置顶按钮点击后图标未更新，编辑器区域点击无法进入编辑模式
  - 修复：
    - 将 `_togglePin()` 改为 async 并等待完成，确保状态正确刷新
    - 用 `IgnorePointer` 包裹 QuillEditor，使点击事件传递到外层 GestureDetector
  - 修改文件：`lib/ui/screens/memo/memo_detail_edit_screen.dart`

- **[26] 列表显示乱码**
  - 问题：列表页显示 Delta JSON 格式而非纯文本
  - 修复：
    - 新建 `lib/core/utils/delta_utils.dart` 提供 `extractPlainText()` 方法
    - 修改 MemoCard 使用该方法提取纯文本显示
  - 修改文件：`lib/ui/components/cards/memo_card.dart`
  - 新建文件：`lib/core/utils/delta_utils.dart`

## 2026-03-20

### Bug Fixes

- **[19] 编辑页面格式丢失** - 修复 flutter_quill 编辑内容保存后再次进入格式丢失的问题
  - 原因：flutter_quill 使用 Delta JSON 格式，原来保存为纯文本导致格式丢失
  - 修复：保存时将 QuillController 的 document 转为 Delta JSON 存储，加载时从 JSON 恢复
  - 修改文件：`lib/ui/screens/memo/memo_detail_edit_screen.dart`

- **[20] 编辑框太小** - 正文编辑框改为全屏
  - 原因：原来编辑器有固定最小高度限制
  - 修复：使用 Expanded 让 QuillEditor 占满剩余空间
  - 修改文件：`lib/ui/screens/memo/memo_detail_edit_screen.dart`

### Technical Changes

- 添加 `dart:convert` 导入用于 JSON 序列化/反序列化
- 新增 `_deltaJsonContent` getter 获取 Delta JSON 格式内容
- 新增 `_buildContentDisplay` 方法用于渲染富文本内容
- 重构 `_buildEditMode` 方法，将编辑器改为全屏布局
