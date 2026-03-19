import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/colors.dart';
import '../../../providers/diary_provider.dart';
import '../../components/buttons/app_button.dart';
import '../../components/feedback/empty_state.dart';
import 'widgets/mood_selector.dart';
import 'widgets/weather_selector.dart';

/// Screen for displaying diary detail.
class DiaryDetailScreen extends ConsumerWidget {
  /// The diary ID.
  final String id;

  /// Creates a DiaryDetailScreen.
  const DiaryDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final diaryAsync = ref.watch(diaryByIdProvider(id));

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
          '日记详情',
          style: TextStyle(
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        actions: [
          // Edit button
          IconButton(
            icon: Icon(
              LucideIcons.pencil,
              color: isDark ? AppColorsDark.primary : AppColors.primary,
            ),
            onPressed: () => context.push('/apps/diary/$id/edit'),
          ),
          // Delete button
          IconButton(
            icon: Icon(
              LucideIcons.trash2,
              color: isDark ? AppColorsDark.destructive : AppColors.destructive,
            ),
            onPressed: () => _confirmDelete(context, ref, isDark),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: diaryAsync.when(
        data: (diary) {
          if (diary == null) {
            return CommonEmptyStates.error(
              message: '日记不存在',
              action: AppButton(
                label: '返回',
                variant: ButtonVariant.secondary,
                onPressed: () => context.pop(),
              ),
            );
          }

          final weather = Weather.fromValue(diary.weather);
          final mood = Mood.fromValue(diary.mood);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Date display
              _buildDateDisplay(context, isDark, diary.date),
              const SizedBox(height: 24),

              // Weather and Mood row
              Row(
                children: [
                  // Weather
                  if (weather != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColorsDark.card : AppColors.card),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColorsDark.border : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            weather.icon,
                            size: 16,
                            color: _getWeatherColor(weather, isDark),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            weather.label,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColorsDark.foreground
                                  : AppColors.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  // Mood
                  if (mood != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColorsDark.card : AppColors.card),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColorsDark.border : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            mood.emoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mood.label,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColorsDark.foreground
                                  : AppColors.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Title (if exists)
              if (diary.title.isNotEmpty) ...[
                Text(
                  diary.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Content
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColorsDark.card : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  diary.content,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.8,
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Timestamps
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDark ? AppColorsDark.muted : AppColors.muted)
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 14,
                          color: isDark
                              ? AppColorsDark.mutedForeground
                              : AppColors.mutedForeground,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '创建于 ${_formatDateTime(diary.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColorsDark.mutedForeground
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                    if (diary.updatedAt != diary.createdAt) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.pencil,
                            size: 14,
                            color: isDark
                                ? AppColorsDark.mutedForeground
                                : AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '更新于 ${_formatDateTime(diary.updatedAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColorsDark.mutedForeground
                                  : AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => CommonEmptyStates.error(
          message: '加载失败: $e',
          action: AppButton(
            label: '重试',
            variant: ButtonVariant.secondary,
            onPressed: () => ref.invalidate(diaryByIdProvider(id)),
          ),
        ),
      ),
    );
  }

  Widget _buildDateDisplay(BuildContext context, bool isDark, DateTime date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColorsDark.primary : AppColors.primary)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.calendar,
            color: isDark ? AppColorsDark.primary : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('yyyy年M月d日 EEEE', 'zh_CN').format(date),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColorsDark.primary : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getWeatherColor(Weather weather, bool isDark) {
    switch (weather) {
      case Weather.sunny:
        return const Color(0xFFF59E0B); // Amber
      case Weather.cloudy:
        return isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground;
      case Weather.rainy:
        return const Color(0xFF3B82F6); // Blue
      case Weather.snowy:
        return const Color(0xFF06B6D4); // Cyan
      case Weather.thunder:
        return const Color(0xFF8B5CF6); // Purple
      case Weather.windy:
        return const Color(0xFF10B981); // Green
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy年M月d日 HH:mm').format(dateTime);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, bool isDark) async {
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

    if (confirmed == true && context.mounted) {
      final now = DateTime.now();
      ref
          .read(diaryListProvider(year: now.year, month: now.month).notifier)
          .delete(id);
      context.pop();
    }
  }
}
