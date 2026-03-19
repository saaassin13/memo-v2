import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../../data/database/app_database.dart';
import 'category_config.dart';

/// 交易记录列表组件
class TransactionList extends StatelessWidget {
  /// 创建 TransactionList
  const TransactionList({
    super.key,
    required this.transactions,
    required this.onDelete,
    this.filterType,
  });

  /// 交易记录列表
  final List<Transaction> transactions;

  /// 删除回调
  final ValueChanged<String> onDelete;

  /// 过滤类型 (income/expense)，为 null 时显示全部
  final String? filterType;

  @override
  Widget build(BuildContext context) {
    // 根据 filterType 过滤
    final filteredList = filterType != null
        ? transactions.where((t) => t.type == filterType).toList()
        : transactions;

    if (filteredList.isEmpty) {
      return _buildEmptyState(context);
    }

    // 按日期分组
    final groupedTransactions = _groupByDate(filteredList);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final entry = groupedTransactions.entries.elementAt(index);
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
            LucideIcons.receipt,
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
        ],
      ),
    );
  }

  Map<String, List<Transaction>> _groupByDate(List<Transaction> list) {
    final map = <String, List<Transaction>>{};
    for (final t in list) {
      final key = _formatDateKey(t.date);
      map.putIfAbsent(key, () => []).add(t);
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

  Widget _buildDateGroup(BuildContext context, String dateKey, List<Transaction> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 计算当日收支合计
    double dayIncome = 0;
    double dayExpense = 0;
    for (final t in items) {
      if (t.type == 'income') {
        dayIncome += t.amount.abs();
      } else {
        dayExpense += t.amount.abs();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期标题
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateKey,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                ),
              ),
              Text(
                '收入 ${dayIncome.toStringAsFixed(0)} 支出 ${dayExpense.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground)
                      .withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        // 交易列表
        ...items.map((t) => _buildTransactionItem(context, t)),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = transaction.type == 'income';
    final config = getCategoryConfig(transaction.type, transaction.category);

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
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
            content: const Text('确定要删除这条记录吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => onDelete(transaction.id),
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
            // 分类图标
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                config.icon,
                size: 20,
                color: config.color,
              ),
            ),
            const SizedBox(width: 12),
            // 分类和备注
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                    ),
                  ),
                  if (transaction.note != null && transaction.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        transaction.note!,
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
            // 金额
            Text(
              '${isIncome ? '+' : '-'}${transaction.amount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isIncome
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
