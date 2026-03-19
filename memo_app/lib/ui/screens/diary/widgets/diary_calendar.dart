import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';

/// A calendar widget for diary navigation with month selection and date indicators.
class DiaryCalendar extends StatelessWidget {
  /// Creates a DiaryCalendar.
  const DiaryCalendar({
    super.key,
    required this.selectedDate,
    required this.currentMonth,
    required this.datesWithEntries,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  /// The currently selected date.
  final DateTime selectedDate;

  /// The current month being displayed.
  final DateTime currentMonth;

  /// List of dates that have diary entries.
  final List<DateTime> datesWithEntries;

  /// Called when a date is selected.
  final ValueChanged<DateTime> onDateSelected;

  /// Called when the month changes.
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.card : AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Month navigation header
          _buildMonthHeader(context, isDark),
          const SizedBox(height: 16),
          // Weekday headers
          _buildWeekdayHeaders(context, isDark),
          const SizedBox(height: 8),
          // Calendar grid
          _buildCalendarGrid(context, isDark),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            LucideIcons.chevronLeft,
            size: 20,
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
          onPressed: () {
            final previousMonth = DateTime(
              currentMonth.year,
              currentMonth.month - 1,
              1,
            );
            onMonthChanged(previousMonth);
          },
        ),
        const SizedBox(width: 16),
        Text(
          '${currentMonth.year}年${currentMonth.month}月',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: Icon(
            LucideIcons.chevronRight,
            size: 20,
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
          onPressed: () {
            final nextMonth = DateTime(
              currentMonth.year,
              currentMonth.month + 1,
              1,
            );
            onMonthChanged(nextMonth);
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context, bool isDark) {
    const weekdays = ['日', '一', '二', '三', '四', '五', '六'];

    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColorsDark.mutedForeground
                    : AppColors.mutedForeground,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, bool isDark) {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    // Calculate total cells needed
    final totalCells = ((daysInMonth + firstWeekday) / 7).ceil() * 7;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayNumber = index - firstWeekday + 1;

        // Empty cell for days before first day of month
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(currentMonth.year, currentMonth.month, dayNumber);
        final isSelected = _isSameDay(date, selectedDate);
        final isToday = _isSameDay(date, today);
        final hasEntry = _hasEntryOnDate(date);

        return GestureDetector(
          onTap: () => onDateSelected(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppColorsDark.primary : AppColors.primary)
                  : null,
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected
                  ? Border.all(
                      color: isDark ? AppColorsDark.primary : AppColors.primary,
                      width: 1.5,
                    )
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  dayNumber.toString(),
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
                // Diary indicator dot
                if (hasEntry && !isSelected)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColorsDark.primary : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _hasEntryOnDate(DateTime date) {
    return datesWithEntries.any((d) => _isSameDay(d, date));
  }
}
