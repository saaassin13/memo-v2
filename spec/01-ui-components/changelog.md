# 01-ui-components 变更记录

## [1.0.0] - 2026-03-19

### Added
- **基础组件**
  - AppButton: 按钮组件，支持 primary/secondary/ghost/destructive 变体，sm/md/lg 尺寸，loading 状态，图标支持
  - AppCard: 卡片组件，支持点击效果、阴影层级、自定义圆角
  - AppBadge: 徽章组件，支持 default/secondary/outline 变体，自定义颜色
  - AppInput: 输入框组件，支持 label/placeholder、前缀/后缀图标、验证状态、错误提示
  - AppTextArea: 多行输入组件，支持自动高度调整

- **交互组件**
  - AppDialog: 对话框组件，支持标题、描述、自定义内容、操作按钮
  - AppConfirmDialog: 确认对话框，便捷的确认/取消交互
  - AppDrawer: 底部抽屉组件，支持标题栏、拖拽关闭
  - AppDrawerItem: 抽屉列表项组件
  - AppDropdownMenu: 下拉菜单组件，支持菜单项、分隔线、危险操作标识

- **业务组件**
  - TodoItem: Todo 列表项，支持复选框、标题/分类/日期、更多操作菜单、完成状态样式
  - EventCard: 事件卡片，支持事件信息展示、时间显示、类型标识
  - MemoCard: 备忘录卡片，支持列表/网格两种布局、置顶标识、操作菜单
  - CategoryChip: 分类标签，支持选中状态
  - CategoryChipList: 分类标签列表，横向滚动

- **反馈组件**
  - EmptyState: 空状态组件，支持图标、文案、操作按钮
  - CommonEmptyStates: 预定义的常用空状态
  - Loading: 加载指示器，支持全屏/内联模式
  - LoadingOverlay: 全屏加载遮罩
  - LoadingContainer: 加载状态容器
  - ShimmerLoading: 骨架屏加载动画
  - SearchInput: 搜索输入框，支持清除按钮

- **统一导出**
  - components.dart: 组件库统一导出文件

### Changed
- N/A

### Fixed
- N/A

### Impact
- 为所有页面提供统一的 UI 组件支持
- 影响模块: 10-home, 11-todo, 12-calendar, 13-profile, 20-memo, 21-diary, 22-countdown, 23-accounting, 24-goals, 25-weight

---

## 变更模板

### [版本号] - YYYY-MM-DD

#### Added
- 新增组件

#### Changed
- API 变更

#### Fixed
- Bug 修复

#### Impact
- 影响的页面/模块
