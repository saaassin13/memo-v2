import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// A bottom drawer/sheet component with drag-to-dismiss support.
class AppDrawer extends StatelessWidget {
  /// Creates an AppDrawer.
  const AppDrawer({
    super.key,
    this.title,
    this.description,
    required this.child,
    this.maxHeight,
    this.showDragHandle = true,
  });

  /// The drawer title.
  final String? title;

  /// Optional description text below the title.
  final String? description;

  /// The main content of the drawer.
  final Widget child;

  /// The maximum height of the drawer as a fraction of screen height.
  /// Defaults to 0.9 (90% of screen height).
  final double? maxHeight;

  /// Whether to show the drag handle at the top.
  final bool showDragHandle;

  /// Shows a bottom drawer and returns the result.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    String? description,
    double? maxHeight,
    bool showDragHandle = true,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => AppDrawer(
        title: title,
        description: description,
        maxHeight: maxHeight,
        showDragHandle: showDragHandle,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxSheetHeight = screenHeight * (maxHeight ?? 0.9);

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxSheetHeight,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.card : AppColors.card,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          if (showDragHandle)
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColorsDark.muted : AppColors.muted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          // Header
          if (title != null || description != null)
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: showDragHandle ? 8 : 20,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                      ),
                    ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          // Divider after header
          if (title != null || description != null)
            Divider(
              height: 1,
              color: isDark ? AppColorsDark.border : AppColors.border,
            ),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// A list item for use in AppDrawer.
class AppDrawerItem extends StatelessWidget {
  /// Creates an AppDrawerItem.
  const AppDrawerItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
  });

  /// The item title.
  final String title;

  /// Optional subtitle text.
  final String? subtitle;

  /// Widget displayed at the start (usually an icon).
  final Widget? leading;

  /// Widget displayed at the end.
  final Widget? trailing;

  /// Called when the item is tapped.
  final VoidCallback? onTap;

  /// Whether this item is selected.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? AppColorsDark.primary : AppColors.primary).withOpacity(0.1)
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected
                          ? (isDark ? AppColorsDark.primary : AppColors.primary)
                          : (isDark ? AppColorsDark.foreground : AppColors.foreground),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
