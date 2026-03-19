import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../../providers/calendar_event_provider.dart';

/// 日视图组件
/// 显示单日的详细事件列表
class DayView extends StatelessWidget {
  const DayView({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.onDateChanged,
    this.onEventTap,
  });

  /// 当前选中的日期
  final DateTime selectedDate;

  /// 当日事件列表
  final List<CalendarEvent> events;

  /// 日期选择回调
  final ValueChanged<DateTime> onDateChanged;

  /// 事件点击回调
  final ValueChanged<CalendarEvent>? onEventTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 日期导航
        _buildDateNavigator(context),
        // 分割线
        const Divider(height: 1),
        // 事件列表
        Expanded(
          child: _buildEventList(context),
        ),
      ],
    );
  }

  Widget _buildDateNavigator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    // 计算与今天的差距
    final diff = selectedDay.difference(today).inDays;
    String relativeLabel = '';
    if (diff == 0) {
      relativeLabel = '今天';
    } else if (diff == 1) {
      relativeLabel = '明天';
    } else if (diff == -1) {
      relativeLabel = '昨天';
    } else if (diff > 0) {
      relativeLabel = '$diff 天后';
    } else {
      relativeLabel = '${-diff} 天前';
    }

    // 星期几
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    final weekDay = weekDays[selectedDate.weekday % 7];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 导航控制
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  LucideIcons.chevronLeft,
                  size: 20,
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
                onPressed: () => _navigateDay(-1),
              ),
              GestureDetector(
                onTap: () => _goToToday(),
                child: Column(
                  children: [
                    // 日期
                    Text(
                      '${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? AppColorsDark.foreground : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 星期 + 相对日期
                    Text(
                      '$weekDay $relativeLabel',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColorsDark.mutedForeground
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
                onPressed: () => _navigateDay(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateDay(int delta) {
    final newDate = selectedDate.add(Duration(days: delta));
    onDateChanged(newDate);
  }

  void _goToToday() {
    onDateChanged(DateTime.now());
  }

  Widget _buildEventList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayEvents = events.where((e) => _isSameDay(e.date, selectedDate)).toList();

    if (dayEvents.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    // 按类型分组
    final todoEvents =
        dayEvents.where((e) => e.type == CalendarEventType.todo).toList();
    final diaryEvents =
        dayEvents.where((e) => e.type == CalendarEventType.diary).toList();
    final countdownEvents =
        dayEvents.where((e) => e.type == CalendarEventType.countdown).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 待办事项
        if (todoEvents.isNotEmpty) ...[
          _buildSectionHeader(context, '待办事项', todoEvents.length, isDark),
          const SizedBox(height: 8),
          ...todoEvents.map((e) => _DayEventCard(
                event: e,
                isDark: isDark,
                onTap: onEventTap != null ? () => onEventTap!(e) : null,
              )),
          const SizedBox(height: 16),
        ],
        // 日记
        if (diaryEvents.isNotEmpty) ...[
          _buildSectionHeader(context, '日记', diaryEvents.length, isDark),
          const SizedBox(height: 8),
          ...diaryEvents.map((e) => _DayEventCard(
                event: e,
                isDark: isDark,
                onTap: onEventTap != null ? () => onEventTap!(e) : null,
              )),
          const SizedBox(height: 16),
        ],
        // 倒数日
        if (countdownEvents.isNotEmpty) ...[
          _buildSectionHeader(context, '倒数日', countdownEvents.length, isDark),
          const SizedBox(height: 8),
          ...countdownEvents.map((e) => _DayEventCard(
                event: e,
                isDark: isDark,
                onTap: onEventTap != null ? () => onEventTap!(e) : null,
              )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, int count, bool isDark) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.muted : AppColors.muted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColorsDark.mutedForeground
                  : AppColors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (isDark ? AppColorsDark.muted : AppColors.muted)
                  .withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.calendarOff,
              size: 36,
              color:
                  isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '这一天没有安排',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '享受轻松的一天吧',
            style: TextStyle(
              fontSize: 14,
              color:
                  isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// 日视图事件卡片
class _DayEventCard extends StatelessWidget {
  const _DayEventCard({
    required this.event,
    required this.isDark,
    this.onTap,
  });

  final CalendarEvent event;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final eventColor = getEventColor(event.type, isDark: isDark);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.card : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColorsDark.border : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 左侧颜色指示
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: eventColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            // 内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColorsDark.foreground
                          : AppColors.foreground,
                      decoration: event.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // 类型标签和副标题
                  Row(
                    children: [
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
                          event.typeLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: eventColor,
                          ),
                        ),
                      ),
                      if (event.subtitle != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.subtitle!,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColorsDark.mutedForeground
                                  : AppColors.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 箭头图标
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: isDark
                  ? AppColorsDark.mutedForeground
                  : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
