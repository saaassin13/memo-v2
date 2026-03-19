import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';

/// A card component for displaying events with title, description, time, and type.
class EventCard extends StatelessWidget {
  /// Creates an EventCard.
  const EventCard({
    super.key,
    required this.title,
    this.description,
    this.time,
    required this.type,
    this.accentColor,
    this.onTap,
  });

  /// The event title.
  final String title;

  /// Optional description text.
  final String? description;

  /// The time to display (e.g., "14:00" or "3 days left").
  final String? time;

  /// The event type: 'todo', 'diary', 'countdown', etc.
  final String type;

  /// The accent color for the left border.
  /// If not specified, uses a color based on the type.
  final Color? accentColor;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = accentColor ?? _getTypeColor(type);
    final icon = _getTypeIcon(type);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.card : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(
              color: color,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Time
              if (time != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColorsDark.muted : AppColors.muted).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    time!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'todo':
        return AppColors.chart1;
      case 'diary':
        return AppColors.chart4;
      case 'countdown':
        return AppColors.chart3;
      case 'memo':
        return AppColors.accent;
      case 'goal':
        return AppColors.chart5;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'todo':
        return LucideIcons.checkSquare;
      case 'diary':
        return LucideIcons.bookOpen;
      case 'countdown':
        return LucideIcons.timer;
      case 'memo':
        return LucideIcons.stickyNote;
      case 'goal':
        return LucideIcons.target;
      default:
        return LucideIcons.calendar;
    }
  }
}
