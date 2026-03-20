import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/diary_provider.dart';
import '../../components/feedback/empty_state.dart';
import 'widgets/diary_card.dart';

/// 日记管理页面 - 支持周/月切换查看
class DiaryManagementScreen extends ConsumerStatefulWidget {
  const DiaryManagementScreen({super.key});

  @override
  ConsumerState<DiaryManagementScreen> createState() =>
      _DiaryManagementScreenState();
}

class _DiaryManagementScreenState extends ConsumerState<DiaryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _currentDate; // 用于周视图
  late DateTime _currentMonth; // 用于月视图

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    final now = DateTime.now();
    _currentDate = DateTime(now.year, now.month, now.day);
    _currentMonth = DateTime(now.year, now.month, 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _previousPeriod() {
    setState(() {
      if (_tabController.index == 0) {
        _currentDate = _currentDate.subtract(const Duration(days: 7));
      } else {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_tabController.index == 0) {
        _currentDate = _currentDate.add(const Duration(days: 7));
      } else {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      }
    });
  }

  String _getPeriodLabel() {
    if (_tabController.index == 0) {
      // 周视图: 显示该周的日期范围
      final weekday = _currentDate.weekday;
      final weekStart =
          _currentDate.subtract(Duration(days: weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      return '${weekStart.month}月${weekStart.day}日 - ${weekEnd.month}月${weekEnd.day}日';
    } else {
      return '${_currentMonth.year}年${_currentMonth.month}月';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final countAsync = ref.watch(diaryCountProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, countAsync),
            _buildPeriodSelector(isDark),
            _buildTabBar(isDark),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWeekView(isDark),
                  _buildMonthView(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    AsyncValue<int> countAsync,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '日记管理',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
            ),
          ),
          countAsync.when(
            data: (count) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isDark ? AppColorsDark.primary : AppColors.primary)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '共 $count 篇',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColorsDark.primary : AppColors.primary,
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
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
            onPressed: _previousPeriod,
          ),
          Text(
            _getPeriodLabel(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          IconButton(
            icon: Icon(
              LucideIcons.chevronRight,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
            onPressed: _nextPeriod,
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
          Tab(text: '周视图'),
          Tab(text: '月视图'),
        ],
      ),
    );
  }

  Widget _buildWeekView(bool isDark) {
    final diariesAsync = ref.watch(diariesByWeekProvider(_currentDate));

    return diariesAsync.when(
      data: (diaries) {
        if (diaries.isEmpty) {
          return CommonEmptyStates.noDiaries();
        }
        return _buildDiaryList(diaries, isDark);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => CommonEmptyStates.error(
        message: '加载失败: $e',
      ),
    );
  }

  Widget _buildMonthView(bool isDark) {
    final diariesAsync = ref.watch(
      diaryListProvider(year: _currentMonth.year, month: _currentMonth.month),
    );

    return diariesAsync.when(
      data: (diaries) {
        if (diaries.isEmpty) {
          return CommonEmptyStates.noDiaries();
        }
        return _buildDiaryList(diaries, isDark);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => CommonEmptyStates.error(
        message: '加载失败: $e',
      ),
    );
  }

  Widget _buildDiaryList(List<DiaryEntry> diaries, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: diaries.length,
      itemBuilder: (context, index) {
        final diary = diaries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DiaryCard(
            diary: diary,
            showDate: true,
            onTap: () => context.push(Routes.diaryDetail(diary.id)),
            onEdit: () => context.push(Routes.diaryDetail(diary.id)),
            onDelete: () => _confirmDelete(diary),
          ),
        );
      },
    );
  }

  void _confirmDelete(DiaryEntry diary) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '删除日记',
          style: TextStyle(
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        content: Text(
          '确定要删除这篇日记吗？此操作无法撤销。',
          style: TextStyle(
            color: isDark
                ? AppColorsDark.mutedForeground
                : AppColors.mutedForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '取消',
              style: TextStyle(
                color: isDark
                    ? AppColorsDark.mutedForeground
                    : AppColors.mutedForeground,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '删除',
              style: TextStyle(
                color: isDark ? AppColorsDark.destructive : AppColors.destructive,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (_tabController.index == 0) {
        // 周视图: refresh week provider
        ref.invalidate(diariesByWeekProvider(_currentDate));
      } else {
        // 月视图: refresh month provider
        ref.read(diaryListProvider(
          year: _currentMonth.year,
          month: _currentMonth.month,
        ).notifier).delete(diary.id);
      }
      // Refresh count
      ref.invalidate(diaryCountProvider);
    }
  }
}
