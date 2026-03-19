import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../providers/calendar_event_provider.dart';

/// 日历事件详情页面
/// 显示事件详情并提供跳转到对应模块的功能
class CalendarEventScreen extends ConsumerWidget {
  final String id;

  const CalendarEventScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventDetailAsync = ref.watch(calendarEventDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('事件详情'),
      ),
      body: eventDetailAsync.when(
        data: (detail) {
          if (detail == null) {
            return _buildNotFound(context, isDark);
          }
          return _buildContent(context, ref, detail, isDark);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, isDark),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    CalendarEventDetail detail,
    bool isDark,
  ) {
    final eventColor = getEventColor(detail.type, isDark: isDark);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 事件标题卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColorsDark.card : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: eventColor,
                  width: 4,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 类型标签
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: eventColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    detail.typeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: eventColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 标题
                Text(
                  detail.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                    decoration:
                        detail.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (detail.category != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    detail.category!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 日期信息
          _buildInfoRow(
            context,
            isDark: isDark,
            icon: LucideIcons.calendar,
            label: '日期',
            value: _formatDate(detail.date),
          ),

          const SizedBox(height: 12),

          // 状态信息 (仅待办)
          if (detail.type == CalendarEventType.todo)
            _buildInfoRow(
              context,
              isDark: isDark,
              icon: detail.isCompleted
                  ? LucideIcons.checkCircle2
                  : LucideIcons.circle,
              label: '状态',
              value: detail.isCompleted ? '已完成' : '待完成',
              valueColor:
                  detail.isCompleted ? AppColors.accent : AppColors.chart3,
            ),

          // 描述内容
          if (detail.description != null && detail.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDescriptionSection(context, detail.description!, isDark),
          ],

          // 额外信息
          if (detail.extra.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildExtraInfo(context, detail, isDark),
          ],

          const SizedBox(height: 32),

          // 跳转按钮
          _buildNavigationButton(context, detail, isDark, eventColor),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.card : AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColorsDark.primary : AppColors.primary,
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
      ),
    );
  }

  Widget _buildDescriptionSection(
    BuildContext context,
    String description,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.card : AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.alignLeft,
                size: 18,
                color: isDark ? AppColorsDark.primary : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '详情',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraInfo(
    BuildContext context,
    CalendarEventDetail detail,
    bool isDark,
  ) {
    final List<Widget> items = [];

    // 日记额外信息
    if (detail.type == CalendarEventType.diary) {
      if (detail.extra['mood'] != null) {
        items.add(_buildExtraItem(
          context,
          isDark: isDark,
          icon: LucideIcons.smile,
          label: '心情',
          value: detail.extra['mood'],
        ));
      }
      if (detail.extra['weather'] != null) {
        items.add(_buildExtraItem(
          context,
          isDark: isDark,
          icon: LucideIcons.cloud,
          label: '天气',
          value: detail.extra['weather'],
        ));
      }
    }

    // 倒数日额外信息
    if (detail.type == CalendarEventType.countdown) {
      if (detail.extra['repeatYearly'] == true) {
        items.add(_buildExtraItem(
          context,
          isDark: isDark,
          icon: LucideIcons.repeat,
          label: '重复',
          value: '每年重复',
        ));
      }
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.card : AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildExtraItem(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? AppColorsDark.primary : AppColors.primary,
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
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    CalendarEventDetail detail,
    bool isDark,
    Color eventColor,
  ) {
    String buttonText;
    IconData buttonIcon;
    VoidCallback onPressed;

    switch (detail.type) {
      case CalendarEventType.todo:
        buttonText = '在待办中查看';
        buttonIcon = LucideIcons.checkSquare;
        onPressed = () => context.push(Routes.todo);
        break;
      case CalendarEventType.diary:
        buttonText = '查看日记详情';
        buttonIcon = LucideIcons.bookOpen;
        onPressed = () => context.push(Routes.diaryDetail(detail.id));
        break;
      case CalendarEventType.countdown:
        buttonText = '在倒数日中查看';
        buttonIcon = LucideIcons.calendarHeart;
        onPressed = () => context.push(Routes.countdown);
        break;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(buttonIcon, size: 18),
        label: Text(buttonText),
        style: ElevatedButton.styleFrom(
          backgroundColor: eventColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.searchX,
            size: 64,
            color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
          ),
          const SizedBox(height: 16),
          Text(
            '未找到事件',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '该事件可能已被删除',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColorsDark.mutedForeground
                  : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 64,
            color: AppColors.destructive,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请稍后重试',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColorsDark.mutedForeground
                  : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    final diff = dateDay.difference(today).inDays;

    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    final weekDay = weekDays[date.weekday % 7];

    String prefix = '';
    if (diff == 0) {
      prefix = '今天 ';
    } else if (diff == 1) {
      prefix = '明天 ';
    } else if (diff == -1) {
      prefix = '昨天 ';
    }

    return '$prefix${date.year}年${date.month}月${date.day}日 $weekDay';
  }
}
