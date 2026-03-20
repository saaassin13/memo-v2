import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/diary_provider.dart';
import '../../components/buttons/app_button.dart';
import '../../components/feedback/empty_state.dart';
import 'widgets/diary_calendar.dart';
import 'widgets/diary_card.dart';

/// The main Diary list screen with calendar view.
class DiaryListScreen extends ConsumerStatefulWidget {
  /// Creates a DiaryListScreen.
  const DiaryListScreen({super.key});

  @override
  ConsumerState<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends ConsumerState<DiaryListScreen> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _currentMonth = DateTime(now.year, now.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch diary dates for current month
    final datesAsync = ref.watch(
      diaryDatesProvider(_currentMonth.year, _currentMonth.month),
    );

    // Watch diary for selected date
    final selectedDiaryAsync = ref.watch(diaryByDateProvider(_selectedDate));

    // Watch all diaries for history list
    final diariesAsync = ref.watch(
      diaryListProvider(year: _currentMonth.year, month: _currentMonth.month),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),
            // Content
            Expanded(
              child: datesAsync.when(
                data: (dates) => _buildContent(
                  context,
                  isDark,
                  dates,
                  selectedDiaryAsync,
                  diariesAsync,
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => CommonEmptyStates.error(
                  message: '加载失败: $e',
                  action: AppButton(
                    label: '重试',
                    variant: ButtonVariant.secondary,
                    onPressed: () => ref.invalidate(
                      diaryDatesProvider(_currentMonth.year, _currentMonth.month),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNewDiary(),
        backgroundColor: isDark ? AppColorsDark.primary : AppColors.primary,
        foregroundColor:
            isDark ? AppColorsDark.primaryForeground : AppColors.primaryForeground,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
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
          // Back button
          IconButton(
            icon: Icon(
              LucideIcons.arrowLeft,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
            onPressed: () => context.go('/'),
          ),
          const SizedBox(width: 8),
          // Title
          Expanded(
            child: Text(
              '日记',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
            ),
          ),
          // Write diary button
          TextButton.icon(
            onPressed: () => _navigateToNewDiary(),
            icon: Icon(
              LucideIcons.pencil,
              size: 18,
              color: isDark ? AppColorsDark.primary : AppColors.primary,
            ),
            label: Text(
              '写日记',
              style: TextStyle(
                color: isDark ? AppColorsDark.primary : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isDark,
    List<DateTime> datesWithEntries,
    AsyncValue<DiaryEntry?> selectedDiaryAsync,
    AsyncValue<List<DiaryEntry>> diariesAsync,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Calendar
        DiaryCalendar(
          selectedDate: _selectedDate,
          currentMonth: _currentMonth,
          datesWithEntries: datesWithEntries,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
          onMonthChanged: (month) {
            setState(() {
              _currentMonth = month;
              // Reset selected date to first day of new month
              _selectedDate = DateTime(month.year, month.month, 1);
            });
            // Refresh diary dates for new month
            ref.invalidate(diaryDatesProvider(month.year, month.month));
          },
        ),
        const SizedBox(height: 24),

        // Selected date diary
        selectedDiaryAsync.when(
          data: (diary) => diary != null
              ? _buildSelectedDateDiary(context, isDark, diary)
              : _buildNoSelectedDateDiary(context, isDark),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, s) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 24),

        // History section
        _buildHistorySection(context, isDark, diariesAsync),
      ],
    );
  }

  Widget _buildSelectedDateDiary(
    BuildContext context,
    bool isDark,
    DiaryEntry diary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatSelectedDate(_selectedDate),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        DiaryCard(
          diary: diary,
          showDate: false,
          onTap: () => context.push(Routes.diaryDetail(diary.id)),
          onEdit: () => context.push('${Routes.diaryDetail(diary.id)}/edit'),
          onDelete: () => _confirmDelete(diary),
        ),
      ],
    );
  }

  Widget _buildNoSelectedDateDiary(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatSelectedDate(_selectedDate),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.card : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColorsDark.border : AppColors.border,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(
                LucideIcons.bookOpen,
                size: 32,
                color: isDark
                    ? AppColorsDark.mutedForeground
                    : AppColors.mutedForeground,
              ),
              const SizedBox(height: 12),
              Text(
                '这一天还没有日记',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _navigateToNewDiary(date: _selectedDate),
                icon: Icon(
                  LucideIcons.plus,
                  size: 16,
                  color: isDark ? AppColorsDark.primary : AppColors.primary,
                ),
                label: Text(
                  '写日记',
                  style: TextStyle(
                    color: isDark ? AppColorsDark.primary : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    bool isDark,
    AsyncValue<List<DiaryEntry>> diariesAsync,
  ) {
    return diariesAsync.when(
      data: (diaries) {
        // Filter out selected date diary from history
        final historyDiaries = diaries
            .where((d) => !_isSameDay(d.date, _selectedDate))
            .toList();

        if (historyDiaries.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '历史日记',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColorsDark.mutedForeground
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            ...historyDiaries.map((diary) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DiaryCard(
                    diary: diary,
                    showDate: true, // Show date in history list (Bug 4)
                    onTap: () => context.push(Routes.diaryDetail(diary.id)),
                    onEdit: () => context.push(Routes.diaryDetail(diary.id)),
                    onDelete: () => _confirmDelete(diary),
                  ),
                )),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  void _navigateToNewDiary({DateTime? date}) {
    // Navigate to new diary page with optional date
    if (date != null) {
      context.push('${Routes.diaryNew}?date=${date.toIso8601String()}');
    } else {
      context.push(Routes.diaryNew);
    }
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
      ref
          .read(diaryListProvider(
            year: _currentMonth.year,
            month: _currentMonth.month,
          ).notifier)
          .delete(diary.id);
      // Refresh diary dates
      ref.invalidate(
        diaryDatesProvider(_currentMonth.year, _currentMonth.month),
      );
      // Refresh selected date diary
      ref.invalidate(diaryByDateProvider(_selectedDate));
    }
  }

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    String prefix = '';
    if (dateDay == today) {
      prefix = '今天 - ';
    } else if (dateDay == today.subtract(const Duration(days: 1))) {
      prefix = '昨天 - ';
    }

    return '$prefix${date.year}年${date.month}月${date.day}日';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
