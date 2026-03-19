import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

/// 日历视图模式
enum CalendarViewMode {
  day,
  week,
  month,
}

/// 日历头部组件
/// 包含标题和视图切换按钮 (日/周/月)
class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  /// 当前视图模式
  final CalendarViewMode viewMode;

  /// 视图模式改变回调
  final ValueChanged<CalendarViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 标题
          Text(
            '日历',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          // 视图切换按钮组
          _buildViewModeToggle(context, isDark),
        ],
      ),
    );
  }

  Widget _buildViewModeToggle(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.muted : AppColors.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            context: context,
            label: '日',
            mode: CalendarViewMode.day,
            isDark: isDark,
          ),
          _buildToggleButton(
            context: context,
            label: '周',
            mode: CalendarViewMode.week,
            isDark: isDark,
          ),
          _buildToggleButton(
            context: context,
            label: '月',
            mode: CalendarViewMode.month,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required String label,
    required CalendarViewMode mode,
    required bool isDark,
  }) {
    final isSelected = viewMode == mode;

    return GestureDetector(
      onTap: () => onViewModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColorsDark.card : AppColors.card)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? (isDark ? AppColorsDark.foreground : AppColors.foreground)
                : (isDark
                    ? AppColorsDark.mutedForeground
                    : AppColors.mutedForeground),
          ),
        ),
      ),
    );
  }
}
