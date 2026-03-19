import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../badges/app_badge.dart';
import '../dialogs/app_dropdown_menu.dart';

/// A todo list item component with checkbox, title, category, due date, and actions.
class TodoItem extends StatelessWidget {
  /// Creates a TodoItem.
  const TodoItem({
    super.key,
    required this.id,
    required this.title,
    required this.category,
    this.dueDate,
    required this.completed,
    required this.onToggle,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  /// The unique identifier of the todo.
  final String id;

  /// The todo title.
  final String title;

  /// The category/tag of the todo.
  final String category;

  /// The due date of the todo.
  final DateTime? dueDate;

  /// Whether the todo is completed.
  final bool completed;

  /// Called when the checkbox is toggled.
  final VoidCallback onToggle;

  /// Called when the item is tapped.
  final VoidCallback? onTap;

  /// Called when edit is selected from menu.
  final VoidCallback? onEdit;

  /// Called when delete is selected from menu.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _getCategoryColor(category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: completed
                        ? (isDark ? AppColorsDark.accent : AppColors.accent)
                        : (isDark ? AppColorsDark.border : AppColors.border),
                    width: 2,
                  ),
                  color: completed
                      ? (isDark ? AppColorsDark.accent : AppColors.accent)
                      : Colors.transparent,
                ),
                child: completed
                    ? Icon(
                        LucideIcons.check,
                        size: 14,
                        color: isDark ? AppColorsDark.accentForeground : AppColors.accentForeground,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: completed
                          ? (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground)
                          : (isDark ? AppColorsDark.foreground : AppColors.foreground),
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Category and date
                  Row(
                    children: [
                      AppBadge(
                        label: category,
                        color: categoryColor,
                        backgroundColor: categoryColor.withOpacity(0.15),
                      ),
                      if (dueDate != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          LucideIcons.calendar,
                          size: 14,
                          color: _isOverdue(dueDate!)
                              ? (isDark ? AppColorsDark.destructive : AppColors.destructive)
                              : (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(dueDate!),
                          style: TextStyle(
                            fontSize: 12,
                            color: _isOverdue(dueDate!)
                                ? (isDark ? AppColorsDark.destructive : AppColors.destructive)
                                : (isDark
                                    ? AppColorsDark.mutedForeground
                                    : AppColors.mutedForeground),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // More button
            if (onEdit != null || onDelete != null)
              Builder(
                builder: (context) => GestureDetector(
                  onTapDown: (details) {
                    _showMenu(context, details.globalPosition);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      LucideIcons.moreVertical,
                      size: 20,
                      color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context, Offset position) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    AppDropdownMenu.show(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(position, position),
        Offset.zero & overlay.size,
      ),
      items: [
        if (onEdit != null)
          AppMenuItem(
            label: '编辑',
            icon: LucideIcons.pencil,
            onTap: onEdit,
          ),
        if (onEdit != null && onDelete != null) AppMenuItem.divider,
        if (onDelete != null)
          AppMenuItem(
            label: '删除',
            icon: LucideIcons.trash2,
            onTap: onDelete,
            isDestructive: true,
          ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '工作':
        return AppColors.chart1;
      case '生活':
        return AppColors.accent;
      case '学习':
        return AppColors.chart3;
      default:
        return AppColors.mutedForeground;
    }
  }

  bool _isOverdue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(date.year, date.month, date.day);
    return dueDay.isBefore(today) && !completed;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDay = DateTime(date.year, date.month, date.day);

    if (dueDay == today) {
      return '今天';
    } else if (dueDay == tomorrow) {
      return '明天';
    } else if (dueDay.year == now.year) {
      return '${date.month}月${date.day}日';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }
}
