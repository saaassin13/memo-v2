import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../../../data/database/app_database.dart';

/// 时间范围枚举
enum TimeRange {
  week,
  month,
  year,
}

/// 体重趋势图组件
class WeightChart extends StatefulWidget {
  /// 创建 WeightChart
  const WeightChart({
    super.key,
    required this.records,
    this.selectedRange,
    this.onTimeRangeChanged,
  });

  /// 体重记录列表
  final List<WeightRecord> records;

  /// 外部控制的时间范围
  final TimeRange? selectedRange;

  /// 时间范围变更回调
  final ValueChanged<TimeRange>? onTimeRangeChanged;

  @override
  State<WeightChart> createState() => _WeightChartState();
}

class _WeightChartState extends State<WeightChart> {
  TimeRange _internalRange = TimeRange.month;
  int? _touchedIndex;

  TimeRange get _selectedRange => widget.selectedRange ?? _internalRange;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredRecords = _getFilteredRecords();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 时间范围选择器
          _buildTimeRangeSelector(isDark),
          const SizedBox(height: 16),
          // 图表区域
          Expanded(
            child: filteredRecords.isEmpty
                ? _buildEmptyState(isDark)
                : _buildChart(isDark, filteredRecords),
          ),
        ],
      ),
    );
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
                  _internalRange = range;
                  _touchedIndex = null;
                });
                widget.onTimeRangeChanged?.call(range);
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground)
                .withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            '暂无数据',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(bool isDark, List<WeightRecord> records) {
    final spots = _createSpots(records);
    if (spots.isEmpty) {
      return _buildEmptyState(isDark);
    }

    final minY = _getMinY(records);
    final maxY = _getMaxY(records);
    final padding = (maxY - minY) * 0.1;
    final adjustedMinY = (minY - padding).clamp(0.0, double.infinity);
    final adjustedMaxY = maxY + padding;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(adjustedMaxY - adjustedMinY),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: (isDark ? AppColorsDark.border : AppColors.border).withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: _calculateInterval(adjustedMaxY - adjustedMinY),
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _getBottomTitleInterval(records.length),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= records.length) {
                  return const SizedBox.shrink();
                }
                final date = records[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _formatDateForAxis(date),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (records.length - 1).toDouble().clamp(0, double.infinity),
        minY: adjustedMinY,
        maxY: adjustedMaxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: isDark ? AppColorsDark.card : AppColors.card,
            tooltipBorder: BorderSide(
              color: isDark ? AppColorsDark.border : AppColors.border,
            ),
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index < 0 || index >= records.length) {
                  return null;
                }
                final record = records[index];
                return LineTooltipItem(
                  '${record.weight.toStringAsFixed(1)} kg\n',
                  TextStyle(
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: DateFormat('MM/dd').format(record.date),
                      style: TextStyle(
                        color: isDark
                            ? AppColorsDark.mutedForeground
                            : AppColors.mutedForeground,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
            setState(() {
              if (response == null || response.lineBarSpots == null) {
                _touchedIndex = null;
                return;
              }
              if (event is FlTapUpEvent || event is FlPanEndEvent) {
                _touchedIndex = null;
                return;
              }
              _touchedIndex = response.lineBarSpots!.first.x.toInt();
            });
          },
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: isDark ? AppColorsDark.primary : AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isTouched = index == _touchedIndex;
                return FlDotCirclePainter(
                  radius: isTouched ? 6 : 4,
                  color: isDark ? AppColorsDark.primary : AppColors.primary,
                  strokeWidth: isTouched ? 3 : 2,
                  strokeColor: isDark ? AppColorsDark.card : AppColors.card,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (isDark ? AppColorsDark.primary : AppColors.primary).withOpacity(0.3),
                  (isDark ? AppColorsDark.primary : AppColors.primary).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _createSpots(List<WeightRecord> records) {
    // 按日期排序（升序）
    final sorted = List<WeightRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    return sorted.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();
  }

  List<WeightRecord> _getFilteredRecords() {
    final now = DateTime.now();
    final startDate = switch (_selectedRange) {
      TimeRange.week => now.subtract(const Duration(days: 7)),
      TimeRange.month => DateTime(now.year, now.month - 1, now.day),
      TimeRange.year => DateTime(now.year - 1, now.month, now.day),
    };

    final filtered = widget.records
        .where((r) => r.date.isAfter(startDate) || r.date.isAtSameMomentAs(startDate))
        .toList();

    // 按日期升序排序
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }

  double _getMinY(List<WeightRecord> records) {
    if (records.isEmpty) return 0;
    return records.map((r) => r.weight).reduce((a, b) => a < b ? a : b);
  }

  double _getMaxY(List<WeightRecord> records) {
    if (records.isEmpty) return 100;
    return records.map((r) => r.weight).reduce((a, b) => a > b ? a : b);
  }

  double _calculateInterval(double range) {
    if (range <= 2) return 0.5;
    if (range <= 5) return 1;
    if (range <= 10) return 2;
    if (range <= 20) return 5;
    return 10;
  }

  double _getBottomTitleInterval(int count) {
    if (count <= 7) return 1;
    if (count <= 14) return 2;
    if (count <= 30) return 5;
    return 10;
  }

  String _formatDateForAxis(DateTime date) {
    return DateFormat('M/d').format(date);
  }

  String _getRangeLabel(TimeRange range) {
    return switch (range) {
      TimeRange.week => '周',
      TimeRange.month => '月',
      TimeRange.year => '年',
    };
  }
}
