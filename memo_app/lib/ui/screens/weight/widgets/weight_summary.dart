import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../../data/repositories/weight_repository.dart';

/// 体重摘要组件
class WeightSummary extends StatelessWidget {
  /// 创建 WeightSummary
  const WeightSummary({
    super.key,
    required this.stats,
    this.previousWeight,
  });

  /// 体重统计数据
  final WeightStats stats;

  /// 上一次体重记录（用于计算对比）
  final double? previousWeight;

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
          // 当前体重
          _buildCurrentWeight(context, isDark),
          const SizedBox(height: 20),
          // 统计数据
          _buildStats(context, isDark),
        ],
      ),
    );
  }

  Widget _buildCurrentWeight(BuildContext context, bool isDark) {
    final currentWeight = stats.currentWeight;
    final change = _calculateChange();

    return Column(
      children: [
        Text(
          '当前体重',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currentWeight != null ? currentWeight.toStringAsFixed(1) : '--',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColorsDark.foreground : AppColors.foreground,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                ' kg',
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
        if (change != null) ...[
          const SizedBox(height: 8),
          _buildChangeIndicator(context, isDark, change),
        ],
      ],
    );
  }

  Widget _buildChangeIndicator(BuildContext context, bool isDark, double change) {
    final isIncrease = change > 0;
    final isDecrease = change < 0;
    final color = isIncrease
        ? const Color(0xFFEF4444)
        : isDecrease
            ? const Color(0xFF22C55E)
            : (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground);
    final icon = isIncrease
        ? LucideIcons.trendingUp
        : isDecrease
            ? LucideIcons.trendingDown
            : LucideIcons.minus;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '${isIncrease ? '+' : ''}${change.toStringAsFixed(1)} kg',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            ' 较上次',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, bool isDark) {
    return Row(
      children: [
        // 最低
        Expanded(
          child: _buildStatItem(
            context,
            isDark,
            label: '最低',
            value: stats.minWeight,
            icon: LucideIcons.arrowDown,
            color: const Color(0xFF22C55E),
          ),
        ),
        // 分隔线
        Container(
          width: 1,
          height: 50,
          color: (isDark ? AppColorsDark.border : AppColors.border).withOpacity(0.5),
        ),
        // 平均
        Expanded(
          child: _buildStatItem(
            context,
            isDark,
            label: '平均',
            value: stats.averageWeight,
            icon: LucideIcons.minus,
            color: isDark ? AppColorsDark.primary : AppColors.primary,
          ),
        ),
        // 分隔线
        Container(
          width: 1,
          height: 50,
          color: (isDark ? AppColorsDark.border : AppColors.border).withOpacity(0.5),
        ),
        // 最高
        Expanded(
          child: _buildStatItem(
            context,
            isDark,
            label: '最高',
            value: stats.maxWeight,
            icon: LucideIcons.arrowUp,
            color: const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    bool isDark, {
    required String label,
    required double? value,
    required IconData icon,
    required Color color,
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
          value != null ? '${value.toStringAsFixed(1)} kg' : '--',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
      ],
    );
  }

  double? _calculateChange() {
    if (stats.currentWeight == null || previousWeight == null) {
      return null;
    }
    return stats.currentWeight! - previousWeight!;
  }
}
