import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../../data/database/app_database.dart';

/// Goal type category for display styling.
enum GoalCategory {
  daily('daily', '每日', LucideIcons.sun, Color(0xFFF59E0B)),
  weekly('weekly', '每周', LucideIcons.calendar, Color(0xFF3B82F6)),
  monthly('monthly', '每月', LucideIcons.calendarDays, Color(0xFF8B5CF6)),
  yearly('yearly', '每年', LucideIcons.calendarRange, Color(0xFFEC4899)),
  custom('custom', '自定义', LucideIcons.target, Color(0xFF4B7BEC));

  const GoalCategory(this.value, this.label, this.icon, this.color);

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  static GoalCategory fromString(String? value) {
    return GoalCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GoalCategory.custom,
    );
  }
}

/// A card widget for displaying goal item with progress bar.
class GoalCard extends StatelessWidget {
  /// Creates a GoalCard.
  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onQuickProgress,
  });

  /// The goal data to display.
  final Goal goal;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Called when the card is long pressed.
  final VoidCallback? onLongPress;

  /// Called when delete action is triggered.
  final VoidCallback? onDelete;

  /// Called when quick progress button is pressed (Bug 10).
  final void Function(int newValue)? onQuickProgress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = GoalCategory.fromString(goal.type);
    final progress = goal.targetValue > 0
        ? (goal.currentValue / goal.targetValue).clamp(0.0, 1.0)
        : 0.0;
    final percentage = (progress * 100).round();
    final isCompleted = goal.completed;

    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.destructive : AppColors.destructive,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          LucideIcons.trash2,
          color: Colors.white,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.card : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? (isDark ? AppColorsDark.accent : AppColors.accent)
                      .withOpacity(0.5)
                  : (isDark ? AppColorsDark.border : AppColors.border),
              width: isCompleted ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: icon, title, status
              Row(
                children: [
                  _buildCategoryIcon(category, isDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColorsDark.foreground
                                : AppColors.foreground,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (goal.description != null &&
                            goal.description!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            goal.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColorsDark.mutedForeground
                                  : AppColors.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildProgressBadge(percentage, isCompleted, isDark),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              _buildProgressBar(progress, category, isDark),
              const SizedBox(height: 8),
              // Progress text and deadline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProgressText(isDark),
                  if (goal.endDate != null) _buildDeadline(isDark),
                ],
              ),
              // Bug 10: Quick progress buttons
              if (!isCompleted && onQuickProgress != null) ...[
                const SizedBox(height: 12),
                _buildQuickProgressButtons(isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(GoalCategory category, bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: category.color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        category.icon,
        size: 20,
        color: category.color,
      ),
    );
  }

  Widget _buildProgressBadge(int percentage, bool isCompleted, bool isDark) {
    final Color bgColor;
    final Color textColor;

    if (isCompleted) {
      bgColor = (isDark ? AppColorsDark.accent : AppColors.accent)
          .withOpacity(isDark ? 0.2 : 0.1);
      textColor = isDark ? AppColorsDark.accent : AppColors.accent;
    } else if (percentage >= 80) {
      bgColor = const Color(0xFFF59E0B).withOpacity(isDark ? 0.2 : 0.1);
      textColor = const Color(0xFFF59E0B);
    } else {
      bgColor = (isDark ? AppColorsDark.muted : AppColors.muted);
      textColor =
          isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCompleted) ...[
            Icon(
              LucideIcons.check,
              size: 14,
              color: textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress, GoalCategory category, bool isDark) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: (isDark ? AppColorsDark.muted : AppColors.muted),
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: constraints.maxWidth * progress,
                decoration: BoxDecoration(
                  color: goal.completed
                      ? (isDark ? AppColorsDark.accent : AppColors.accent)
                      : category.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressText(bool isDark) {
    final unit = goal.unit ?? '';
    final currentText = goal.currentValue.toString();
    final targetText = goal.targetValue.toString();

    return Text(
      '$currentText / $targetText $unit',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
      ),
    );
  }

  Widget _buildDeadline(bool isDark) {
    final endDate = goal.endDate!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final daysRemaining = end.difference(today).inDays;

    final Color textColor;
    final String text;

    if (goal.completed) {
      textColor =
          isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground;
      text = '已完成';
    } else if (daysRemaining < 0) {
      textColor = isDark ? AppColorsDark.destructive : AppColors.destructive;
      text = '已过期 ${-daysRemaining} 天';
    } else if (daysRemaining == 0) {
      textColor = isDark ? AppColorsDark.destructive : AppColors.destructive;
      text = '今天截止';
    } else if (daysRemaining <= 7) {
      textColor = const Color(0xFFF59E0B);
      text = '还剩 $daysRemaining 天';
    } else {
      textColor =
          isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground;
      text = '${endDate.month}/${endDate.day} 截止';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          LucideIcons.clock,
          size: 14,
          color: textColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
          ),
        ),
      ],
    );
  }

  /// Bug 10: Build quick progress buttons for the list view
  Widget _buildQuickProgressButtons(bool isDark) {
    return Row(
      children: [
        _buildQuickButton(
          icon: LucideIcons.minus,
          onTap: goal.currentValue > 0
              ? () => onQuickProgress?.call(goal.currentValue - 1)
              : null,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _buildQuickButton(
          label: '+1',
          onTap: () => onQuickProgress?.call(goal.currentValue + 1),
          isDark: isDark,
          isPrimary: true,
        ),
        const SizedBox(width: 8),
        _buildQuickButton(
          label: '+5',
          onTap: () => onQuickProgress?.call(goal.currentValue + 5),
          isDark: isDark,
        ),
        const Spacer(),
        _buildQuickButton(
          icon: LucideIcons.check,
          label: '完成',
          onTap: () => onQuickProgress?.call(goal.targetValue),
          isDark: isDark,
          isAccent: true,
        ),
      ],
    );
  }

  Widget _buildQuickButton({
    IconData? icon,
    String? label,
    VoidCallback? onTap,
    required bool isDark,
    bool isPrimary = false,
    bool isAccent = false,
  }) {
    Color bgColor;
    Color fgColor;

    if (isAccent) {
      bgColor = (isDark ? AppColorsDark.accent : AppColors.accent)
          .withOpacity(isDark ? 0.2 : 0.1);
      fgColor = isDark ? AppColorsDark.accent : AppColors.accent;
    } else if (isPrimary) {
      bgColor = (isDark ? AppColorsDark.primary : AppColors.primary);
      fgColor = isDark ? AppColorsDark.primaryForeground : AppColors.primaryForeground;
    } else {
      bgColor = isDark ? AppColorsDark.muted : AppColors.muted;
      fgColor = isDark ? AppColorsDark.foreground : AppColors.foreground;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: label != null ? 12 : 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: onTap != null ? bgColor : bgColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 14,
                color: onTap != null ? fgColor : fgColor.withOpacity(0.5),
              ),
            if (icon != null && label != null) const SizedBox(width: 4),
            if (label != null)
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: onTap != null ? fgColor : fgColor.withOpacity(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
            title: Text(
              '确认删除',
              style: TextStyle(
                color: isDark ? AppColorsDark.foreground : AppColors.foreground,
              ),
            ),
            content: Text(
              '确定要删除「${goal.title}」吗？',
              style: TextStyle(
                color: isDark ? AppColorsDark.foreground : AppColors.foreground,
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
