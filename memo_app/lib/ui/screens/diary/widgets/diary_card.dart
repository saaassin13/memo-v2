import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../../data/database/app_database.dart';
import '../../../components/dialogs/app_dropdown_menu.dart';
import 'weather_selector.dart';
import 'mood_selector.dart';

/// A card component for displaying diary entries.
class DiaryCard extends StatelessWidget {
  /// Creates a DiaryCard.
  const DiaryCard({
    super.key,
    required this.diary,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showDate = true,
  });

  /// The diary entry to display.
  final DiaryEntry diary;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Called when edit is selected.
  final VoidCallback? onEdit;

  /// Called when delete is selected.
  final VoidCallback? onDelete;

  /// Whether to show the date in the card.
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weather = Weather.fromValue(diary.weather);
    final mood = Mood.fromValue(diary.mood);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.card : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with weather, mood, date, and more button
            Row(
              children: [
                // Weather icon
                if (weather != null) ...[
                  Icon(
                    weather.icon,
                    size: 18,
                    color: _getWeatherColor(weather, isDark),
                  ),
                  const SizedBox(width: 8),
                ],
                // Mood emoji
                if (mood != null) ...[
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
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
                const Spacer(),
                // Date
                if (showDate)
                  Text(
                    _formatDate(diary.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                  ),
                // More button
                if (onEdit != null || onDelete != null) ...[
                  const SizedBox(width: 8),
                  _buildMoreButton(context),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Title (if not empty)
            if (diary.title.isNotEmpty) ...[
              Text(
                diary.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],
            // Content preview
            Text(
              diary.content,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColorsDark.mutedForeground
                    : AppColors.mutedForeground,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Builder(
      builder: (context) => GestureDetector(
        onTapDown: (details) => _showMenu(context, details.globalPosition),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            LucideIcons.moreHorizontal,
            size: 18,
            color: isDark
                ? AppColorsDark.mutedForeground
                : AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    AppDropdownMenu.show(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(position, position),
        Offset.zero & overlay.size,
      ),
      items: [
        if (onEdit != null)
          AppMenuItem(
            label: '编辑',
            icon: LucideIcons.pencil,
            onTap: onEdit,
          ),
        if (onEdit != null && onDelete != null) AppMenuItem.divider,
        if (onDelete != null)
          AppMenuItem(
            label: '删除',
            icon: LucideIcons.trash2,
            onTap: onDelete,
            isDestructive: true,
          ),
      ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return '今天';
    } else if (dateDay == today.subtract(const Duration(days: 1))) {
      return '昨天';
    } else if (date.year == now.year) {
      return '${date.month}月${date.day}日';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }
}
