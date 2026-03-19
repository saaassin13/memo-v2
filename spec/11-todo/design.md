# 11-todo 设计文档

## 页面布局

```
┌─────────────────────────────────────┐
│  Header: Todo            [Filter]   │
├─────────────────────────────────────┤
│  [全部] [工作] [生活] [学习] [杂项] [+] │
├─────────────────────────────────────┤
│                                     │
│  待办 (3)                           │
│  ┌─────────────────────────────────┐│
│  │ ○ 完成项目报告                   ││
│  │   工作 · 明天                    ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ ○ 购买生活用品                   ││
│  │   生活 · 今天                    ││
│  └─────────────────────────────────┘│
│                                     │
│  已完成 (1)                    [▼]  │
│  ┌─────────────────────────────────┐│
│  │ ✓ 复习英语单词                   ││
│  │   学习 · 昨天                    ││
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│           [+ FAB]                   │
├─────────────────────────────────────┤
│           Bottom Navigation          │
└─────────────────────────────────────┘
```

## TodoScreen

```dart
class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  String _activeCategory = '全部';

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todoListProvider(category: _activeCategory));

    return Scaffold(
      body: Column(
        children: [
          // Header
          _buildHeader(context),
          // Category Filter
          CategoryFilter(
            categories: const ['全部', '工作', '生活', '学习', '杂项'],
            activeCategory: _activeCategory,
            onCategoryChanged: (cat) => setState(() => _activeCategory = cat),
          ),
          // Todo List
          Expanded(
            child: todosAsync.when(
              data: (todos) => _buildTodoList(todos),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditSheet(context),
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Todo',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(List<Todo> todos) {
    final pending = todos.where((t) => !t.completed).toList();
    final completed = todos.where((t) => t.completed).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TodoListSection(
          title: '待办',
          todos: pending,
          onToggle: _toggleTodo,
          onEdit: (todo) => _showEditSheet(context, todo: todo),
          onDelete: _deleteTodo,
        ),
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 16),
          TodoListSection(
            title: '已完成',
            todos: completed,
            collapsible: true,
            onToggle: _toggleTodo,
            onEdit: (todo) => _showEditSheet(context, todo: todo),
            onDelete: _deleteTodo,
          ),
        ],
      ],
    );
  }

  void _toggleTodo(String id) {
    ref.read(todoListProvider(category: _activeCategory).notifier).toggle(id);
  }

  void _deleteTodo(String id) {
    ref.read(todoListProvider(category: _activeCategory).notifier).delete(id);
  }

  void _showEditSheet(BuildContext context, {Todo? todo}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TodoEditSheet(
        todo: todo,
        onSave: (data) {
          if (todo != null) {
            // Update
          } else {
            ref.read(todoListProvider(category: _activeCategory).notifier)
                .add(data);
          }
        },
      ),
    );
  }
}
```

## CategoryFilter

```dart
class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String activeCategory;
  final ValueChanged<String> onCategoryChanged;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.activeCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ...categories.map((cat) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CategoryChip(
              label: cat,
              selected: activeCategory == cat,
              onTap: () => onCategoryChanged(cat),
            ),
          )),
          IconButton(
            icon: const Icon(LucideIcons.plus, size: 16),
            onPressed: () {
              // 添加分类
            },
          ),
        ],
      ),
    );
  }
}
```

## TodoEditSheet

```dart
class TodoEditSheet extends StatefulWidget {
  final Todo? todo;
  final ValueChanged<TodoData> onSave;

  const TodoEditSheet({
    super.key,
    this.todo,
    required this.onSave,
  });

  @override
  State<TodoEditSheet> createState() => _TodoEditSheetState();
}

class _TodoEditSheetState extends State<TodoEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  String _category = '杂项';
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title);
    _noteController = TextEditingController(text: widget.todo?.note);
    _category = widget.todo?.category ?? '杂项';
    _dueDate = widget.todo?.dueDate;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.todo != null ? '编辑待办' : '新建待办',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            AppInput(
              controller: _titleController,
              placeholder: '待办事项',
              autofocus: true,
            ),
            const SizedBox(height: 12),
            // Category selector
            // Due date picker
            // Note input
            const SizedBox(height: 16),
            AppButton(
              label: '保存',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final data = TodoData(
      title: _titleController.text,
      category: _category,
      dueDate: _dueDate,
      note: _noteController.text,
    );
    widget.onSave(data);
    Navigator.pop(context);
  }
}
```
