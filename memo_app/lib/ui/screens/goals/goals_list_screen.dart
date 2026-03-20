import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/colors.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/goal_provider.dart';
import '../../components/buttons/app_button.dart';
import '../../components/feedback/empty_state.dart';
import '../todo/widgets/category_filter.dart';
import 'widgets/goal_card.dart';
import 'widgets/goal_edit_sheet.dart';
import 'widgets/progress_update_sheet.dart';

/// The main Goals screen displaying goal list with category filter.
class GoalsListScreen extends ConsumerStatefulWidget {
  /// Creates a GoalsListScreen.
  const GoalsListScreen({super.key});

  @override
  ConsumerState<GoalsListScreen> createState() => _GoalsListScreenState();
}

class _GoalsListScreenState extends ConsumerState<GoalsListScreen> {
  String _activeCategory = '全部';

  static const List<String> _categories = ['全部', '进行中', '已完成'];

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Goal>> goalsAsync;

    if (_activeCategory == '进行中') {
      goalsAsync = ref.watch(activeGoalsProvider);
    } else if (_activeCategory == '已完成') {
      goalsAsync = ref.watch(completedGoalsProvider);
    } else {
      goalsAsync = ref.watch(goalListProvider());
    }

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
            // Goal List
            Expanded(
              child: goalsAsync.when(
                data: (goals) => _buildGoalContent(goals),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => CommonEmptyStates.error(
                  message: '加载失败: $e',
                  action: AppButton(
                    label: '重试',
                    variant: ButtonVariant.secondary,
                    onPressed: () => ref.invalidate(goalListProvider()),
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
            '目标',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
          ),
          Icon(
            LucideIcons.target,
            color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalContent(List<Goal> goals) {
    if (goals.isEmpty) {
      return _buildEmptyState();
    }

    // Sort goals: incomplete first (by end date), then completed
    final sorted = List<Goal>.from(goals);
    sorted.sort((a, b) {
      // Completed goals at the end
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1;
      }

      // For incomplete goals, sort by end date (nearest first)
      if (!a.completed && !b.completed) {
        if (a.endDate != null && b.endDate != null) {
          return a.endDate!.compareTo(b.endDate!);
        }
        if (a.endDate != null) return -1;
        if (b.endDate != null) return 1;
      }

      // Default: sort by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    // Split into active and completed
    final active = sorted.where((g) => !g.completed).toList();
    final completed = sorted.where((g) => g.completed).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Active goals section
        if (active.isNotEmpty) ...[
          _buildSectionHeader('进行中', active.length, isDark),
          const SizedBox(height: 12),
          ...active.map((goal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GoalCard(
                  goal: goal,
                  onTap: () => _navigateToDetail(goal.id),
                  onDelete: () => _deleteGoal(goal.id),
                  // Progress update button opens sheet
                  onProgressUpdate: () => _showProgressUpdateSheet(goal),
                ),
              )),
        ],
        // Completed goals section
        if (completed.isNotEmpty) ...[
          if (active.isNotEmpty) const SizedBox(height: 16),
          _buildSectionHeader('已完成', completed.length, isDark),
          const SizedBox(height: 12),
          ...completed.map((goal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GoalCard(
                  goal: goal,
                  onTap: () => _navigateToDetail(goal.id),
                  onDelete: () => _deleteGoal(goal.id),
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
            color:
                (isDark ? AppColorsDark.muted : AppColors.muted).withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color:
                  isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    String message;
    String description;

    switch (_activeCategory) {
      case '进行中':
        message = '暂无进行中的目标';
        description = '所有目标都已完成，太棒了！';
        break;
      case '已完成':
        message = '暂无已完成的目标';
        description = '努力完成你的第一个目标吧';
        break;
      default:
        message = '暂无目标';
        description = '设定一个目标，开始你的进步之旅';
    }

    return EmptyState(
      message: message,
      description: description,
      icon: LucideIcons.target,
      action: _activeCategory != '已完成'
          ? AppButton(
              label: '添加目标',
              icon: LucideIcons.plus,
              onPressed: () => _showEditSheet(context),
            )
          : null,
    );
  }

  void _navigateToDetail(String id) {
    context.push('/apps/goals/$id');
  }

  void _deleteGoal(String id) {
    ref.read(goalListProvider().notifier).delete(id);
  }

  /// Show progress update sheet with +/- controls and note input
  void _showProgressUpdateSheet(Goal goal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ProgressUpdateSheet(
        goal: goal,
        onUpdate: (newValue, note) {
          ref.read(goalListProvider().notifier).updateProgress(
                goal.id,
                newValue,
                note: note,
              );
        },
      ),
    );
  }

  void _showEditSheet(BuildContext context, {Goal? goal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalEditSheet(
        goal: goal,
        onSave: (data) {
          if (goal != null) {
            // Update existing goal
            final updatedGoal = Goal(
              id: goal.id,
              title: data.title,
              description: data.description,
              type: data.type,
              targetValue: data.targetValue,
              currentValue: goal.currentValue,
              unit: data.unit,
              startDate: data.startDate,
              endDate: data.endDate,
              completed: goal.completed,
              createdAt: goal.createdAt,
              updatedAt: DateTime.now(),
            );
            ref.read(goalListProvider().notifier).updateGoal(updatedGoal);
          } else {
            // Create new goal
            ref.read(goalListProvider().notifier).add(
                  title: data.title,
                  description: data.description,
                  type: data.type,
                  targetValue: data.targetValue,
                  unit: data.unit,
                  startDate: data.startDate,
                  endDate: data.endDate,
                );
          }
        },
      ),
    );
  }
}
