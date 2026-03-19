import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';

/// A component for displaying empty state with icon, message, and optional action.
class EmptyState extends StatelessWidget {
  /// Creates an EmptyState.
  const EmptyState({
    super.key,
    required this.message,
    this.icon,
    this.action,
    this.description,
  });

  /// The main message to display.
  final String message;

  /// The icon to display above the message.
  final IconData? icon;

  /// Optional action button to display below the message.
  final Widget? action;

  /// Optional description text below the main message.
  final String? description;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (icon != null)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: (isDark ? AppColorsDark.muted : AppColors.muted).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                ),
              ),
            if (icon != null) const SizedBox(height: 24),
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColorsDark.foreground : AppColors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            // Description
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            // Action button
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-defined empty states for common scenarios.
class CommonEmptyStates {
  CommonEmptyStates._();

  /// Empty state for no todo items.
  static EmptyState noTodos({Widget? action}) => EmptyState(
        message: '暂无待办事项',
        description: '点击下方按钮添加一个待办吧',
        icon: LucideIcons.checkSquare,
        action: action,
      );

  /// Empty state for no memo items.
  static EmptyState noMemos({Widget? action}) => EmptyState(
        message: '暂无备忘录',
        description: '记录你的想法和笔记',
        icon: LucideIcons.stickyNote,
        action: action,
      );

  /// Empty state for no diary entries.
  static EmptyState noDiaries({Widget? action}) => EmptyState(
        message: '暂无日记',
        description: '记录生活中的点点滴滴',
        icon: LucideIcons.bookOpen,
        action: action,
      );

  /// Empty state for no search results.
  static EmptyState noSearchResults({String query = ''}) => EmptyState(
        message: '未找到相关内容',
        description: query.isNotEmpty ? '尝试使用其他关键词搜索' : null,
        icon: LucideIcons.searchX,
      );

  /// Empty state for no events on a date.
  static EmptyState noEvents({Widget? action}) => EmptyState(
        message: '这一天没有安排',
        description: '享受轻松的一天吧',
        icon: LucideIcons.calendarOff,
        action: action,
      );

  /// Empty state for network error.
  static EmptyState networkError({Widget? action}) => EmptyState(
        message: '网络连接失败',
        description: '请检查网络设置后重试',
        icon: LucideIcons.wifiOff,
        action: action,
      );

  /// Empty state for general error.
  static EmptyState error({String? message, Widget? action}) => EmptyState(
        message: message ?? '出错了',
        description: '请稍后重试',
        icon: LucideIcons.alertCircle,
        action: action,
      );

  /// Empty state for no countdown items.
  static EmptyState noCountdowns({Widget? action}) => EmptyState(
        message: '暂无倒数日',
        description: '记录重要的日子，让每一天都有期待',
        icon: LucideIcons.calendarHeart,
        action: action,
      );
}
