import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../../providers/calendar_event_provider.dart';

/// 周视图组件
/// 显示一周的事件
class WeekView extends StatelessWidget {
  const WeekView({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.onDateChanged,
    this.onEventTap,
  });

  /// 当前选中的日期
  final DateTime selectedDate;

  /// 当前周的事件列表
  final List<CalendarEvent> events;

  /// 日期选择回调
  final ValueChanged<DateTime> onDateChanged;

  /// 事件点击回调
  final ValueChanged<CalendarEvent>? onEventTap;

  static const _weekDays = ['日', '一', '二', '三', '四', '五', '六'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 周导航
        _buildWeekNavigator(context),
        // 周天数显示
        _buildWeekDays(context),
        // 分割线
        const Divider(height: 1),
        // 事件列表
        Expanded(
          child: _buildEventList(context),
        ),
      ],
    );
  }

  /// 获取当前周的起始日期 (周日开始)
  DateTime get _weekStart {
    final weekday = selectedDate.weekday % 7;
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day - weekday,
    );
  }

  /// 获取当前周的结束日期
  DateTime get _weekEnd {
    return _weekStart.add(const Duration(days: 6));
  }

  Widget _buildWeekNavigator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final start = _weekStart;
    final end = _weekEnd;

    // 格式化周范围显示
    String weekLabel;
    if (start.month == end.month) {
      weekLabel = '${start.year}年${start.month}月${start.day}日 - ${end.day}日';
    } else if (start.year == end.year) {
      weekLabel =
          '${start.year}年${start.month}月${start.day}日 - ${end.month}月${end.day}日';
    } else {
      weekLabel =
          '${start.year}年${start.month}月${start.day}日 - ${end.year}年${end.month}月${end.day}日';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              LucideIcons.chevronLeft,
              size: 20,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
            onPressed: () => _navigateWeek(-1),
          ),
          GestureDetector(
            onTap: () => _goToToday(),
            child: Text(
              weekLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColorsDark.foreground : AppColors.foreground,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
            onPressed: () => _navigateWeek(1),
          ),
        ],
      ),
    );
  }

  void _navigateWeek(int delta) {
    final newDate = selectedDate.add(Duration(days: delta * 7));
    onDateChanged(newDate);
  }

  void _goToToday() {
    onDateChanged(DateTime.now());
  }

  Widget _buildWeekDays(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = _weekStart;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: List.generate(7, (index) {
          final date = start.add(Duration(days: index));
          final isToday = _isSameDay(date, today);
          final isSelected = _isSameDay(date, selectedDate);
          final dayEvents = _getEventsForDate(date);

          return Expanded(
            child: GestureDetector(
              onTap: () => onDateChanged(date),
              child: Column(
                children: [
                  // 周几
                  Text(
                    _weekDays[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 日期数字
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColorsDark.primary : AppColors.primary)
                          : null,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(
                              color: isDark
                                  ? AppColorsDark.primary
                                  : AppColors.primary,
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColorsDark.foreground
                                  : AppColors.foreground),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 事件指示点
                  SizedBox(
                    height: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: dayEvents.take(3).map((e) {
                        return Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: getEventColor(e.type, isDark: isDark),
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEventList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayEvents = _getEventsForDate(selectedDate);

    // 格式化日期标题
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    String dateTitle;
    if (_isSameDay(selectedDay, today)) {
      dateTitle = '今天';
    } else if (_isSameDay(selectedDay, today.add(const Duration(days: 1)))) {
      dateTitle = '明天';
    } else if (_isSameDay(selectedDay, today.subtract(const Duration(days: 1)))) {
      dateTitle = '昨天';
    } else {
      dateTitle = '${selectedDate.month}月${selectedDate.day}日';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期标题
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '$dateTitle 事件',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
        ),
        // 事件列表
        Expanded(
          child: dayEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.calendarOff,
                        size: 48,
                        color: isDark
                            ? AppColorsDark.mutedForeground
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '这一天没有安排',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColorsDark.mutedForeground
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dayEvents.length,
                  itemBuilder: (context, index) {
                    final event = dayEvents[index];
                    return _WeekEventCard(
                      event: event,
                      isDark: isDark,
                      onTap: onEventTap != null ? () => onEventTap!(event) : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<CalendarEvent> _getEventsForDate(DateTime date) {
    return events.where((e) => _isSameDay(e.date, date)).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// 周视图事件卡片
class _WeekEventCard extends StatelessWidget {
  const _WeekEventCard({
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.card : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: eventColor,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          isDark ? AppColorsDark.foreground : AppColors.foreground,
                      decoration:
                          event.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // 副标题和类型
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: eventColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.typeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: eventColor,
                          ),
                        ),
                      ),
                      if (event.subtitle != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          event.subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColorsDark.mutedForeground
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // 箭头图标
            Icon(
              LucideIcons.chevronRight,
              size: 16,
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
