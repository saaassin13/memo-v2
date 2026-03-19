# 11-todo - Todo 模块

## 模块说明

待办事项管理，包含分类筛选、添加/编辑/删除、完成状态切换。

## 依赖模块

- 00-foundation
- 01-ui-components (TodoItem, AppDialog)
- 02-data-layer (todoProvider)
- 03-navigation

## Web 对应

- `app/todo/page.tsx`
- `components/todo-list.tsx`
- `components/todo-dialog.tsx`

## 页面

| 页面 | 路由 | 说明 |
|------|------|------|
| TodoScreen | `/todo` | Todo 主页面 |

## 功能

- 分类筛选: 全部/工作/生活/学习/杂项
- 待办列表: 按截止日期排序
- 已完成列表: 可折叠
- 新建/编辑: 底部对话框
- 删除: 滑动删除或菜单删除
- 完成切换: 点击复选框

## 核心文件

```
lib/ui/screens/todo/
├── todo_screen.dart
└── widgets/
    ├── todo_list_section.dart
    ├── category_filter.dart
    └── todo_edit_sheet.dart
```

## 状态

- [x] 设计完成
- [x] 开发完成
- [ ] 测试完成
- [ ] 发布就绪

## 相关文档

- [设计文档](./design.md)
- [任务明细](./tasks.md)
- [变更记录](./changelog.md)
