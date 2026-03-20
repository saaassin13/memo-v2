import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/theme/colors.dart';
import '../data/database/app_database.dart';
import '../ui/screens/diary/widgets/mood_selector.dart';
import '../ui/screens/diary/widgets/weather_selector.dart';
import 'countdown_provider.dart';
import 'diary_provider.dart';
import 'todo_provider.dart';

part 'calendar_event_provider.g.dart';

/// 日历事件类型
enum CalendarEventType {
  todo,
  diary,
  countdown,
}

/// 日历事件模型
class CalendarEvent {
  final String id;
  final CalendarEventType type;
  final String title;
  final DateTime date;
  final Color color;
  final String? subtitle;
  final bool isCompleted;

  const CalendarEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.color,
    this.subtitle,
    this.isCompleted = false,
  });

  /// 获取原始 ID (去除类型前缀)
  String get originalId {
    final parts = id.split('_');
    if (parts.length > 1) {
      return parts.sublist(1).join('_');
    }
    return id;
  }

  /// 获取类型显示名称
  String get typeLabel {
    switch (type) {
      case CalendarEventType.todo:
        return '待办';
      case CalendarEventType.diary:
        return '日记';
      case CalendarEventType.countdown:
        return '倒数日';
    }
  }
}

/// 获取事件颜色的辅助方法
Color getEventColor(CalendarEventType type, {bool isDark = false}) {
  switch (type) {
    case CalendarEventType.todo:
      return isDark ? AppColorsDark.primary : AppColors.primary;
    case CalendarEventType.diary:
      return isDark ? AppColorsDark.accent : AppColors.accent;
    case CalendarEventType.countdown:
      return isDark ? AppColorsDark.chart4 : AppColors.chart4;
  }
}

/// 日历事件 Provider - 按日期范围获取事件
@riverpod
Future<List<CalendarEvent>> calendarEvents(
  Ref ref, {
  required DateTime startDate,
  required DateTime endDate,
}) async {
  final todoRepo = ref.watch(todoRepositoryProvider);
  final diaryRepo = ref.watch(diaryRepositoryProvider);
  final countdownRepo = ref.watch(countdownRepositoryProvider);

  final events = <CalendarEvent>[];

  // 获取日期范围内的待办
  final allTodos = await todoRepo.getAll();
  for (final todo in allTodos) {
    if (todo.dueDate != null) {
      final dueDate = todo.dueDate!;
      if (!dueDate.isBefore(startDate) && !dueDate.isAfter(endDate)) {
        events.add(CalendarEvent(
          id: 'todo_${todo.id}',
          type: CalendarEventType.todo,
          title: todo.title,
          date: dueDate,
          color: AppColors.primary,
          subtitle: todo.category,
          isCompleted: todo.completed,
        ));
      }
    }
  }

  // 获取日期范围内的日记
  // 遍历日期范围内的每个月
  var current = DateTime(startDate.year, startDate.month, 1);
  while (current.isBefore(endDate) || current.month == endDate.month && current.year == endDate.year) {
    final diaries = await diaryRepo.getByMonth(current.year, current.month);
    for (final diary in diaries) {
      if (!diary.date.isBefore(startDate) && !diary.date.isAfter(endDate)) {
        events.add(CalendarEvent(
          id: 'diary_${diary.id}',
          type: CalendarEventType.diary,
          title: diary.title.isNotEmpty ? diary.title : '日记',
          date: diary.date,
          color: AppColors.accent,
          subtitle: Mood.fromValue(diary.mood)?.emoji ?? diary.mood,
        ));
      }
    }
    current = DateTime(current.year, current.month + 1, 1);
  }

  // 获取倒数日
  final allCountdowns = await countdownRepo.getAll();
  for (final countdown in allCountdowns) {
    final targetDate = countdown.targetDate;

    // 如果是周年重复的纪念日，计算当年的日期
    if (countdown.repeatYearly) {
      // 计算在日期范围内的周年日期
      for (int year = startDate.year; year <= endDate.year; year++) {
        final yearlyDate = DateTime(year, targetDate.month, targetDate.day);
        if (!yearlyDate.isBefore(startDate) && !yearlyDate.isAfter(endDate)) {
          events.add(CalendarEvent(
            id: 'countdown_${countdown.id}_$year',
            type: CalendarEventType.countdown,
            title: countdown.title,
            date: yearlyDate,
            color: AppColors.chart4,
            subtitle: countdown.type == 'anniversary' ? '纪念日' : '倒数日',
          ));
        }
      }
    } else {
      // 普通倒数日
      if (!targetDate.isBefore(startDate) && !targetDate.isAfter(endDate)) {
        events.add(CalendarEvent(
          id: 'countdown_${countdown.id}',
          type: CalendarEventType.countdown,
          title: countdown.title,
          date: targetDate,
          color: AppColors.chart4,
          subtitle: countdown.type == 'anniversary' ? '纪念日' : '倒数日',
        ));
      }
    }
  }

  // 按日期排序
  events.sort((a, b) => a.date.compareTo(b.date));

  return events;
}

/// 按月份获取日历事件
@riverpod
Future<List<CalendarEvent>> calendarEventsByMonth(
  Ref ref, {
  required int year,
  required int month,
}) async {
  final startDate = DateTime(year, month, 1);
  final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

  return ref.watch(calendarEventsProvider(
    startDate: startDate,
    endDate: endDate,
  ).future);
}

/// 按周获取日历事件
@riverpod
Future<List<CalendarEvent>> calendarEventsByWeek(
  Ref ref, {
  required DateTime weekStart,
}) async {
  final startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
  final endDate = startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

  return ref.watch(calendarEventsProvider(
    startDate: startDate,
    endDate: endDate,
  ).future);
}

/// 按日期获取日历事件
@riverpod
Future<List<CalendarEvent>> calendarEventsByDate(
  Ref ref, {
  required DateTime date,
}) async {
  final startDate = DateTime(date.year, date.month, date.day);
  final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

  return ref.watch(calendarEventsProvider(
    startDate: startDate,
    endDate: endDate,
  ).future);
}

/// 获取单个日历事件详情
@riverpod
Future<CalendarEventDetail?> calendarEventDetail(
  Ref ref,
  String eventId,
) async {
  final parts = eventId.split('_');
  if (parts.isEmpty) return null;

  final type = parts[0];
  final originalId = parts.length > 1 ? parts.sublist(1).join('_') : '';

  // 移除可能的年份后缀 (用于重复的周年纪念日)
  final idParts = originalId.split('_');
  String cleanId = originalId;
  if (idParts.length > 1) {
    final lastPart = idParts.last;
    if (int.tryParse(lastPart) != null && lastPart.length == 4) {
      cleanId = idParts.sublist(0, idParts.length - 1).join('_');
    }
  }

  switch (type) {
    case 'todo':
      final todoRepo = ref.watch(todoRepositoryProvider);
      final todo = await todoRepo.getById(cleanId);
      if (todo != null) {
        return CalendarEventDetail.fromTodo(todo);
      }
      break;
    case 'diary':
      final diaryRepo = ref.watch(diaryRepositoryProvider);
      final diary = await diaryRepo.getById(cleanId);
      if (diary != null) {
        return CalendarEventDetail.fromDiary(diary);
      }
      break;
    case 'countdown':
      final countdownRepo = ref.watch(countdownRepositoryProvider);
      final countdown = await countdownRepo.getById(cleanId);
      if (countdown != null) {
        return CalendarEventDetail.fromCountdown(countdown);
      }
      break;
  }

  return null;
}

/// 日历事件详情模型
class CalendarEventDetail {
  final String id;
  final CalendarEventType type;
  final String title;
  final DateTime date;
  final String? description;
  final String? category;
  final bool isCompleted;
  final Map<String, dynamic> extra;

  const CalendarEventDetail({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    this.description,
    this.category,
    this.isCompleted = false,
    this.extra = const {},
  });

  factory CalendarEventDetail.fromTodo(Todo todo) {
    return CalendarEventDetail(
      id: todo.id,
      type: CalendarEventType.todo,
      title: todo.title,
      date: todo.dueDate ?? DateTime.now(),
      description: todo.note,
      category: todo.category,
      isCompleted: todo.completed,
      extra: {
        'createdAt': todo.createdAt,
        'updatedAt': todo.updatedAt,
      },
    );
  }

  factory CalendarEventDetail.fromDiary(DiaryEntry diary) {
    return CalendarEventDetail(
      id: diary.id,
      type: CalendarEventType.diary,
      title: diary.title.isNotEmpty ? diary.title : '日记',
      date: diary.date,
      description: diary.content,
      extra: {
        'mood': Mood.fromValue(diary.mood)?.emoji ?? diary.mood,
        'weather': Weather.fromValue(diary.weather)?.label ?? diary.weather,
        'images': diary.images,
        'createdAt': diary.createdAt,
        'updatedAt': diary.updatedAt,
      },
    );
  }

  factory CalendarEventDetail.fromCountdown(Countdown countdown) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      countdown.targetDate.year,
      countdown.targetDate.month,
      countdown.targetDate.day,
    );
    final diff = targetDate.difference(today).inDays;

    String description;
    if (diff > 0) {
      description = '还有 $diff 天';
    } else if (diff < 0) {
      description = '已过 ${-diff} 天';
    } else {
      description = '就是今天';
    }

    return CalendarEventDetail(
      id: countdown.id,
      type: CalendarEventType.countdown,
      title: countdown.title,
      date: countdown.targetDate,
      description: description,
      category: countdown.type == 'anniversary' ? '纪念日' : '倒数日',
      extra: {
        'repeatYearly': countdown.repeatYearly,
        'icon': countdown.icon,
        'color': countdown.color,
        'createdAt': countdown.createdAt,
        'updatedAt': countdown.updatedAt,
      },
    );
  }

  /// 获取类型显示名称
  String get typeLabel {
    switch (type) {
      case CalendarEventType.todo:
        return '待办';
      case CalendarEventType.diary:
        return '日记';
      case CalendarEventType.countdown:
        return '倒数日';
    }
  }
}
