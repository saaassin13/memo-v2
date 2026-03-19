# UI 组件说明

## 组件使用指南

### AppButton

**基础用法**:
```dart
AppButton(
  label: '提交',
  onPressed: () => print('clicked'),
)
```

**带图标**:
```dart
AppButton(
  label: '新增',
  icon: LucideIcons.plus,
  onPressed: () {},
)
```

**仅图标**:
```dart
AppButton.icon(
  icon: LucideIcons.settings,
  onPressed: () {},
)
```

**变体**:
```dart
// 主要按钮
AppButton(label: '确定', variant: ButtonVariant.primary)

// 次要按钮
AppButton(label: '取消', variant: ButtonVariant.secondary)

// 幽灵按钮
AppButton(label: '更多', variant: ButtonVariant.ghost)

// 危险按钮
AppButton(label: '删除', variant: ButtonVariant.destructive)
```

---

### AppCard

**基础用法**:
```dart
AppCard(
  child: Text('内容'),
)
```

**可点击**:
```dart
AppCard(
  onTap: () => print('tapped'),
  child: Text('点击我'),
)
```

---

### AppBadge

**基础用法**:
```dart
AppBadge(label: '工作')
```

**带颜色**:
```dart
AppBadge(
  label: '工作',
  color: AppColors.chart1,
  backgroundColor: AppColors.chart1.withOpacity(0.1),
)
```

---

### AppInput

**基础用法**:
```dart
AppInput(
  label: '标题',
  placeholder: '请输入标题',
  controller: _controller,
)
```

**带验证**:
```dart
AppInput(
  label: '邮箱',
  validator: (value) {
    if (value?.isEmpty ?? true) return '请输入邮箱';
    return null;
  },
)
```

---

### AppDialog

**显示对话框**:
```dart
await AppDialog.show(
  context: context,
  title: '确认删除',
  description: '删除后无法恢复',
  content: Text('确定要删除这条记录吗？'),
  actions: [
    AppButton(
      label: '取消',
      variant: ButtonVariant.secondary,
      onPressed: () => Navigator.pop(context),
    ),
    AppButton(
      label: '删除',
      variant: ButtonVariant.destructive,
      onPressed: () => Navigator.pop(context, true),
    ),
  ],
);
```

---

### AppDrawer

**显示底部抽屉**:
```dart
await AppDrawer.show(
  context: context,
  title: '显示设置',
  description: '选择展示样式',
  child: Column(
    children: [
      ListTile(title: Text('列表视图')),
      ListTile(title: Text('网格视图')),
    ],
  ),
);
```

---

### TodoItem

**使用示例**:
```dart
TodoItem(
  id: '1',
  title: '完成项目报告',
  category: '工作',
  dueDate: DateTime.now().add(Duration(days: 1)),
  completed: false,
  onToggle: () => toggleTodo('1'),
  onTap: () => openDetail('1'),
  onEdit: () => editTodo('1'),
  onDelete: () => deleteTodo('1'),
)
```

---

### EventCard

**使用示例**:
```dart
EventCard(
  title: '团队会议',
  description: '讨论下周计划',
  time: '14:00',
  type: 'todo',
  accentColor: AppColors.chart1,
  onTap: () => openEvent(event),
)
```

---

### MemoCard

**列表模式**:
```dart
MemoCard(
  id: '1',
  title: '会议记录',
  content: '讨论了新功能...',
  category: '工作',
  updatedAt: DateTime.now(),
  pinned: true,
  gridMode: false,
  onTap: () => openMemo('1'),
)
```

**网格模式**:
```dart
MemoCard(
  ...
  gridMode: true,
)
```

---

### CategoryChip

**分类选择器**:
```dart
Row(
  children: categories.map((cat) =>
    CategoryChip(
      label: cat,
      selected: activeCategory == cat,
      onTap: () => setCategory(cat),
    ),
  ).toList(),
)
```

---

### EmptyState

**空状态展示**:
```dart
EmptyState(
  message: '暂无待办事项',
  icon: LucideIcons.checkSquare,
  action: AppButton(
    label: '新建待办',
    icon: LucideIcons.plus,
    onPressed: () => createTodo(),
  ),
)
```
