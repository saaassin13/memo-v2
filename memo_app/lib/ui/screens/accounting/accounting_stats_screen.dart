import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/colors.dart';
import '../../../providers/transaction_provider.dart';
import 'widgets/category_config.dart';

/// 记账统计页面 - 年度和月度统计视图 (Bug 8)
class AccountingStatsScreen extends ConsumerStatefulWidget {
  const AccountingStatsScreen({super.key});

  @override
  ConsumerState<AccountingStatsScreen> createState() =>
      _AccountingStatsScreenState();
}

class _AccountingStatsScreenState extends ConsumerState<AccountingStatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _currentYear;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentYear = DateTime.now().year;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColorsDark.background : AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '统计',
          style: TextStyle(
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
      ),
      body: Column(
        children: [
          // Year selector
          _buildYearSelector(isDark),
          // Tab bar
          _buildTabBar(isDark),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildYearlyView(isDark),
                _buildMonthlyView(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              LucideIcons.chevronLeft,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
            onPressed: () {
              setState(() {
                _currentYear--;
              });
            },
          ),
          Text(
            '$_currentYear 年',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          IconButton(
            icon: Icon(
              LucideIcons.chevronRight,
              color: _currentYear >= DateTime.now().year
                  ? (isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground)
                  : (isDark ? AppColorsDark.foreground : AppColors.foreground),
            ),
            onPressed: _currentYear >= DateTime.now().year
                ? null
                : () {
                    setState(() {
                      _currentYear++;
                    });
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.input : AppColors.input,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDark ? AppColorsDark.card : AppColors.card,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: isDark ? AppColorsDark.foreground : AppColors.foreground,
        unselectedLabelColor:
            isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
        tabs: const [
          Tab(text: '年度概览'),
          Tab(text: '月度明细'),
        ],
      ),
    );
  }

  Widget _buildYearlyView(bool isDark) {
    return FutureBuilder<YearlyStatsData>(
      future: _loadYearlyData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('加载失败: ${snapshot.error}'),
          );
        }

        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: '总收入',
                    amount: data.totalIncome,
                    color: Colors.green,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: '总支出',
                    amount: data.totalExpense,
                    color: isDark ? AppColorsDark.destructive : AppColors.destructive,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSummaryCard(
              title: '年度结余',
              amount: data.totalIncome - data.totalExpense,
              color: (data.totalIncome - data.totalExpense) >= 0
                  ? Colors.green
                  : (isDark ? AppColorsDark.destructive : AppColors.destructive),
              isDark: isDark,
              large: true,
            ),
            const SizedBox(height: 24),
            // Monthly trend chart
            Text(
              '月度趋势',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColorsDark.foreground : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildMonthlyTrendChart(data.monthlyData, isDark),
            ),
            const SizedBox(height: 24),
            // Category breakdown
            Text(
              '支出分类',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColorsDark.foreground : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 12),
            ...data.categoryExpenses.entries.map((e) => _buildCategoryRow(
                  e.key,
                  e.value,
                  data.totalExpense,
                  'expense',
                  isDark,
                )),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyView(bool isDark) {
    return FutureBuilder<YearlyStatsData>(
      future: _loadYearlyData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('加载失败: ${snapshot.error}'),
          );
        }

        final data = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 12,
          itemBuilder: (context, index) {
            final month = index + 1;
            final monthData = data.monthlyData[month];
            final income = monthData?['income'] ?? 0.0;
            final expense = monthData?['expense'] ?? 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColorsDark.card : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColorsDark.border : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${month}月',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColorsDark.foreground
                              : AppColors.foreground,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '结余: ${(income - expense).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: (income - expense) >= 0
                              ? Colors.green
                              : (isDark
                                  ? AppColorsDark.destructive
                                  : AppColors.destructive),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '收入',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColorsDark.mutedForeground
                                    : AppColors.mutedForeground,
                              ),
                            ),
                            Text(
                              income.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '支出',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColorsDark.mutedForeground
                                    : AppColors.mutedForeground,
                              ),
                            ),
                            Text(
                              expense.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColorsDark.destructive
                                    : AppColors.destructive,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required bool isDark,
    bool large = false,
  }) {
    return Container(
      padding: EdgeInsets.all(large ? 20 : 16),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.card : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColorsDark.border : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColorsDark.mutedForeground
                  : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount.toStringAsFixed(2),
            style: TextStyle(
              fontSize: large ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrendChart(
      Map<int, Map<String, double>> monthlyData, bool isDark) {
    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];

    for (int month = 1; month <= 12; month++) {
      final data = monthlyData[month];
      incomeSpots.add(FlSpot(month.toDouble(), data?['income'] ?? 0));
      expenseSpots.add(FlSpot(month.toDouble(), data?['expense'] ?? 0));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1000,
          getDrawingHorizontalLine: (value) => FlLine(
            color: (isDark ? AppColorsDark.border : AppColors.border)
                .withOpacity(0.5),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 1 && value.toInt() <= 12) {
                  return Text(
                    '${value.toInt()}月',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 1,
        maxX: 12,
        lineBarsData: [
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true,
            color: Colors.green,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.1),
            ),
          ),
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            color: isDark ? AppColorsDark.destructive : AppColors.destructive,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: (isDark ? AppColorsDark.destructive : AppColors.destructive)
                  .withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
    String category,
    double amount,
    double total,
    String type,
    bool isDark,
  ) {
    final config = getCategoryConfig(type, category);
    final percent = total > 0 ? amount / total : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColorsDark.foreground
                            : AppColors.foreground,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      amount.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColorsDark.foreground
                            : AppColors.foreground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: (isDark ? AppColorsDark.border : AppColors.border)
                        .withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(config.color),
                    minHeight: 4,
                  ),
                ),
              ],
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
    );
  }

  Future<YearlyStatsData> _loadYearlyData() async {
    double totalIncome = 0;
    double totalExpense = 0;
    final monthlyData = <int, Map<String, double>>{};
    final categoryExpenses = <String, double>{};

    for (int month = 1; month <= 12; month++) {
      final stats =
          await ref.read(monthlyStatsProvider(_currentYear, month).future);

      totalIncome += stats.totalIncome;
      totalExpense += stats.totalExpense;

      monthlyData[month] = {
        'income': stats.totalIncome,
        'expense': stats.totalExpense,
      };

      // Aggregate category expenses
      stats.categoryExpenses.forEach((cat, amount) {
        categoryExpenses[cat] = (categoryExpenses[cat] ?? 0) + amount;
      });
    }

    // Sort by amount
    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return YearlyStatsData(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      monthlyData: monthlyData,
      categoryExpenses: Map.fromEntries(sortedCategories),
    );
  }
}

class YearlyStatsData {
  final double totalIncome;
  final double totalExpense;
  final Map<int, Map<String, double>> monthlyData;
  final Map<String, double> categoryExpenses;

  YearlyStatsData({
    required this.totalIncome,
    required this.totalExpense,
    required this.monthlyData,
    required this.categoryExpenses,
  });
}
