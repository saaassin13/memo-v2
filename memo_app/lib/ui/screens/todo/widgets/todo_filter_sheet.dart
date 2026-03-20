import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../components/buttons/app_button.dart';

/// Filter options for todo list.
class TodoFilterOptions {
  final bool showCompleted;
  final bool showOverdue;
  final String? sortBy; // 'dueDate', 'createdAt', 'title'
  final bool sortAscending;

  const TodoFilterOptions({
    this.showCompleted = true,
    this.showOverdue = true,
    this.sortBy = 'dueDate',
    this.sortAscending = true,
  });

  TodoFilterOptions copyWith({
    bool? showCompleted,
    bool? showOverdue,
    String? sortBy,
    bool? sortAscending,
  }) {
    return TodoFilterOptions(
      showCompleted: showCompleted ?? this.showCompleted,
      showOverdue: showOverdue ?? this.showOverdue,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

/// Bug 15: Todo filter bottom sheet
class TodoFilterSheet extends StatefulWidget {
  const TodoFilterSheet({
    super.key,
    required this.currentOptions,
    required this.onApply,
  });

  final TodoFilterOptions currentOptions;
  final ValueChanged<TodoFilterOptions> onApply;

  @override
  State<TodoFilterSheet> createState() => _TodoFilterSheetState();
}

class _TodoFilterSheetState extends State<TodoFilterSheet> {
  late TodoFilterOptions _options;

  @override
  void initState() {
    super.initState();
    _options = widget.currentOptions;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.card : AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: bottomPadding + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColorsDark.border : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Row(
              children: [
                Icon(
                  LucideIcons.filter,
                  size: 20,
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
                const SizedBox(width: 8),
                Text(
                  '筛选与排序',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Show completed toggle
            _buildToggleOption(
              title: '显示已完成',
              subtitle: '在列表中显示已完成的待办',
              value: _options.showCompleted,
              onChanged: (v) => setState(() {
                _options = _options.copyWith(showCompleted: v);
              }),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Show overdue toggle
            _buildToggleOption(
              title: '显示已过期',
              subtitle: '在列表中显示已过期的待办',
              value: _options.showOverdue,
              onChanged: (v) => setState(() {
                _options = _options.copyWith(showOverdue: v);
              }),
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Sort by
            Text(
              '排序方式',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColorsDark.foreground : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildSortChip('dueDate', '截止日期', isDark),
                _buildSortChip('createdAt', '创建时间', isDark),
                _buildSortChip('title', '标题', isDark),
              ],
            ),
            const SizedBox(height: 16),

            // Sort direction
            Row(
              children: [
                Text(
                  '排序顺序',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
                ),
                const Spacer(),
                _buildDirectionChip(true, '升序', LucideIcons.arrowUp, isDark),
                const SizedBox(width: 8),
                _buildDirectionChip(false, '降序', LucideIcons.arrowDown, isDark),
              ],
            ),
            const SizedBox(height: 24),

            // Apply button
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: '重置',
                    variant: ButtonVariant.secondary,
                    onPressed: () {
                      setState(() {
                        _options = const TodoFilterOptions();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: '应用',
                    onPressed: () {
                      widget.onApply(_options);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: isDark ? AppColorsDark.primary : AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSortChip(String value, String label, bool isDark) {
    final isSelected = _options.sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _options = _options.copyWith(sortBy: value);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColorsDark.primary : AppColors.primary)
              : (isDark ? AppColorsDark.muted : AppColors.muted),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? (isDark
                    ? AppColorsDark.primaryForeground
                    : AppColors.primaryForeground)
                : (isDark ? AppColorsDark.foreground : AppColors.foreground),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionChip(
      bool ascending, String label, IconData icon, bool isDark) {
    final isSelected = _options.sortAscending == ascending;
    return GestureDetector(
      onTap: () {
        setState(() {
          _options = _options.copyWith(sortAscending: ascending);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColorsDark.primary : AppColors.primary)
              : (isDark ? AppColorsDark.muted : AppColors.muted),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? (isDark
                      ? AppColorsDark.primaryForeground
                      : AppColors.primaryForeground)
                  : (isDark ? AppColorsDark.foreground : AppColors.foreground),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? (isDark
                        ? AppColorsDark.primaryForeground
                        : AppColors.primaryForeground)
                    : (isDark ? AppColorsDark.foreground : AppColors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
