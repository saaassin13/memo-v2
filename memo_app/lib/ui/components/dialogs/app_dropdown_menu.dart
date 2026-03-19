import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// A menu item for AppDropdownMenu.
class AppMenuItem {
  /// Creates an AppMenuItem.
  const AppMenuItem({
    required this.label,
    this.icon,
    this.onTap,
    this.isDestructive = false,
    this.enabled = true,
  });

  /// The item label.
  final String label;

  /// Optional icon for the item.
  final IconData? icon;

  /// Called when the item is tapped.
  final VoidCallback? onTap;

  /// Whether this is a destructive action (shown in red).
  final bool isDestructive;

  /// Whether the item is enabled.
  final bool enabled;

  /// Creates a divider item.
  static const divider = _AppMenuDivider();
}

/// A divider item for menus.
class _AppMenuDivider implements AppMenuItem {
  const _AppMenuDivider();

  @override
  bool get enabled => false;

  @override
  IconData? get icon => null;

  @override
  bool get isDestructive => false;

  @override
  String get label => '';

  @override
  VoidCallback? get onTap => null;
}

/// A dropdown menu component that can be anchored to any widget.
class AppDropdownMenu extends StatelessWidget {
  /// Creates an AppDropdownMenu.
  const AppDropdownMenu({
    super.key,
    required this.items,
    this.width,
  });

  /// The menu items.
  final List<AppMenuItem> items;

  /// The width of the menu. Defaults to auto-sizing based on content.
  final double? width;

  /// Shows a dropdown menu anchored to the given position.
  static Future<void> show({
    required BuildContext context,
    required RelativeRect position,
    required List<AppMenuItem> items,
    double? width,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showMenu(
      context: context,
      position: position,
      color: isDark ? AppColorsDark.card : AppColors.card,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? AppColorsDark.border : AppColors.border,
          width: 1,
        ),
      ),
      constraints: BoxConstraints(
        minWidth: width ?? 160,
        maxWidth: width ?? 280,
      ),
      items: _buildMenuItems(context, items, isDark),
    );
  }

  /// Shows a dropdown menu anchored to a widget using GlobalKey.
  static Future<void> showFromKey({
    required BuildContext context,
    required GlobalKey anchorKey,
    required List<AppMenuItem> items,
    double? width,
    Alignment alignment = Alignment.topRight,
  }) async {
    final RenderBox? renderBox = anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    late RelativeRect position;
    if (alignment == Alignment.topRight || alignment == Alignment.bottomRight) {
      position = RelativeRect.fromLTRB(
        offset.dx + size.width,
        offset.dy + size.height,
        0,
        0,
      );
    } else {
      position = RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        0,
        0,
      );
    }

    await show(
      context: context,
      position: position,
      items: items,
      width: width,
    );
  }

  static List<PopupMenuEntry<void>> _buildMenuItems(
    BuildContext context,
    List<AppMenuItem> items,
    bool isDark,
  ) {
    final List<PopupMenuEntry<void>> result = [];
    for (final item in items) {
      if (item is _AppMenuDivider) {
        result.add(const PopupMenuDivider(height: 9));
        continue;
      }

      final textColor = item.isDestructive
          ? (isDark ? AppColorsDark.destructive : AppColors.destructive)
          : (isDark ? AppColorsDark.foreground : AppColors.foreground);

      final iconColor = item.isDestructive
          ? (isDark ? AppColorsDark.destructive : AppColors.destructive)
          : (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground);

      result.add(PopupMenuItem<void>(
        enabled: item.enabled,
        onTap: item.onTap,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 18,
                color: item.enabled
                    ? iconColor
                    : Color.fromRGBO(iconColor.r.toInt(), iconColor.g.toInt(),
                        iconColor.b.toInt(), 0.5),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  color: item.enabled
                      ? textColor
                      : Color.fromRGBO(textColor.r.toInt(), textColor.g.toInt(),
                          textColor.b.toInt(), 0.5),
                ),
              ),
            ),
          ],
        ),
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColorsDark.card : AppColors.card,
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: BoxConstraints(
          minWidth: width ?? 160,
          maxWidth: width ?? 280,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? AppColorsDark.border : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildItemWidgets(context, isDark),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItemWidgets(BuildContext context, bool isDark) {
    return items.map((item) {
      if (item is _AppMenuDivider) {
        return Divider(
          height: 1,
          color: isDark ? AppColorsDark.border : AppColors.border,
        );
      }

      final textColor = item.isDestructive
          ? (isDark ? AppColorsDark.destructive : AppColors.destructive)
          : (isDark ? AppColorsDark.foreground : AppColors.foreground);

      final iconColor = item.isDestructive
          ? (isDark ? AppColorsDark.destructive : AppColors.destructive)
          : (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground);

      return InkWell(
        onTap: item.enabled ? item.onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 18,
                  color: item.enabled ? iconColor : iconColor.withOpacity(0.5),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: item.enabled ? textColor : textColor.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
