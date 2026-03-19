# 01-ui-components - UI 组件库

## 模块说明

可复用的 UI 组件库，对标原 Web 版的 shadcn/ui 组件。

## 依赖模块

- 00-foundation (主题系统)

## 被依赖模块

- 10-home, 11-todo, 12-calendar, 13-profile
- 20-memo, 21-diary, 22-countdown, 23-accounting, 24-goals, 25-weight

## 组件清单

### 基础组件
| 组件 | 说明 | Web 对应 | 状态 |
|------|------|---------|------|
| AppButton | 按钮 | button.tsx | 已完成 |
| AppCard | 卡片 | card.tsx | 已完成 |
| AppBadge | 徽章 | badge.tsx | 已完成 |
| AppInput | 输入框 | input.tsx | 已完成 |
| AppTextArea | 多行输入 | textarea.tsx | 已完成 |

### 交互组件
| 组件 | 说明 | Web 对应 | 状态 |
|------|------|---------|------|
| AppDialog | 对话框 | dialog.tsx | 已完成 |
| AppDrawer | 底部抽屉 | drawer.tsx | 已完成 |
| AppDropdownMenu | 下拉菜单 | dropdown-menu.tsx | 已完成 |

### 业务组件
| 组件 | 说明 | Web 对应 | 状态 |
|------|------|---------|------|
| TodoItem | Todo 列表项 | todo-list.tsx | 已完成 |
| EventCard | 事件卡片 | event-card.tsx | 已完成 |
| MemoCard | 备忘录卡片 | memo/page.tsx | 已完成 |
| CategoryChip | 分类标签 | - | 已完成 |
| EmptyState | 空状态 | empty.tsx | 已完成 |
| SearchInput | 搜索输入 | - | 已完成 |
| Loading | 加载指示器 | - | 已完成 |

## 核心文件

```
lib/ui/components/
├── components.dart          # 统一导出文件
├── buttons/
│   └── app_button.dart
├── cards/
│   ├── app_card.dart
│   ├── todo_item.dart
│   ├── event_card.dart
│   └── memo_card.dart
├── inputs/
│   ├── app_input.dart
│   ├── app_textarea.dart
│   └── search_input.dart
├── dialogs/
│   ├── app_dialog.dart
│   ├── app_drawer.dart
│   └── app_dropdown_menu.dart
├── badges/
│   ├── app_badge.dart
│   └── category_chip.dart
└── feedback/
    ├── empty_state.dart
    └── loading.dart
```

## 使用方式

```dart
// 导入所有组件
import 'package:memo_app/ui/components/components.dart';

// 或单独导入
import 'package:memo_app/ui/components/buttons/app_button.dart';
```

## 状态

- [x] 设计完成
- [x] 开发完成
- [ ] 测试完成
- [ ] 发布就绪

## 相关文档

- [设计文档](./design.md)
- [任务明细](./tasks.md)
- [组件说明](./components.md)
- [变更记录](./changelog.md)
