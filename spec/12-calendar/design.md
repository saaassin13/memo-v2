# 12-calendar 设计文档

## 页面布局

### 月视图

```
┌─────────────────────────────────────┐
│  Header: 日历      [日] [周] [月]   │
├─────────────────────────────────────┤
│    [<]     2026年3月      [>]       │
├─────────────────────────────────────┤
│  日   一   二   三   四   五   六   │
│                           1    2    │
│   3    4    5    6    7   8    9    │
│  10   11   12   13   14  15   16    │
│  17   18●  19   20   21  22   23    │
│  24   25   26   27   28  29   30    │
│  31                                 │
├─────────────────────────────────────┤
│  3月19日 事件                       │
│  ┌─────────────────────────────────┐│
│  │ 团队会议 · 14:00                ││
│  │ Todo                            ││
│  └─────────────────────────────────┘│
├─────────────────────────────────────┤
│           Bottom Navigation          │
└─────────────────────────────────────┘
```

## CalendarScreen

```dart
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  String _viewMode = 'month'; // day, week, month

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(calendarEventsProvider(
      date: _selectedDate,
      viewMode: _viewMode,
    ));

    return Scaffold(
      body: Column(
        children: [
          CalendarHeader(
            viewMode: _viewMode,
            onViewModeChanged: (mode) => setState(() => _viewMode = mode),
          ),
          Expanded(
            child: eventsAsync.when(
              data: (events) => _buildView(events),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildView(List<CalendarEvent> events) {
    switch (_viewMode) {
      case 'day':
        return DayView(
          selectedDate: _selectedDate,
          events: events,
          onDateChanged: (date) => setState(() => _selectedDate = date),
          onEventTap: _onEventTap,
        );
      case 'week':
        return WeekView(
          selectedDate: _selectedDate,
          events: events,
          onDateChanged: (date) => setState(() => _selectedDate = date),
          onEventTap: _onEventTap,
        );
      default:
        return MonthView(
          selectedDate: _selectedDate,
          events: events,
          onDateChanged: (date) => setState(() => _selectedDate = date),
          onEventTap: _onEventTap,
        );
    }
  }

  void _onEventTap(CalendarEvent event) {
    context.push('/calendar/event/${event.id}');
  }
}
```

## MonthView

```dart
class MonthView extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarEvent> events;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<CalendarEvent>? onEventTap;

  const MonthView({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.onDateChanged,
    this.onEventTap,
  });

  static const _weekDays = ['日', '一', '二', '三', '四', '五', '六'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Month Navigator
        _buildMonthNavigator(context),
        // Week Day Headers
        _buildWeekDayHeaders(context),
        // Calendar Grid
        Expanded(
          child: _buildCalendarGrid(context),
        ),
        // Selected Date Events
        _buildEventList(context),
      ],
    );
  }

  Widget _buildMonthNavigator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft),
            onPressed: () => _navigateMonth(-1),
          ),
          Text(
            DateFormat('yyyy年M月', 'zh_CN').format(selectedDate),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronRight),
            onPressed: () => _navigateMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final days = _getMonthDays();
    final today = DateTime.now();

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: days.map((date) {
        if (date == null) return const SizedBox();

        final isToday = _isSameDay(date, today);
        final isSelected = _isSameDay(date, selectedDate);
        final dayEvents = _getEventsForDate(date);

        return GestureDetector(
          onTap: () => onDateChanged(date),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : isToday
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? Theme.of(context).colorScheme.primary
                            : null,
                    fontWeight: isToday || isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: dayEvents.take(3).map((e) => Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : _getEventColor(e),
                      shape: BoxShape.circle,
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
```

## CalendarEvent Provider

```dart
@riverpod
Future<List<CalendarEvent>> calendarEvents(
  CalendarEventsRef ref, {
  required DateTime date,
  required String viewMode,
}) async {
  final todos = await ref.watch(todoRepositoryProvider).getByDate(date);
  final diaries = await ref.watch(diaryRepositoryProvider).getByDate(date);
  final countdowns = await ref.watch(countdownRepositoryProvider).getUpcoming();

  final events = <CalendarEvent>[];

  for (final todo in todos) {
    events.add(CalendarEvent(
      id: 'todo_${todo.id}',
      type: 'todo',
      title: todo.title,
      date: todo.dueDate!,
      color: AppColors.primary,
    ));
  }

  for (final diary in diaries) {
    events.add(CalendarEvent(
      id: 'diary_${diary.id}',
      type: 'diary',
      title: '日记',
      date: diary.date,
      color: AppColors.accent,
    ));
  }

  // ... countdowns

  return events;
}
```
