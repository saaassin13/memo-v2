import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/colors.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/goal_provider.dart';
import '../../components/buttons/app_button.dart';
import 'widgets/goal_card.dart';
import 'widgets/goal_edit_sheet.dart';
import 'widgets/progress_ring.dart';

/// Detail screen for viewing and updating a goal.
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
                    icon: const Icon(LucideIcons.pencil),
                    onPressed: () => _showEditSheet(context, goal),
                  )
                : null,
          ) ?? const SizedBox.shrink(),
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
                color: isDark ? AppColorsDark.destructive : AppColors.destructive,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress ring section
          _buildProgressSection(goal, progress, category, isDark),
          const SizedBox(height: 24),
          // Goal info section
          _buildInfoSection(goal, category, isDark),
          const SizedBox(height: 24),
          // Progress update section
          if (!goal.completed) ...[
            _buildUpdateProgressSection(goal, isDark),
            const SizedBox(height: 24),
          ],
          // Quick actions
          _buildQuickActions(goal, isDark),
          const SizedBox(height: 24),
          // Delete button
          _buildDeleteButton(goal, isDark),
        ],
      ),
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
            size: 160,
            strokeWidth: 14,
            progressColor:
                goal.completed ? (isDark ? AppColorsDark.accent : AppColors.accent) : category.color,
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 16),
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
              valueColor: _getDeadlineColor(goal.endDate!, goal.completed, isDark),
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
              (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
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

  Widget _buildUpdateProgressSection(Goal goal, bool isDark) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '更新进度',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Decrement button
              _buildProgressButton(
                icon: LucideIcons.minus,
                onPressed: goal.currentValue > 0
                    ? () => _updateProgress(goal.id, goal.currentValue - 1)
                    : null,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              // Current value display
              Expanded(
                child: GestureDetector(
                  onTap: () => _showSetProgressDialog(goal),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColorsDark.input : AppColors.input,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${goal.currentValue}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColorsDark.foreground
                              : AppColors.foreground,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Increment button
              _buildProgressButton(
                icon: LucideIcons.plus,
                onPressed: () => _updateProgress(goal.id, goal.currentValue + 1),
                isDark: isDark,
                isPrimary: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quick increment buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [1, 5, 10].map((amount) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AppButton(
                    label: '+$amount',
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.sm,
                    onPressed: () =>
                        _updateProgress(goal.id, goal.currentValue + amount),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDark,
    bool isPrimary = false,
  }) {
    final bgColor = isPrimary
        ? (isDark ? AppColorsDark.primary : AppColors.primary)
        : (isDark ? AppColorsDark.muted : AppColors.muted);
    final fgColor = isPrimary
        ? (isDark ? AppColorsDark.primaryForeground : AppColors.primaryForeground)
        : (isDark ? AppColorsDark.foreground : AppColors.foreground);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: onPressed != null ? bgColor : bgColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 24,
          color: onPressed != null ? fgColor : fgColor.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildQuickActions(Goal goal, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: goal.completed ? '标记为进行中' : '标记为完成',
            icon: goal.completed ? LucideIcons.rotateCcw : LucideIcons.check,
            variant: goal.completed ? ButtonVariant.secondary : ButtonVariant.primary,
            onPressed: () => _toggleComplete(goal),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton(Goal goal, bool isDark) {
    return AppButton(
      label: '删除目标',
      icon: LucideIcons.trash2,
      variant: ButtonVariant.destructive,
      fullWidth: true,
      onPressed: () => _confirmDelete(goal),
    );
  }

  void _updateProgress(String id, int newValue) {
    if (newValue < 0) return;
    ref.read(goalListProvider().notifier).updateProgress(id, newValue);
  }

  void _toggleComplete(Goal goal) {
    final newValue = goal.completed ? goal.currentValue : goal.targetValue;
    _updateProgress(goal.id, newValue);
  }

  void _showSetProgressDialog(Goal goal) {
    final controller =
        TextEditingController(text: goal.currentValue.toString());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
        title: Text(
          '设置进度',
          style: TextStyle(
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          decoration: InputDecoration(
            hintText: '输入当前进度',
            suffixText: '/ ${goal.targetValue}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
            onPressed: () {
              final value = int.tryParse(controller.text) ?? 0;
              _updateProgress(goal.id, value);
              Navigator.pop(context);
            },
            child: Text(
              '确定',
              style: TextStyle(
                color: isDark ? AppColorsDark.primary : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
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
                color: isDark ? AppColorsDark.destructive : AppColors.destructive,
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
