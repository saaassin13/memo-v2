import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../providers/calendar_event_provider.dart';
import 'widgets/calendar_header.dart';
import 'widgets/day_view.dart';
import 'widgets/month_view.dart';
import 'widgets/week_view.dart';

/// 日历主页面
/// 支持日/周/月三种视图模式
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  /// 当前选中的日期
  DateTime _selectedDate = DateTime.now();

  /// 当前视图模式
  CalendarViewMode _viewMode = CalendarViewMode.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 头部：标题和视图切换
            CalendarHeader(
              viewMode: _viewMode,
              onViewModeChanged: (mode) {
                setState(() {
                  _viewMode = mode;
                });
              },
            ),
            // 内容区域
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // 根据视图模式获取对应的日期范围
    final dateRange = _getDateRange();

    // 监听事件数据
    final eventsAsync = ref.watch(
      calendarEventsProvider(
        startDate: dateRange.start,
        endDate: dateRange.end,
      ),
    );

    return eventsAsync.when(
      data: (events) => _buildView(events),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.invalidate(calendarEventsProvider(
                  startDate: dateRange.start,
                  endDate: dateRange.end,
                ));
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  /// 根据视图模式获取日期范围
  ({DateTime start, DateTime end}) _getDateRange() {
    switch (_viewMode) {
      case CalendarViewMode.day:
        // 日视图：当天
        final start = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
        );
        final end = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          23,
          59,
          59,
        );
        return (start: start, end: end);

      case CalendarViewMode.week:
        // 周视图：当周（周日开始）
        final weekday = _selectedDate.weekday % 7;
        final start = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day - weekday,
        );
        final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return (start: start, end: end);

      case CalendarViewMode.month:
        // 月视图：当月
        final start = DateTime(_selectedDate.year, _selectedDate.month, 1);
        final end = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
        return (start: start, end: end);
    }
  }

  Widget _buildView(List<CalendarEvent> events) {
    switch (_viewMode) {
      case CalendarViewMode.day:
        return DayView(
          selectedDate: _selectedDate,
          events: events,
          onDateChanged: _onDateChanged,
          onEventTap: _onEventTap,
        );

      case CalendarViewMode.week:
        return WeekView(
          selectedDate: _selectedDate,
          events: events,
          onDateChanged: _onDateChanged,
          onEventTap: _onEventTap,
        );

      case CalendarViewMode.month:
        return MonthView(
          selectedDate: _selectedDate,
          events: events,
          onDateChanged: _onDateChanged,
          onEventTap: _onEventTap,
        );
    }
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onEventTap(CalendarEvent event) {
    context.push(Routes.calendarEvent(event.id));
  }
}
