import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/colors.dart';
import '../../../providers/memo_provider.dart';
import '../../components/badges/app_badge.dart';
import '../../components/feedback/empty_state.dart';

/// Screen for displaying memo details.
class MemoDetailScreen extends ConsumerWidget {
  /// The memo ID.
  final String id;

  /// Creates a MemoDetailScreen.
  const MemoDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final memoAsync = ref.watch(memoByIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? AppColorsDark.background : AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '备忘录详情',
          style: TextStyle(
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        actions: [
          memoAsync.when(
            data: (memo) {
              if (memo == null) return const SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pin toggle button
                  IconButton(
                    icon: Icon(
                      memo.pinned ? LucideIcons.pinOff : LucideIcons.pin,
                      color: memo.pinned
                          ? (isDark ? AppColorsDark.primary : AppColors.primary)
                          : (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground),
                    ),
                    onPressed: () => _togglePin(ref, memo.id),
                    tooltip: memo.pinned ? '取消置顶' : '置顶',
                  ),
                  // Edit button
                  IconButton(
                    icon: Icon(
                      LucideIcons.edit,
                      color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                    ),
                    onPressed: () => _navigateToEdit(context, memo.id),
                    tooltip: '编辑',
                  ),
                  // Delete button
                  IconButton(
                    icon: Icon(
                      LucideIcons.trash2,
                      color: isDark ? AppColorsDark.destructive : AppColors.destructive,
                    ),
                    onPressed: () => _confirmDelete(context, ref, memo.id, memo.title),
                    tooltip: '删除',
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: memoAsync.when(
        data: (memo) {
          if (memo == null) {
            return const EmptyState(
              message: '备忘录不存在',
              description: '该备忘录可能已被删除',
              icon: LucideIcons.fileX,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Category and pin status
                Row(
                  children: [
                    AppBadge(
                      label: memo.category,
                      color: _getCategoryColor(memo.category),
                      backgroundColor: _getCategoryColor(memo.category).withOpacity(0.15),
                    ),
                    if (memo.pinned) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColorsDark.primary : AppColors.primary)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.pin,
                              size: 12,
                              color: isDark ? AppColorsDark.primary : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '置顶',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColorsDark.primary : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  memo.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Timestamps
                Row(
                  children: [
                    Icon(
                      LucideIcons.calendarDays,
                      size: 14,
                      color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '创建于 ${_formatDate(memo.createdAt)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      LucideIcons.clock,
                      size: 14,
                      color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '更新于 ${_formatDate(memo.updatedAt)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Divider
                Divider(
                  color: isDark ? AppColorsDark.border : AppColors.border,
                  height: 1,
                ),
                const SizedBox(height: 24),

                // Content
                if (memo.content.isEmpty)
                  Text(
                    '暂无内容',
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                    ),
                  )
                else
                  Text(
                    memo.content,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => EmptyState(
          message: '加载失败',
          description: e.toString(),
          icon: LucideIcons.alertCircle,
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, String memoId) {
    context.push('/apps/memo/$memoId/edit');
  }

  void _togglePin(WidgetRef ref, String memoId) {
    ref.read(memoListProvider().notifier).togglePin(memoId);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String memoId,
    String title,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '删除备忘录',
          style: TextStyle(
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        content: Text(
          '确定要删除「$title」吗？此操作无法撤销。',
          style: TextStyle(
            color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '取消',
              style: TextStyle(
                color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
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
      await ref.read(memoListProvider().notifier).delete(memoId);
      if (context.mounted) {
        context.pop();
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '工作':
        return AppColors.chart1;
      case '生活':
        return AppColors.accent;
      case '学习':
        return AppColors.chart3;
      default:
        return AppColors.mutedForeground;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    if (dateDay == today) {
      return '今天 $time';
    } else if (dateDay == today.subtract(const Duration(days: 1))) {
      return '昨天 $time';
    } else if (date.year == now.year) {
      return '${date.month}月${date.day}日 $time';
    } else {
      return '${date.year}年${date.month}月${date.day}日 $time';
    }
  }
}
