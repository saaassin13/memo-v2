import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';

/// 月度汇总组件
class MonthlySummary extends StatelessWidget {
  /// 创建 MonthlySummary
  const MonthlySummary({
    super.key,
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  /// 当前年份
  final int year;

  /// 当前月份
  final int month;

  /// 总收入
  final double totalIncome;

  /// 总支出
  final double totalExpense;

  /// 结余
  final double balance;

  /// 上个月回调
  final VoidCallback onPreviousMonth;

  /// 下个月回调
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColorsDark.primary.withOpacity(0.3),
                  AppColorsDark.primary.withOpacity(0.1),
                ]
              : [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColorsDark.primary.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // 月份导航
          _buildMonthNavigation(context, isDark),
          const SizedBox(height: 20),
          // 收支统计
          _buildStats(context, isDark),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation(BuildContext context, bool isDark) {
    final now = DateTime.now();
    final isCurrentMonth = year == now.year && month == now.month;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPreviousMonth,
          icon: Icon(
            LucideIcons.chevronLeft,
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        const SizedBox(width: 8),
        Text(
          '$year年$month月',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: isCurrentMonth ? null : onNextMonth,
          icon: Icon(
            LucideIcons.chevronRight,
            color: isCurrentMonth
                ? (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground)
                    .withOpacity(0.3)
                : (isDark ? AppColorsDark.foreground : AppColors.foreground),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, bool isDark) {
    return Row(
      children: [
        // 支出
        Expanded(
          child: _buildStatItem(
            context,
            isDark,
            label: '支出',
            amount: totalExpense,
            color: const Color(0xFFEF4444),
            icon: LucideIcons.arrowDownLeft,
          ),
        ),
        // 分隔线
        Container(
          width: 1,
          height: 50,
          color: (isDark ? AppColorsDark.border : AppColors.border).withOpacity(0.5),
        ),
        // 收入
        Expanded(
          child: _buildStatItem(
            context,
            isDark,
            label: '收入',
            amount: totalIncome,
            color: const Color(0xFF22C55E),
            icon: LucideIcons.arrowUpRight,
          ),
        ),
        // 分隔线
        Container(
          width: 1,
          height: 50,
          color: (isDark ? AppColorsDark.border : AppColors.border).withOpacity(0.5),
        ),
        // 结余
        Expanded(
          child: _buildStatItem(
            context,
            isDark,
            label: '结余',
            amount: balance,
            color: balance >= 0
                ? const Color(0xFF22C55E)
                : const Color(0xFFEF4444),
            icon: LucideIcons.wallet,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    bool isDark, {
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: color.withOpacity(0.8),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _formatAmount(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(1)}万';
    }
    return amount.toStringAsFixed(2);
  }
}
