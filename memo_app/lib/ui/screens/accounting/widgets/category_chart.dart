import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import 'category_config.dart';

/// 分类饼图组件
class CategoryChart extends StatefulWidget {
  /// 创建 CategoryChart
  const CategoryChart({
    super.key,
    required this.categoryData,
    required this.type,
    this.totalAmount = 0,
  });

  /// 分类数据 Map<分类名, 金额>
  final Map<String, double> categoryData;

  /// 类型 (income/expense)
  final String type;

  /// 总金额
  final double totalAmount;

  @override
  State<CategoryChart> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<CategoryChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.categoryData.isEmpty || widget.totalAmount == 0) {
      return _buildEmptyState(context, isDark);
    }

    // 排序并获取数据
    final sortedEntries = widget.categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 饼图
          Expanded(
            flex: 5,
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = null;
                          return;
                        }
                        touchedIndex =
                            pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 36,
                  sections: _buildPieSections(sortedEntries),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 图例
          Expanded(
            flex: 5,
            child: _buildLegend(context, isDark, sortedEntries),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          '暂无数据',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
      List<MapEntry<String, double>> entries) {
    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == touchedIndex;
      final config = getCategoryConfig(widget.type, item.key);
      final percent = (item.value / widget.totalAmount * 100);

      return PieChartSectionData(
        color: config.color,
        value: item.value,
        title: isTouched ? '${percent.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 55 : 45,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(
    BuildContext context,
    bool isDark,
    List<MapEntry<String, double>> entries,
  ) {
    // 只显示前 6 个
    final displayEntries = entries.take(6).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: displayEntries.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final config = getCategoryConfig(widget.type, item.key);
        final percent = (item.value / widget.totalAmount * 100);
        final isTouched = index == touchedIndex;

        return GestureDetector(
          onTap: () {
            setState(() {
              touchedIndex = touchedIndex == index ? null : index;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                // 颜色指示器
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: config.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                // 分类名
                Expanded(
                  child: Text(
                    item.key,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isTouched ? FontWeight.w600 : FontWeight.normal,
                      color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 百分比
                Text(
                  '${percent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isTouched ? FontWeight.w600 : FontWeight.normal,
                    color: isDark
                        ? AppColorsDark.mutedForeground
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 简单的分类列表（不带图表）
class CategoryList extends StatelessWidget {
  /// 创建 CategoryList
  const CategoryList({
    super.key,
    required this.categoryData,
    required this.type,
    required this.totalAmount,
  });

  /// 分类数据
  final Map<String, double> categoryData;

  /// 类型
  final String type;

  /// 总金额
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (categoryData.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedEntries = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.map((entry) {
        final config = getCategoryConfig(type, entry.key);
        final percent = totalAmount > 0 ? entry.value / totalAmount : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: config.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      config.icon,
                      size: 16,
                      color: config.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                      ),
                    ),
                  ),
                  Text(
                    entry.value.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(percent * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor:
                      (isDark ? AppColorsDark.border : AppColors.border).withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(config.color),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
