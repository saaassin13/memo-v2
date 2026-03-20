import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/delta_utils.dart';
import '../badges/app_badge.dart';
import '../dialogs/app_dropdown_menu.dart';

/// A card component for displaying memo items with list/grid layout support.
class MemoCard extends StatelessWidget {
  /// Creates a MemoCard.
  const MemoCard({
    super.key,
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.updatedAt,
    this.pinned = false,
    this.gridMode = false,
    this.onTap,
    this.onTogglePin,
    this.onDelete,
  });

  /// The unique identifier of the memo.
  final String id;

  /// The memo title.
  final String title;

  /// The memo content/preview.
  final String content;

  /// The category of the memo.
  final String category;

  /// The last update time.
  final DateTime updatedAt;

  /// Whether this memo is pinned.
  final bool pinned;

  /// Whether to use grid mode layout (vs list mode).
  final bool gridMode;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Called when pin toggle is selected.
  final VoidCallback? onTogglePin;

  /// Called when delete is selected.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    if (gridMode) {
      return _buildGridCard(context);
    }
    return _buildListCard(context);
  }

  Widget _buildListCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _getCategoryColor(category);

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
            // Header row
            Row(
              children: [
                // Pin indicator
                if (pinned) ...[
                  Icon(
                    LucideIcons.pin,
                    size: 16,
                    color: isDark ? AppColorsDark.primary : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                ],
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // More button
                _buildMoreButton(context),
              ],
            ),
            const SizedBox(height: 8),
            // Content preview - extract plain text from Delta JSON
            Text(
              DeltaUtils.extractPlainText(content),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Footer
            Row(
              children: [
                AppBadge(
                  label: category,
                  color: categoryColor,
                  backgroundColor: categoryColor.withOpacity(0.15),
                ),
                const Spacer(),
                Text(
                  _formatDate(updatedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _getCategoryColor(category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
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
            // Header row
            Row(
              children: [
                if (pinned)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      LucideIcons.pin,
                      size: 14,
                      color: isDark ? AppColorsDark.primary : AppColors.primary,
                    ),
                  ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildMoreButton(context),
              ],
            ),
            const SizedBox(height: 8),
            // Content preview - takes more space in grid, extract plain text from Delta JSON
            Expanded(
              child: Text(
                DeltaUtils.extractPlainText(content),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                  height: 1.4,
                ),
                overflow: TextOverflow.fade,
              ),
            ),
            const SizedBox(height: 8),
            // Footer
            Row(
              children: [
                Flexible(
                  child: AppBadge(
                    label: category,
                    color: categoryColor,
                    backgroundColor: categoryColor.withOpacity(0.15),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDateShort(updatedAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (onTogglePin == null && onDelete == null) {
      return const SizedBox.shrink();
    }

    return Builder(
      builder: (context) => GestureDetector(
        onTapDown: (details) => _showMenu(context, details.globalPosition),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            LucideIcons.moreHorizontal,
            size: 18,
            color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context, Offset position) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    AppDropdownMenu.show(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(position, position),
        Offset.zero & overlay.size,
      ),
      items: [
        if (onTogglePin != null)
          AppMenuItem(
            label: pinned ? '取消置顶' : '置顶',
            icon: pinned ? LucideIcons.pinOff : LucideIcons.pin,
            onTap: onTogglePin,
          ),
        if (onTogglePin != null && onDelete != null) AppMenuItem.divider,
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case '工作':
        return AppColors.chart1;
      case '生活':
        return AppColors.accent;
      case '学习':
        return AppColors.chart3;
      default:
        return AppColors.mutedForeground;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return '今天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateDay == today.subtract(const Duration(days: 1))) {
      return '昨天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (date.year == now.year) {
      return '${date.month}月${date.day}日';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }

  String _formatDateShort(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return '今天';
    } else if (dateDay == today.subtract(const Duration(days: 1))) {
      return '昨天';
    } else if (date.year == now.year) {
      return '${date.month}/${date.day}';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }
}
