import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/colors.dart';
import '../../../core/services/notification_service.dart';
import '../../../providers/notification_settings_provider.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/todo_provider.dart';
import '../../components/buttons/app_button.dart';
import '../../components/feedback/empty_state.dart';
import 'widgets/category_filter.dart';
import 'widgets/todo_edit_sheet.dart';
import 'widgets/todo_filter_sheet.dart';
import 'widgets/todo_list_section.dart';

/// The main Todo screen displaying todo list with category filter.
class TodoScreen extends ConsumerStatefulWidget {
  /// Creates a TodoScreen.
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  String _activeCategory = '全部';
  // Bug 15: Filter options
  TodoFilterOptions _filterOptions = const TodoFilterOptions();

  static const List<String> _categories = ['全部', '工作', '生活', '学习', '杂项'];

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todoListProvider(
      category: _activeCategory == '全部' ? null : _activeCategory,
    ));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Category Filter
            CategoryFilter(
              categories: _categories,
              activeCategory: _activeCategory,
              onCategoryChanged: (cat) => setState(() => _activeCategory = cat),
            ),
            // Todo List
            Expanded(
              child: todosAsync.when(
                data: (todos) => _buildTodoContent(todos),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => CommonEmptyStates.error(
                  message: '加载失败: $e',
                  action: AppButton(
                    label: '重试',
                    variant: ButtonVariant.secondary,
                    onPressed: () => ref.invalidate(todoListProvider(
                      category: _activeCategory == '全部' ? null : _activeCategory,
                    )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditSheet(context),
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? AppColorsDark.primary
                : AppColors.primary,
        foregroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? AppColorsDark.primaryForeground
                : AppColors.primaryForeground,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.background : AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColorsDark.border : AppColors.border,
            width: 0.5,
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
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
          ),
          IconButton(
            icon: Icon(
              LucideIcons.filter,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
            // Bug 15: Implement filter functionality
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoContent(List<Todo> todos) {
    // Bug 15: Apply filter options
    var filteredTodos = todos.toList();

    // Filter by completed status
    if (!_filterOptions.showCompleted) {
      filteredTodos = filteredTodos.where((t) => !t.completed).toList();
    }

    // Filter by overdue status
    if (!_filterOptions.showOverdue) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      filteredTodos = filteredTodos.where((t) {
        if (t.completed || t.dueDate == null) return true;
        final dueDay = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
        return !dueDay.isBefore(today);
      }).toList();
    }

    // Sort based on filter options
    filteredTodos.sort((a, b) {
      int result = 0;
      switch (_filterOptions.sortBy) {
        case 'dueDate':
          if (a.dueDate == null && b.dueDate == null) {
            result = 0;
          } else if (a.dueDate == null) {
            result = 1;
          } else if (b.dueDate == null) {
            result = -1;
          } else {
            result = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case 'createdAt':
          result = a.createdAt.compareTo(b.createdAt);
          break;
        case 'title':
          result = a.title.compareTo(b.title);
          break;
        default:
          result = 0;
      }
      return _filterOptions.sortAscending ? result : -result;
    });

    // Split into pending and completed
    final pending = filteredTodos.where((t) => !t.completed).toList();
    final completed = filteredTodos.where((t) => t.completed).toList();

    // Check if empty
    if (filteredTodos.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Pending section
        TodoListSection(
          title: '待办',
          todos: pending,
          onToggle: _toggleTodo,
          onEdit: (todo) => _showEditSheet(context, todo: todo),
          onDelete: _deleteTodo,
          onDismissed: _deleteTodo,
        ),
        // Completed section
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 20),
          TodoListSection(
            title: '已完成',
            todos: completed,
            collapsible: true,
            initiallyExpanded: false,
            onToggle: _toggleTodo,
            onEdit: (todo) => _showEditSheet(context, todo: todo),
            onDelete: _deleteTodo,
            onDismissed: _deleteTodo,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return CommonEmptyStates.noTodos(
      action: AppButton(
        label: '添加待办',
        icon: LucideIcons.plus,
        onPressed: () => _showEditSheet(context),
      ),
    );
  }

  void _toggleTodo(String id) {
    ref
        .read(todoListProvider(
          category: _activeCategory == '全部' ? null : _activeCategory,
        ).notifier)
        .toggle(id);
  }

  void _deleteTodo(String id) {
    ref
        .read(todoListProvider(
          category: _activeCategory == '全部' ? null : _activeCategory,
        ).notifier)
        .delete(id);
  }

  void _showEditSheet(BuildContext context, {Todo? todo}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TodoEditSheet(
        todo: todo,
        onSave: (data) {
          if (todo != null) {
            // Update existing todo
            final updatedTodo = Todo(
              id: todo.id,
              title: data.title,
              category: data.category,
              dueDate: data.dueDate,
              note: data.note,
              completed: todo.completed,
              remind: data.remind,
              createdAt: todo.createdAt,
              updatedAt: DateTime.now(),
            );
            ref
                .read(todoListProvider(
                  category: _activeCategory == '全部' ? null : _activeCategory,
                ).notifier)
                .updateTodo(updatedTodo);
          } else {
            // Create new todo
            ref
                .read(todoListProvider(
                  category: _activeCategory == '全部' ? null : _activeCategory,
                ).notifier)
                .add(
                  title: data.title,
                  category: data.category,
                  dueDate: data.dueDate,
                  note: data.note,
                  remind: data.remind,
                );
          }
          // Schedule reminder notification
          final notifySettings = ref.read(notificationSettingsProvider);
          if (data.remind && data.dueDate != null && notifySettings.todoReminder) {
            NotificationService.instance.scheduleTodoReminder(
              todoId: todo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              title: data.title,
              dueDate: data.dueDate!,
            );
          }
        },
      ),
    );
  }

  // Bug 15: Show filter bottom sheet
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TodoFilterSheet(
        currentOptions: _filterOptions,
        onApply: (options) {
          setState(() {
            _filterOptions = options;
          });
        },
      ),
    );
  }
}
