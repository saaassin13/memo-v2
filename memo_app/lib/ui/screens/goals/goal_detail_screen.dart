import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/colors.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/goal_progress_provider.dart';
import '../../../providers/goal_provider.dart';
import '../../components/buttons/app_button.dart';
import 'widgets/goal_card.dart';
import 'widgets/goal_edit_sheet.dart';
import 'widgets/progress_ring.dart';

/// Detail screen for viewing a goal and its progress history.
class GoalDetailScreen extends ConsumerStatefulWidget {
  /// Creates a GoalDetailScreen.
  const GoalDetailScreen({super.key, required this.id});

  /// The goal ID.
  final String id;

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final goalAsync = ref.watch(goalByIdProvider(widget.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('目标详情'),
        actions: [
          goalAsync.whenOrNull(
                data: (goal) => goal != null
                    ? IconButton(
                        icon: const Icon(LucideIcons.settings),
                        onPressed: () => _showSettingsMenu(context, goal),
                      )
                    : null,
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: goalAsync.when(
        data: (goal) {
          if (goal == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    size: 48,
                    color: isDark
                        ? AppColorsDark.mutedForeground
                        : AppColors.mutedForeground,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '目标不存在',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: '返回',
                    variant: ButtonVariant.secondary,
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            );
          }
          return _buildContent(goal, isDark);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.alertCircle,
                size: 48,
                color:
                    isDark ? AppColorsDark.destructive : AppColors.destructive,
              ),
              const SizedBox(height: 16),
              Text(
                '加载失败: $e',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: '重试',
                variant: ButtonVariant.secondary,
                onPressed: () => ref.invalidate(goalByIdProvider(widget.id)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Goal goal, bool isDark) {
    final category = GoalCategory.fromString(goal.type);
    final progress = goal.targetValue > 0
        ? (goal.currentValue / goal.targetValue).clamp(0.0, 1.0)
        : 0.0;

    return CustomScrollView(
      slivers: [
        // Progress section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildProgressSection(goal, progress, category, isDark),
          ),
        ),

        // Goal info section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildInfoSection(goal, category, isDark),
          ),
        ),

        // Progress history header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                Icon(
                  LucideIcons.history,
                  size: 18,
                  color: isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground,
                ),
                const SizedBox(width: 8),
                Text(
                  '进度历史',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColorsDark.foreground
                        : AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Progress history list
        _buildProgressHistoryList(goal.id, isDark),
      ],
    );
  }

  Widget _buildProgressSection(
    Goal goal,
    double progress,
    GoalCategory category,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.card : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goal.completed
              ? (isDark ? AppColorsDark.accent : AppColors.accent)
                  .withOpacity(0.5)
              : (isDark ? AppColorsDark.border : AppColors.border),
          width: goal.completed ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Progress ring
          ProgressRing(
            progress: progress,
            size: 140,
            strokeWidth: 12,
            progressColor: goal.completed
                ? (isDark ? AppColorsDark.accent : AppColors.accent)
                : category.color,
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            goal.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
            textAlign: TextAlign.center,
          ),
          if (goal.description != null && goal.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              goal.description!,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColorsDark.mutedForeground
                    : AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${goal.currentValue}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: goal.completed
                      ? (isDark ? AppColorsDark.accent : AppColors.accent)
                      : category.color,
                ),
              ),
              Text(
                ' / ${goal.targetValue}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground,
                ),
              ),
              if (goal.unit != null && goal.unit!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  goal.unit!,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? AppColorsDark.mutedForeground
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ],
          ),
          if (goal.completed) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isDark ? AppColorsDark.accent : AppColors.accent)
                    .withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.check,
                    size: 16,
                    color: isDark ? AppColorsDark.accent : AppColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '目标已完成',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColorsDark.accent : AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(Goal goal, GoalCategory category, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.card : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColorsDark.border : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: category.icon,
            iconColor: category.color,
            label: '类型',
            value: category.label,
            isDark: isDark,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: LucideIcons.calendarPlus,
            label: '开始日期',
            value: _formatDate(goal.startDate),
            isDark: isDark,
          ),
          if (goal.endDate != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              icon: LucideIcons.calendarCheck,
              label: '截止日期',
              value: _formatDate(goal.endDate!),
              valueColor:
                  _getDeadlineColor(goal.endDate!, goal.completed, isDark),
              isDark: isDark,
            ),
          ],
          const Divider(height: 24),
          _buildInfoRow(
            icon: LucideIcons.clock,
            label: '创建时间',
            value: _formatDateTime(goal.createdAt),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    Color? iconColor,
    required String label,
    required String value,
    Color? valueColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor ??
              (isDark
                  ? AppColorsDark.mutedForeground
                  : AppColors.mutedForeground),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColorsDark.mutedForeground
                : AppColors.mutedForeground,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ??
                (isDark ? AppColorsDark.foreground : AppColors.foreground),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressHistoryList(String goalId, bool isDark) {
    final progressListAsync = ref.watch(goalProgressListProvider(goalId));

    return progressListAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? AppColorsDark.card : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColorsDark.border : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.inbox,
                    size: 48,
                    color: isDark
                        ? AppColorsDark.mutedForeground
                        : AppColors.mutedForeground,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无进度记录',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '更新进度时会自动记录',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final record = records[index];
              return _buildProgressRecordItem(record, isDark);
            },
            childCount: records.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              '加载失败: $e',
              style: TextStyle(
                color: isDark
                    ? AppColorsDark.mutedForeground
                    : AppColors.mutedForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRecordItem(GoalProgressRecord record, bool isDark) {
    final isPositive = record.change >= 0;
    final changeColor = isPositive
        ? (isDark ? AppColorsDark.accent : AppColors.accent)
        : (isDark ? AppColorsDark.destructive : AppColors.destructive);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.card : AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColorsDark.border : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Change indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: changeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${isPositive ? "+" : ""}${record.change}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: changeColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${record.previousValue}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColorsDark.mutedForeground
                            : AppColors.mutedForeground,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        LucideIcons.arrowRight,
                        size: 14,
                        color: isDark
                            ? AppColorsDark.mutedForeground
                            : AppColors.mutedForeground,
                      ),
                    ),
                    Text(
                      '${record.newValue}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColorsDark.foreground
                            : AppColors.foreground,
                      ),
                    ),
                  ],
                ),
                if (record.note != null && record.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.note!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColorsDark.foreground
                          : AppColors.foreground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Time
          Text(
            _formatRecordTime(record.createdAt),
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

  void _showSettingsMenu(BuildContext context, Goal goal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColorsDark.border : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Bug #6: When goal is completed, only show "Clone" and "Delete"
            // Hide "Edit" and "Complete/Uncomplete" for completed goals
            if (!goal.completed) ...[
              // Edit goal - only show for incomplete goals
              ListTile(
                leading: Icon(
                  LucideIcons.pencil,
                  color:
                      isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
                title: Text(
                  '编辑目标',
                  style: TextStyle(
                    color:
                        isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showEditSheet(context, goal);
                },
              ),
              // Complete goal - only show for incomplete goals
              ListTile(
                leading: Icon(
                  LucideIcons.check,
                  color:
                      isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
                title: Text(
                  '完成目标',
                  style: TextStyle(
                    color:
                        isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _toggleComplete(goal);
                },
              ),
            ],
            // Clone goal - only show for completed goals
            if (goal.completed)
              ListTile(
                leading: Icon(
                  LucideIcons.copy,
                  color:
                      isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
                title: Text(
                  '克隆目标',
                  style: TextStyle(
                    color: isDark
                        ? AppColorsDark.foreground
                        : AppColors.foreground,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _cloneGoal(goal);
                },
              ),
            const Divider(),
            // Delete goal - always show
            ListTile(
              leading: Icon(
                LucideIcons.trash2,
                color:
                    isDark ? AppColorsDark.destructive : AppColors.destructive,
              ),
              title: Text(
                '删除目标',
                style: TextStyle(
                  color:
                      isDark ? AppColorsDark.destructive : AppColors.destructive,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(goal);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _toggleComplete(Goal goal) {
    final newValue = goal.completed ? goal.currentValue : goal.targetValue;
    ref.read(goalListProvider().notifier).updateProgress(
          goal.id,
          newValue,
          note: goal.completed ? '取消完成' : '完成目标',
        );
    ref.invalidate(goalByIdProvider(widget.id));
  }

  void _cloneGoal(Goal goal) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '克隆目标',
          style: TextStyle(
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        content: Text(
          '将以「${goal.title}」为模板创建新目标，进度从零开始。',
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
              '克隆',
              style: TextStyle(
                color: isDark ? AppColorsDark.primary : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(goalListProvider().notifier).add(
            title: goal.title,
            description: goal.description,
            type: goal.type,
            targetValue: goal.targetValue,
            unit: goal.unit,
            startDate: DateTime.now(),
            endDate: goal.endDate != null
                ? DateTime.now().add(
                    goal.endDate!.difference(goal.startDate),
                  )
                : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('目标已克隆')),
        );
        context.pop();
      }
    }
  }

  void _confirmDelete(Goal goal) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
        title: Text(
          '确认删除',
          style: TextStyle(
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        content: Text(
          '确定要删除「${goal.title}」吗？此操作无法撤销。',
          style: TextStyle(
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
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
                color:
                    isDark ? AppColorsDark.destructive : AppColors.destructive,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ref.read(goalListProvider().notifier).delete(goal.id);
      context.pop();
    }
  }

  void _showEditSheet(BuildContext context, Goal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalEditSheet(
        goal: goal,
        onSave: (data) {
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
            completed: goal.currentValue >= data.targetValue,
            createdAt: goal.createdAt,
            updatedAt: DateTime.now(),
          );
          ref.read(goalListProvider().notifier).updateGoal(updatedGoal);
          ref.invalidate(goalByIdProvider(widget.id));
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatRecordTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (dateDay == today) {
      return '今天 $time';
    } else if (dateDay == today.subtract(const Duration(days: 1))) {
      return '昨天 $time';
    } else if (dateTime.year == now.year) {
      return '${dateTime.month}/${dateTime.day} $time';
    } else {
      return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
    }
  }

  Color _getDeadlineColor(DateTime endDate, bool completed, bool isDark) {
    if (completed) {
      return isDark ? AppColorsDark.foreground : AppColors.foreground;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final daysRemaining = end.difference(today).inDays;

    if (daysRemaining < 0) {
      return isDark ? AppColorsDark.destructive : AppColors.destructive;
    } else if (daysRemaining <= 7) {
      return const Color(0xFFF59E0B);
    }
    return isDark ? AppColorsDark.foreground : AppColors.foreground;
  }
}
