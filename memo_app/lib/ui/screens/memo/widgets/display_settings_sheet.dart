import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';

/// Display settings bottom sheet for memo list view configuration.
class DisplaySettingsSheet extends StatelessWidget {
  /// Creates a DisplaySettingsSheet.
  const DisplaySettingsSheet({
    super.key,
    required this.viewMode,
    required this.sortMode,
    required this.onViewModeChanged,
    required this.onSortModeChanged,
  });

  /// Current view mode: 'list' or 'grid'.
  final String viewMode;

  /// Current sort mode: 'createdAt' or 'updatedAt'.
  final String sortMode;

  /// Called when view mode is changed.
  final ValueChanged<String> onViewModeChanged;

  /// Called when sort mode is changed.
  final ValueChanged<String> onSortModeChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.card : AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColorsDark.muted : AppColors.muted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            '显示设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '选择备忘录的展示样式和排序方式',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 24),

          // View Mode Section
          Text(
            '展示样式',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OptionCard(
                  icon: LucideIcons.list,
                  label: '列表',
                  selected: viewMode == 'list',
                  onTap: () {
                    onViewModeChanged('list');
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OptionCard(
                  icon: LucideIcons.layoutGrid,
                  label: '网格',
                  selected: viewMode == 'grid',
                  onTap: () {
                    onViewModeChanged('grid');
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sort Mode Section
          Text(
            '排序方式',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OptionCard(
                  icon: LucideIcons.calendarDays,
                  label: '创建时间',
                  selected: sortMode == 'createdAt',
                  onTap: () {
                    onSortModeChanged('createdAt');
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OptionCard(
                  icon: LucideIcons.clock,
                  label: '修改时间',
                  selected: sortMode == 'updatedAt',
                  onTap: () {
                    onSortModeChanged('updatedAt');
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// A selectable option card for display settings.
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? primaryColor.withOpacity(0.1)
              : (isDark ? AppColorsDark.muted : AppColors.muted).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: selected
                  ? primaryColor
                  : (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? primaryColor
                    : (isDark ? AppColorsDark.foreground : AppColors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
