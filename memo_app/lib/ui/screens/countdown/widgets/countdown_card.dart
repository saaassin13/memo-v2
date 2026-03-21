import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../../data/database/app_database.dart';

/// Helper class for countdown calculations.
class CountdownHelper {
  CountdownHelper._();

  /// Calculate days difference between target date and today.
  /// Positive = future (countdown), Negative = past (count-up).
  static int calculateDays(DateTime targetDate, {bool repeatYearly = false}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime target = DateTime(targetDate.year, targetDate.month, targetDate.day);

    if (repeatYearly) {
      // For yearly repeat, find the next occurrence
      target = _getNextOccurrence(targetDate, today);
    }

    return target.difference(today).inDays;
  }

  /// Get the next occurrence of a yearly repeating date.
  static DateTime _getNextOccurrence(DateTime originalDate, DateTime today) {
    // Try this year first
    DateTime thisYear = DateTime(today.year, originalDate.month, originalDate.day);

    // Handle Feb 29 for non-leap years
    if (originalDate.month == 2 && originalDate.day == 29) {
      if (!_isLeapYear(today.year)) {
        thisYear = DateTime(today.year, 2, 28);
      }
    }

    // If this year's date has passed, use next year
    if (thisYear.isBefore(today)) {
      int nextYear = today.year + 1;
      if (originalDate.month == 2 && originalDate.day == 29) {
        // Find the next leap year
        while (!_isLeapYear(nextYear)) {
          nextYear++;
        }
        return DateTime(nextYear, 2, 29);
      }
      return DateTime(nextYear, originalDate.month, originalDate.day);
    }

    return thisYear;
  }

  /// Check if a year is a leap year.
  static bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  }

  /// Get display text for days difference.
  static String getDaysText(int days) {
    if (days == 0) {
      return '今天';
    } else if (days > 0) {
      return '还有 $days 天';
    } else {
      return '已过 ${-days} 天';
    }
  }

  /// Get years since original date (for anniversaries).
  static int getYearsSince(DateTime originalDate) {
    final now = DateTime.now();
    int years = now.year - originalDate.year;
    if (DateTime(now.year, originalDate.month, originalDate.day).isAfter(now)) {
      years--;
    }
    return years > 0 ? years : 0;
  }
}

/// Category type for countdown items.
enum CountdownCategory {
  birthday('birthday', '生日', LucideIcons.cake, Color(0xFFEC4899)),
  festival('festival', '节日', LucideIcons.partyPopper, Color(0xFFF59E0B)),
  important('important', '重要日', LucideIcons.star, Color(0xFF4B7BEC));

  const CountdownCategory(this.value, this.label, this.icon, this.color);

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  static CountdownCategory fromString(String? value) {
    return CountdownCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CountdownCategory.important,
    );
  }
}

/// A card widget for displaying countdown item.
class CountdownCard extends StatelessWidget {
  /// Creates a CountdownCard.
  const CountdownCard({
    super.key,
    required this.countdown,
    this.onTap,
    this.onLongPress,
  });

  /// The countdown data to display.
  final Countdown countdown;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Called when the card is long pressed.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = CountdownCategory.fromString(countdown.type);
    final days = CountdownHelper.calculateDays(
      countdown.targetDate,
      repeatYearly: countdown.repeatYearly,
    );
    final daysText = CountdownHelper.getDaysText(days);
    final isToday = days == 0;
    final isPast = days < 0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.card : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday
                ? category.color.withOpacity(0.5)
                : (isDark ? AppColorsDark.border : AppColors.border),
            width: isToday ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category icon
            _buildCategoryIcon(category, isDark),
            const SizedBox(width: 16),
            // Title and date info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    countdown.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 14,
                        color: isDark
                            ? AppColorsDark.mutedForeground
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(countdown.targetDate),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColorsDark.mutedForeground
                              : AppColors.mutedForeground,
                        ),
                      ),
                      if (countdown.repeatYearly) ...[
                        const SizedBox(width: 8),
                        Icon(
                          LucideIcons.repeat,
                          size: 14,
                          color: isDark
                              ? AppColorsDark.mutedForeground
                              : AppColors.mutedForeground,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Days count
            _buildDaysCount(days, daysText, isToday, isPast, category, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(CountdownCategory category, bool isDark) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: category.color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        category.icon,
        size: 24,
        color: category.color,
      ),
    );
  }

  Widget _buildDaysCount(
    int days,
    String daysText,
    bool isToday,
    bool isPast,
    CountdownCategory category,
    bool isDark,
  ) {
    final absdays = days.abs();
    final displayDays = isToday ? '!' : absdays.toString();
    final Color textColor;

    if (isToday) {
      textColor = category.color;
    } else if (isPast) {
      textColor = isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground;
    } else if (days <= 7) {
      textColor = isDark ? AppColorsDark.destructive : AppColors.destructive;
    } else if (days <= 30) {
      textColor = const Color(0xFFF59E0B);
    } else {
      textColor = isDark ? AppColorsDark.foreground : AppColors.foreground;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displayDays,
          style: TextStyle(
            fontSize: isToday ? 28 : 32,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(
          isToday ? '今天' : (isPast ? '天前' : '天后'),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year) {
      return '${date.month}月${date.day}日';
    }
    return '${date.year}年${date.month}月${date.day}日';
  }
}
