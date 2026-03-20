import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/colors.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/transaction_provider.dart';
import '../../components/feedback/empty_state.dart';
import 'widgets/add_transaction_sheet.dart';
import 'widgets/category_chart.dart';
import 'widgets/monthly_summary.dart';
import 'widgets/transaction_list.dart' as transaction_list;

/// 记账页面
class AccountingScreen extends ConsumerStatefulWidget {
  /// 创建 AccountingScreen
  const AccountingScreen({super.key});

  @override
  ConsumerState<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends ConsumerState<AccountingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late int _currentYear;
  late int _currentMonth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final now = DateTime.now();
    _currentYear = now.year;
    _currentMonth = now.month;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    setState(() {
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_currentYear == now.year && _currentMonth == now.month) {
      return;
    }

    setState(() {
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
  }

  void _showAddTransactionSheet({String? initialType}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionSheet(
        initialType: initialType ?? (_tabController.index == 0 ? 'expense' : 'income'),
        onSave: (data) async {
          await ref
              .read(transactionListProvider(
                year: _currentYear,
                month: _currentMonth,
              ).notifier)
              .add(
                amount: data.amount,
                type: data.type,
                category: data.category,
                date: data.date,
                note: data.note,
              );
          // Bug 6: Invalidate monthly stats to refresh totals after adding
          ref.invalidate(monthlyStatsProvider(_currentYear, _currentMonth));
        },
      ),
    );
  }

  void _deleteTransaction(String id) async {
    await ref
        .read(transactionListProvider(
          year: _currentYear,
          month: _currentMonth,
        ).notifier)
        .delete(id);
    // Bug 6: Invalidate monthly stats to refresh totals after deleting
    ref.invalidate(monthlyStatsProvider(_currentYear, _currentMonth));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionsAsync = ref.watch(transactionListProvider(
      year: _currentYear,
      month: _currentMonth,
    ));
    final statsAsync = ref.watch(monthlyStatsProvider(_currentYear, _currentMonth));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildHeader(context, isDark),
            // 月度汇总
            statsAsync.when(
              data: (stats) => MonthlySummary(
                year: _currentYear,
                month: _currentMonth,
                totalIncome: stats.totalIncome,
                totalExpense: stats.totalExpense,
                balance: stats.balance,
                onPreviousMonth: _previousMonth,
                onNextMonth: _nextMonth,
              ),
              loading: () => _buildSummaryLoading(isDark),
              error: (_, __) => _buildSummaryError(isDark),
            ),
            // Tab 栏
            _buildTabBar(isDark),
            // 内容区域
            Expanded(
              child: transactionsAsync.when(
                data: (transactions) => TabBarView(
                  controller: _tabController,
                  children: [
                    // 支出 Tab
                    _buildTabContent(
                      context,
                      isDark,
                      transactions,
                      'expense',
                      statsAsync,
                    ),
                    // 收入 Tab
                    _buildTabContent(
                      context,
                      isDark,
                      transactions,
                      'income',
                      statsAsync,
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => CommonEmptyStates.error(message: '加载失败: $e'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(),
        backgroundColor:
            isDark ? AppColorsDark.primary : AppColors.primary,
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
            '记账',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              LucideIcons.pieChart,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
            onPressed: () {
              // Bug 8: Navigate to statistics page
              context.push('/apps/accounting/stats');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLoading(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? AppColorsDark.primary : AppColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      height: 140,
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
      height: 140,
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: isDark ? AppColorsDark.foreground : AppColors.foreground,
        unselectedLabelColor:
            isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: '支出'),
          Tab(text: '收入'),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    bool isDark,
    List<Transaction> transactions,
    String type,
    AsyncValue statsAsync,
  ) {
    final filteredTransactions =
        transactions.where((t) => t.type == type).toList();

    if (filteredTransactions.isEmpty) {
      return _buildEmptyContent(context, isDark, type);
    }

    return Column(
      children: [
        // 图表区域
        statsAsync.when(
          data: (stats) {
            final categoryData = type == 'income'
                ? stats.categoryIncomes
                : stats.categoryExpenses;
            final total = type == 'income'
                ? stats.totalIncome
                : stats.totalExpense;

            if (categoryData.isEmpty) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: 160,
              child: CategoryChart(
                categoryData: categoryData,
                type: type,
                totalAmount: total,
              ),
            );
          },
          loading: () => const SizedBox(height: 160),
          error: (_, __) => const SizedBox(height: 160),
        ),
        // 分隔线
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            color: isDark ? AppColorsDark.border : AppColors.border,
            height: 1,
          ),
        ),
        // 交易列表
        Expanded(
          child: transaction_list.TransactionList(
            transactions: transactions,
            filterType: type,
            onDelete: _deleteTransaction,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyContent(BuildContext context, bool isDark, String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'expense' ? LucideIcons.receipt : LucideIcons.wallet,
            size: 48,
            color: (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground)
                .withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            type == 'expense' ? '暂无支出记录' : '暂无收入记录',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _showAddTransactionSheet(initialType: type),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: Text(type == 'expense' ? '记一笔支出' : '记一笔收入'),
          ),
        ],
      ),
    );
  }
}
