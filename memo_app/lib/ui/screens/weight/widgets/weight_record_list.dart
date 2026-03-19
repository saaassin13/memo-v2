import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../../data/database/app_database.dart';

/// 体重记录列表组件
class WeightRecordList extends StatelessWidget {
  /// 创建 WeightRecordList
  const WeightRecordList({
    super.key,
    required this.records,
    required this.onDelete,
    this.onTap,
  });

  /// 体重记录列表
  final List<WeightRecord> records;

  /// 删除回调
  final ValueChanged<String> onDelete;

  /// 点击回调
  final ValueChanged<WeightRecord>? onTap;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return _buildEmptyState(context);
    }

    // 按日期分组
    final groupedRecords = _groupByDate(records);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedRecords.length,
      itemBuilder: (context, index) {
        final entry = groupedRecords.entries.elementAt(index);
        return _buildDateGroup(context, entry.key, entry.value);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.scale,
            size: 48,
            color: (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground)
                .withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无记录',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮添加体重记录',
            style: TextStyle(
              fontSize: 14,
              color: (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground)
                  .withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<WeightRecord>> _groupByDate(List<WeightRecord> list) {
    final map = <String, List<WeightRecord>>{};
    for (final r in list) {
      final key = _formatDateKey(r.date);
      map.putIfAbsent(key, () => []).add(r);
    }
    return map;
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '今天';
    } else if (dateOnly == yesterday) {
      return '昨天';
    } else if (date.year == now.year) {
      return DateFormat('MM月dd日').format(date);
    } else {
      return DateFormat('yyyy年MM月dd日').format(date);
    }
  }

  Widget _buildDateGroup(
      BuildContext context, String dateKey, List<WeightRecord> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期标题
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            dateKey,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
          ),
        ),
        // 记录列表
        ...items.map((r) => _buildRecordItem(context, r, items)),
      ],
    );
  }

  Widget _buildRecordItem(
      BuildContext context, WeightRecord record, List<WeightRecord> groupItems) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 查找前一条记录计算变化
    final currentIndex = records.indexOf(record);
    WeightRecord? previousRecord;
    if (currentIndex < records.length - 1) {
      previousRecord = records[currentIndex + 1];
    }

    final change = previousRecord != null ? record.weight - previousRecord.weight : null;

    // 检查是否有运动标记（通过备注判断）
    final hasExercise = record.note?.contains('运动') == true ||
        record.note?.contains('exercise') == true ||
        record.note?.toLowerCase().contains('workout') == true;

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.destructive,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          LucideIcons.trash2,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认删除'),
            content: const Text('确定要删除这条体重记录吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.destructive,
                ),
                child: const Text('删除'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => onDelete(record.id),
      child: GestureDetector(
        onTap: () => onTap?.call(record),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.card : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColorsDark.border : AppColors.border,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // 体重图标
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: (isDark ? AppColorsDark.primary : AppColors.primary)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.scale,
                  size: 20,
                  color: isDark ? AppColorsDark.primary : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              // 体重值和备注
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${record.weight.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? AppColorsDark.foreground : AppColors.foreground,
                          ),
                        ),
                        if (hasExercise) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.dumbbell,
                                  size: 12,
                                  color: const Color(0xFF22C55E),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '运动',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF22C55E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (record.note != null && record.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          record.note!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColorsDark.mutedForeground
                                : AppColors.mutedForeground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              // 变化指示
              if (change != null)
                _buildChangeIndicator(isDark, change)
              else
                Text(
                  DateFormat('HH:mm').format(record.date),
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
      ),
    );
  }

  Widget _buildChangeIndicator(bool isDark, double change) {
    final isIncrease = change > 0;

    if (change.abs() < 0.01) {
      return Text(
        '-',
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
        ),
      );
    }

    final color = isIncrease ? const Color(0xFFEF4444) : const Color(0xFF22C55E);
    final icon = isIncrease ? LucideIcons.arrowUp : LucideIcons.arrowDown;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          change.abs().toStringAsFixed(1),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
