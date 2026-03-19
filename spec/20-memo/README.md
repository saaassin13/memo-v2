# 20-memo - 备忘录模块

## 模块说明

备忘录管理，包含列表、新建、详情/编辑三个页面。

## 依赖模块

- 00-foundation
- 01-ui-components (MemoCard, AppDrawer)
- 02-data-layer (memoProvider)
- 03-navigation

## Web 对应

- `app/apps/memo/page.tsx`
- `app/apps/memo/new/page.tsx`
- `app/apps/memo/[id]/page.tsx`

## 页面

| 页面 | 路由 | 说明 |
|------|------|------|
| MemoListScreen | `/apps/memo` | 备忘录列表 |
| MemoEditScreen | `/apps/memo/new` | 新建备忘录 |
| MemoDetailScreen | `/apps/memo/:id` | 备忘录详情 |
| MemoEditScreen | `/apps/memo/:id/edit` | 编辑备忘录 |

## 功能

- 分类筛选: 全部/工作/生活/学习
- 显示设置: 列表/网格视图, 创建/修改时间排序
- 置顶功能
- 搜索
- 新建/编辑/删除

## 核心文件

```
lib/ui/screens/memo/
├── memo_list_screen.dart
├── memo_edit_screen.dart
├── memo_detail_screen.dart
└── widgets/
    └── display_settings_sheet.dart
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
