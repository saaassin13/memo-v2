import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/colors.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/weight_provider.dart';
import '../../components/feedback/empty_state.dart';
import 'widgets/add_weight_sheet.dart';
import 'widgets/weight_chart.dart';
import 'widgets/weight_record_list.dart';
import 'widgets/weight_summary.dart';

/// 体重记录页面
class WeightScreen extends ConsumerStatefulWidget {
  /// 创建 WeightScreen
  const WeightScreen({super.key});

  @override
  ConsumerState<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends ConsumerState<WeightScreen> {
  static const int _pageSize = 10;

  bool _showChart = false;
  TimeRange _selectedRange = TimeRange.month;
  int _displayCount = _pageSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weightsAsync = ref.watch(weightsStreamProvider);
    final statsAsync = ref.watch(weightStatsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildHeader(context, isDark),
            // 内容区域
            Expanded(
              child: weightsAsync.when(
                data: (records) => _buildContent(context, isDark, records, statsAsync),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => CommonEmptyStates.error(message: '加载失败: $e'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWeightSheet(context, statsAsync),
        backgroundColor: isDark ? AppColorsDark.primary : AppColors.primary,
        foregroundColor:
            isDark ? AppColorsDark.primaryForeground : AppColors.primaryForeground,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.background : AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColorsDark.border : AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              LucideIcons.arrowLeft,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
            onPressed: () => context.go('/'),
          ),
          const SizedBox(width: 8),
          Text(
            '体重',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          const Spacer(),
          // 图表/列表切换按钮
          IconButton(
            icon: Icon(
              _showChart ? LucideIcons.list : LucideIcons.lineChart,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
            onPressed: () {
              setState(() {
                _showChart = !_showChart;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isDark,
    List<WeightRecord> records,
    AsyncValue<dynamic> statsAsync,
  ) {
    if (records.isEmpty) {
      return _buildEmptyContent(context, isDark, statsAsync);
    }

    // 计算前一次体重（用于对比）
    double? previousWeight;
    if (records.length > 1) {
      previousWeight = records[1].weight;
    }

    // 按时间范围过滤记录
    final filteredRecords = _filterRecordsByRange(records, _selectedRange);
    // 过滤后的记录按日期降序排列
    filteredRecords.sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        // 体重摘要
        statsAsync.when(
          data: (stats) => WeightSummary(
            stats: stats,
            previousWeight: previousWeight,
          ),
          loading: () => _buildSummaryLoading(isDark),
          error: (_, __) => _buildSummaryError(isDark),
        ),
        // 图表或列表区域
        _showChart
            ? _buildChartSection(context, isDark, records, filteredRecords)
            : _buildListSection(context, isDark, filteredRecords),
      ],
    );
  }

  Widget _buildEmptyContent(
      BuildContext context, bool isDark, AsyncValue<dynamic> statsAsync) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.scale,
            size: 64,
            color: (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground)
                .withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无体重记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '开始记录你的体重变化',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => _showAddWeightSheet(context, statsAsync),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('添加记录'),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? AppColorsDark.primary : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(
      BuildContext context, bool isDark, List<WeightRecord> records) {
    final hasMore = _displayCount < records.length;
    final displayRecords = records.take(_displayCount).toList();

    return Expanded(
      child: Column(
        children: [
          // 时间范围选择器
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _buildTimeRangeSelector(isDark),
          ),
          // 记录列表
          Expanded(
            child: WeightRecordList(
              records: displayRecords,
              hasMore: hasMore,
              onLoadMore: hasMore
                  ? () {
                      setState(() {
                        _displayCount += _pageSize;
                      });
                    }
                  : null,
              onDelete: (id) => _deleteRecord(id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(
      BuildContext context, bool isDark, List<WeightRecord> allRecords, List<WeightRecord> filteredRecords) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 图表区域
          SizedBox(
            height: 220,
            child: WeightChart(
              records: allRecords,
              selectedRange: _selectedRange,
              onTimeRangeChanged: (range) {
                setState(() {
                  _selectedRange = range;
                });
              },
            ),
          ),
          // 分隔线
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: isDark ? AppColorsDark.border : AppColors.border,
              height: 1,
            ),
          ),
          // 最近记录标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  '最近记录',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
                ),
                const Spacer(),
                Text(
                  '共 ${filteredRecords.length} 条',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          // 记录列表（内嵌在 ListView 中，不再需要 Expanded）
          ...filteredRecords.take(10).map((record) => _buildRecordItem(context, isDark, record, filteredRecords)),
        ],
      ),
    );
  }

  List<WeightRecord> _filterRecordsByRange(List<WeightRecord> records, TimeRange range) {
    final now = DateTime.now();
    final startDate = switch (range) {
      TimeRange.week => now.subtract(const Duration(days: 7)),
      TimeRange.month => DateTime(now.year, now.month - 1, now.day),
      TimeRange.year => DateTime(now.year - 1, now.month, now.day),
    };

    return records
        .where((r) => r.date.isAfter(startDate) || r.date.isAtSameMomentAs(startDate))
        .toList();
  }

  Widget _buildTimeRangeSelector(bool isDark) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.input : AppColors.input,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: TimeRange.values.map((range) {
          final isSelected = _selectedRange == range;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRange = range;
                  _displayCount = _pageSize;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColorsDark.card : AppColors.card)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                margin: const EdgeInsets.all(3),
                child: Center(
                  child: Text(
                    _getRangeLabel(range),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? AppColorsDark.foreground : AppColors.foreground)
                          : (isDark
                              ? AppColorsDark.mutedForeground
                              : AppColors.mutedForeground),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getRangeLabel(TimeRange range) {
    return switch (range) {
      TimeRange.week => '周',
      TimeRange.month => '月',
      TimeRange.year => '年',
    };
  }

  Widget _buildRecordItem(BuildContext context, bool isDark, WeightRecord record, List<WeightRecord> allRecords) {
    final index = allRecords.indexOf(record);
    final previousWeight = index < allRecords.length - 1 ? allRecords[index + 1].weight : null;
    final change = previousWeight != null ? record.weight - previousWeight : null;

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: isDark ? AppColorsDark.destructive : AppColors.destructive,
        child: Icon(
          LucideIcons.trash2,
          color: isDark ? AppColorsDark.destructiveForeground : AppColors.destructiveForeground,
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
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('删除'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) => _deleteRecord(record.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColorsDark.border : AppColors.border,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // 日期
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.date.month}月${record.date.day}日',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
                ),
                Text(
                  _getWeekday(record.date.weekday),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // 体重变化
            if (change != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: change > 0
                      ? (isDark ? AppColorsDark.destructive : AppColors.destructive).withValues(alpha: 0.1)
                      : change < 0
                          ? Colors.green.withValues(alpha: 0.1)
                          : (isDark ? AppColorsDark.muted : AppColors.muted),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change > 0 ? '+${change.toStringAsFixed(1)}' : change.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: change > 0
                        ? (isDark ? AppColorsDark.destructive : AppColors.destructive)
                        : change < 0
                            ? Colors.green
                            : (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground),
                  ),
                ),
              ),
            // 体重
            Text(
              '${record.weight.toStringAsFixed(1)} kg',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColorsDark.foreground : AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekday(int weekday) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[weekday - 1];
  }

  Widget _buildSummaryLoading(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? AppColorsDark.primary : AppColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      height: 180,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildSummaryError(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? AppColorsDark.primary : AppColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      height: 180,
      child: Center(
        child: Text(
          '加载失败',
          style: TextStyle(
            color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }

  void _showAddWeightSheet(BuildContext context, AsyncValue<dynamic> statsAsync) {
    // 获取当前体重作为初始值
    double? initialWeight;
    if (statsAsync.hasValue && statsAsync.value != null) {
      initialWeight = statsAsync.value.currentWeight;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddWeightSheet(
        initialWeight: initialWeight,
        onSave: (data) async {
          await ref.read(weightListProvider().notifier).add(
                weight: data.weight,
                date: data.date,
                note: data.note,
              );
          // Bug 13: Invalidate providers to auto-refresh after adding
          ref.invalidate(weightsStreamProvider);
          ref.invalidate(weightStatsProvider);
        },
      ),
    );
  }

  void _deleteRecord(String id) async {
    await ref.read(weightListProvider().notifier).delete(id);
    // Bug 13: Invalidate providers to auto-refresh after deleting
    ref.invalidate(weightsStreamProvider);
    ref.invalidate(weightStatsProvider);
  }
}
