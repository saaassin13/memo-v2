# 20-memo 设计文档

## MemoListScreen 布局

```
┌─────────────────────────────────────┐
│  [<] 备忘录          [搜索] [设置]  │
├─────────────────────────────────────┤
│  [全部] [工作] [生活] [学习]        │
├─────────────────────────────────────┤
│                                     │
│  📌 置顶                            │
│  ┌─────────────────────────────────┐│
│  │ 项目会议记录            [更多] ││
│  │ 讨论了新功能的开发计划...       ││
│  │ 工作 · 2026-03-18              ││
│  └─────────────────────────────────┘│
│                                     │
│  其他                               │
│  ┌─────────────────────────────────┐│
│  │ 购物清单                [更多] ││
│  │ 牛奶 面包 鸡蛋...               ││
│  │ 生活 · 2026-03-17              ││
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│           [+ FAB]                   │
└─────────────────────────────────────┘
```

## MemoListScreen

```dart
class MemoListScreen extends ConsumerStatefulWidget {
  const MemoListScreen({super.key});

  @override
  ConsumerState<MemoListScreen> createState() => _MemoListScreenState();
}

class _MemoListScreenState extends ConsumerState<MemoListScreen> {
  String _activeCategory = '全部';
  String _viewMode = 'list'; // list, grid
  String _sortMode = 'updatedAt'; // createdAt, updatedAt

  @override
  Widget build(BuildContext context) {
    final memosAsync = ref.watch(memoListProvider(
      category: _activeCategory,
      sortBy: _sortMode,
    ));

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          CategoryFilter(
            categories: const ['全部', '工作', '生活', '学习'],
            activeCategory: _activeCategory,
            onCategoryChanged: (cat) => setState(() => _activeCategory = cat),
          ),
          Expanded(
            child: memosAsync.when(
              data: (memos) => _buildMemoList(memos),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/apps/memo/new'),
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft),
        onPressed: () => context.go('/'),
      ),
      title: const Text('备忘录'),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.search),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(LucideIcons.settings2),
          onPressed: () => _showDisplaySettings(context),
        ),
      ],
    );
  }

  Widget _buildMemoList(List<Memo> memos) {
    final pinned = memos.where((m) => m.pinned).toList();
    final others = memos.where((m) => !m.pinned).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (pinned.isNotEmpty) ...[
          _buildSection('置顶', pinned, icon: LucideIcons.pin),
          const SizedBox(height: 16),
        ],
        if (others.isNotEmpty) ...[
          if (pinned.isNotEmpty)
            _buildSectionTitle('其他'),
          _buildMemoGrid(others),
        ],
      ],
    );
  }

  Widget _buildMemoGrid(List<Memo> memos) {
    if (_viewMode == 'grid') {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: memos.map((memo) => MemoCard(
          memo: memo,
          gridMode: true,
          onTap: () => context.push('/apps/memo/${memo.id}'),
          onTogglePin: () => _togglePin(memo.id),
          onDelete: () => _deleteMemo(memo.id),
        )).toList(),
      );
    }

    return Column(
      children: memos.map((memo) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: MemoCard(
          memo: memo,
          gridMode: false,
          onTap: () => context.push('/apps/memo/${memo.id}'),
          onTogglePin: () => _togglePin(memo.id),
          onDelete: () => _deleteMemo(memo.id),
        ),
      )).toList(),
    );
  }

  void _showDisplaySettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DisplaySettingsSheet(
        viewMode: _viewMode,
        sortMode: _sortMode,
        onViewModeChanged: (mode) => setState(() => _viewMode = mode),
        onSortModeChanged: (mode) => setState(() => _sortMode = mode),
      ),
    );
  }
}
```

## MemoEditScreen

```dart
class MemoEditScreen extends ConsumerStatefulWidget {
  final String? id;

  const MemoEditScreen({super.key, this.id});

  @override
  ConsumerState<MemoEditScreen> createState() => _MemoEditScreenState();
}

class _MemoEditScreenState extends ConsumerState<MemoEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _category = '生活';

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _loadMemo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.id != null ? '编辑备忘录' : '新建备忘录'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppInput(
              controller: _titleController,
              placeholder: '标题',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Category selector
            Row(
              children: ['工作', '生活', '学习'].map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CategoryChip(
                  label: cat,
                  selected: _category == cat,
                  onTap: () => setState(() => _category = cat),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AppTextArea(
                controller: _contentController,
                placeholder: '内容...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() async {
    final memo = Memo(
      id: widget.id ?? const Uuid().v4(),
      title: _titleController.text,
      content: _contentController.text,
      category: _category,
      pinned: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.id != null) {
      await ref.read(memoListProvider().notifier).update(memo);
    } else {
      await ref.read(memoListProvider().notifier).add(memo);
    }

    if (mounted) context.pop();
  }
}
```

## DisplaySettingsSheet

```dart
class DisplaySettingsSheet extends StatelessWidget {
  final String viewMode;
  final String sortMode;
  final ValueChanged<String> onViewModeChanged;
  final ValueChanged<String> onSortModeChanged;

  const DisplaySettingsSheet({
    super.key,
    required this.viewMode,
    required this.sortMode,
    required this.onViewModeChanged,
    required this.onSortModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('显示设置', style: Theme.of(context).textTheme.titleLarge),
          Text('选择备忘录的展示样式和排序方式',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),

          // View Mode
          Text('展示样式', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildOption(
                context,
                icon: LucideIcons.list,
                label: '列表',
                selected: viewMode == 'list',
                onTap: () => onViewModeChanged('list'),
              ),
              const SizedBox(width: 12),
              _buildOption(
                context,
                icon: LucideIcons.grid3X3,
                label: '九宫格',
                selected: viewMode == 'grid',
                onTap: () => onViewModeChanged('grid'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sort Mode
          Text('排序方式', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildOption(
                context,
                icon: LucideIcons.calendarDays,
                label: '创建时间',
                selected: sortMode == 'createdAt',
                onTap: () => onSortModeChanged('createdAt'),
              ),
              const SizedBox(width: 12),
              _buildOption(
                context,
                icon: LucideIcons.clock,
                label: '修改时间',
                selected: sortMode == 'updatedAt',
                onTap: () => onSortModeChanged('updatedAt'),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
```
