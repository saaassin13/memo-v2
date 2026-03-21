import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../../data/database/app_database.dart';
import '../../../components/cards/todo_item.dart';

/// A section component for displaying a list of todos with title and collapse support.
class TodoListSection extends StatefulWidget {
  /// Creates a TodoListSection.
  const TodoListSection({
    super.key,
    required this.title,
    required this.todos,
    required this.onToggle,
    this.onEdit,
    this.onDelete,
    this.collapsible = false,
    this.initiallyExpanded = true,
    this.onDismissed,
  });

  /// The section title (e.g., "Pending", "Completed").
  final String title;

  /// The list of todos to display.
  final List<Todo> todos;

  /// Called when a todo checkbox is toggled.
  final void Function(String id) onToggle;

  /// Called when edit is selected for a todo.
  final void Function(Todo todo)? onEdit;

  /// Called when delete is selected for a todo.
  final void Function(String id)? onDelete;

  /// Whether this section can be collapsed.
  final bool collapsible;

  /// Whether initially expanded (only applies if collapsible is true).
  final bool initiallyExpanded;

  /// Called when a todo is dismissed by swiping.
  final void Function(String id)? onDismissed;

  @override
  State<TodoListSection> createState() => _TodoListSectionState();
}

class _TodoListSectionState extends State<TodoListSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;
  final Set<String> _dismissedIds = {};

  @override
  void didUpdateWidget(covariant TodoListSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear dismissed IDs when the todo list updates from provider
    final currentIds = widget.todos.map((t) => t.id).toSet();
    _dismissedIds.removeWhere((id) => !currentIds.contains(id));
  }

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _buildHeader(context, isDark),
        // Todo list with animation
        if (widget.collapsible)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _heightFactor.value,
                  child: child,
                ),
              );
            },
            child: _buildTodoList(isDark),
          )
        else
          _buildTodoList(isDark),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (isDark ? AppColorsDark.muted : AppColors.muted)
                      .withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.todos.length}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColorsDark.mutedForeground
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          if (widget.collapsible)
            GestureDetector(
              onTap: _toggleExpanded,
              child: RotationTransition(
                turns: _iconTurns,
                child: Icon(
                  LucideIcons.chevronDown,
                  size: 20,
                  color: isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTodoList(bool isDark) {
    if (widget.todos.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleTodos = widget.todos.where((todo) => !_dismissedIds.contains(todo.id)).toList();

    return Column(
      children: visibleTodos.map((todo) {
        Widget todoItem = Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.card : AppColors.card,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TodoItem(
            id: todo.id,
            title: todo.title,
            category: todo.category,
            dueDate: todo.dueDate,
            completed: todo.completed,
            onToggle: () => widget.onToggle(todo.id),
            onEdit: widget.onEdit != null ? () => widget.onEdit!(todo) : null,
            onDelete:
                widget.onDelete != null ? () => widget.onDelete!(todo.id) : null,
          ),
        );

        // Wrap with Dismissible if onDismissed is provided
        if (widget.onDismissed != null) {
          todoItem = Dismissible(
            key: Key(todo.id),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColorsDark.destructive : AppColors.destructive,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                LucideIcons.trash2,
                color: Colors.white,
                size: 22,
              ),
            ),
            confirmDismiss: (direction) async {
              final confirmed = await _showDeleteConfirmation(context);
              if (confirmed == true) {
                setState(() {
                  _dismissedIds.add(todo.id);
                });
                widget.onDismissed!(todo.id);
                // Return false to prevent Dismissible animation - we remove via state instead
                return false;
              }
              return false;
            },
            child: todoItem,
          );
        }

        return todoItem;
      }).toList(),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              '确认删除',
              style: TextStyle(
                color: isDark ? AppColorsDark.foreground : AppColors.foreground,
              ),
            ),
            content: Text(
              '确定要删除这个待办事项吗？',
              style: TextStyle(
                color: isDark
                    ? AppColorsDark.mutedForeground
                    : AppColors.mutedForeground,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: isDark
                        ? AppColorsDark.mutedForeground
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  '删除',
                  style: TextStyle(
                    color:
                        isDark ? AppColorsDark.destructive : AppColors.destructive,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
