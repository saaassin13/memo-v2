import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/colors.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/countdown_provider.dart';
import '../../components/buttons/app_button.dart';
import '../../components/feedback/empty_state.dart';
import '../todo/widgets/category_filter.dart';
import 'widgets/countdown_card.dart';
import 'widgets/countdown_edit_sheet.dart';

/// The main Countdown screen displaying countdown list with category filter.
class CountdownScreen extends ConsumerStatefulWidget {
  /// Creates a CountdownScreen.
  const CountdownScreen({super.key});

  @override
  ConsumerState<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends ConsumerState<CountdownScreen> {
  String _activeCategory = '全部';

  static const List<String> _categories = ['全部', '生日', '节日', '重要日'];

  /// Map category display name to type value.
  static const Map<String, String?> _categoryToType = {
    '全部': null,
    '生日': 'birthday',
    '节日': 'festival',
    '重要日': 'important',
  };

  @override
  Widget build(BuildContext context) {
    final typeFilter = _categoryToType[_activeCategory];
    final countdownsAsync = ref.watch(countdownListProvider(type: typeFilter));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Category Filter
            CategoryFilter(
              categories: _categories,
              activeCategory: _activeCategory,
              onCategoryChanged: (cat) => setState(() => _activeCategory = cat),
            ),
            // Countdown List
            Expanded(
              child: countdownsAsync.when(
                data: (countdowns) => _buildCountdownContent(countdowns),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => CommonEmptyStates.error(
                  message: '加载失败: $e',
                  action: AppButton(
                    label: '重试',
                    variant: ButtonVariant.secondary,
                    onPressed: () => ref.invalidate(countdownListProvider(type: typeFilter)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditSheet(context),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColorsDark.primary
            : AppColors.primary,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColorsDark.primaryForeground
            : AppColors.primaryForeground,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '倒数纪念日',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
          ),
          Icon(
            LucideIcons.calendarHeart,
            color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownContent(List<Countdown> countdowns) {
    if (countdowns.isEmpty) {
      return _buildEmptyState();
    }

    // Sort by days remaining (closest first for future, most recent first for past)
    final sorted = List<Countdown>.from(countdowns);
    sorted.sort((a, b) {
      final daysA = CountdownHelper.calculateDays(
        a.targetDate,
        repeatYearly: a.repeatYearly,
      );
      final daysB = CountdownHelper.calculateDays(
        b.targetDate,
        repeatYearly: b.repeatYearly,
      );

      // Group: today (0), future (>0), past (<0)
      // Sort order: today first, then future by ascending days, then past by descending abs days
      if (daysA == 0 && daysB != 0) return -1;
      if (daysB == 0 && daysA != 0) return 1;

      if (daysA >= 0 && daysB >= 0) {
        return daysA.compareTo(daysB);
      } else if (daysA < 0 && daysB < 0) {
        return daysB.compareTo(daysA); // More recent (smaller abs) first
      } else {
        // One positive, one negative - positive comes first
        return daysA >= 0 ? -1 : 1;
      }
    });

    // Split into upcoming and past
    final upcoming = sorted.where((c) {
      final days = CountdownHelper.calculateDays(
        c.targetDate,
        repeatYearly: c.repeatYearly,
      );
      return days >= 0;
    }).toList();

    final past = sorted.where((c) {
      final days = CountdownHelper.calculateDays(
        c.targetDate,
        repeatYearly: c.repeatYearly,
      );
      return days < 0;
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Upcoming section
        if (upcoming.isNotEmpty) ...[
          _buildSectionHeader('即将到来', upcoming.length, isDark),
          const SizedBox(height: 12),
          ...upcoming.map((countdown) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CountdownCard(
                  countdown: countdown,
                  onTap: () => _showEditSheet(context, countdown: countdown),
                  onDelete: () => _deleteCountdown(countdown.id),
                ),
              )),
        ],
        // Past section
        if (past.isNotEmpty) ...[
          if (upcoming.isNotEmpty) const SizedBox(height: 16),
          _buildSectionHeader('已经过去', past.length, isDark),
          const SizedBox(height: 12),
          ...past.map((countdown) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CountdownCard(
                  countdown: countdown,
                  onTap: () => _showEditSheet(context, countdown: countdown),
                  onDelete: () => _deleteCountdown(countdown.id),
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, bool isDark) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: (isDark ? AppColorsDark.muted : AppColors.muted).withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      message: '暂无倒数日',
      description: '记录重要的日子，让每一天都有期待',
      icon: LucideIcons.calendarHeart,
      action: AppButton(
        label: '添加倒数日',
        icon: LucideIcons.plus,
        onPressed: () => _showEditSheet(context),
      ),
    );
  }

  void _deleteCountdown(String id) {
    final typeFilter = _categoryToType[_activeCategory];
    ref.read(countdownListProvider(type: typeFilter).notifier).delete(id);
  }

  void _showEditSheet(BuildContext context, {Countdown? countdown}) {
    final typeFilter = _categoryToType[_activeCategory];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CountdownEditSheet(
        countdown: countdown,
        onSave: (data) {
          if (countdown != null) {
            // Update existing countdown
            final updatedCountdown = Countdown(
              id: countdown.id,
              title: data.title,
              targetDate: data.targetDate,
              type: data.type,
              repeatYearly: data.repeatYearly,
              icon: countdown.icon,
              color: countdown.color,
              createdAt: countdown.createdAt,
              updatedAt: DateTime.now(),
            );
            ref
                .read(countdownListProvider(type: typeFilter).notifier)
                .updateCountdown(updatedCountdown);
          } else {
            // Create new countdown
            ref.read(countdownListProvider(type: typeFilter).notifier).add(
                  title: data.title,
                  targetDate: data.targetDate,
                  type: data.type,
                  repeatYearly: data.repeatYearly,
                );
          }
        },
      ),
    );
  }
}
