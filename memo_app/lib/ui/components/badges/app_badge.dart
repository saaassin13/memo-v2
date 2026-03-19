import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// Badge variants for different visual styles
enum BadgeVariant {
  /// Default badge with primary styling
  default_,

  /// Secondary badge with muted styling
  secondary,

  /// Outline badge with border
  outline,
}

/// A badge/tag component for displaying labels and status indicators.
class AppBadge extends StatelessWidget {
  /// Creates an AppBadge.
  const AppBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.default_,
    this.color,
    this.backgroundColor,
    this.borderColor,
  });

  /// The text to display in the badge.
  final String label;

  /// The visual style variant of the badge.
  final BadgeVariant variant;

  /// Custom text color. Overrides variant color if specified.
  final Color? color;

  /// Custom background color. Overrides variant background if specified.
  final Color? backgroundColor;

  /// Custom border color for outline variant.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _getColors(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.background,
        borderRadius: BorderRadius.circular(6),
        border: variant == BadgeVariant.outline
            ? Border.all(
                color: borderColor ?? colors.border,
                width: 1,
              )
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color ?? colors.foreground,
          height: 1.2,
        ),
      ),
    );
  }

  _BadgeColors _getColors(bool isDark) {
    switch (variant) {
      case BadgeVariant.default_:
        return _BadgeColors(
          background: (isDark ? AppColorsDark.primary : AppColors.primary).withOpacity(0.15),
          foreground: isDark ? AppColorsDark.primary : AppColors.primary,
          border: Colors.transparent,
        );
      case BadgeVariant.secondary:
        return _BadgeColors(
          background: isDark ? AppColorsDark.muted : AppColors.muted,
          foreground: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
          border: Colors.transparent,
        );
      case BadgeVariant.outline:
        return _BadgeColors(
          background: Colors.transparent,
          foreground: isDark ? AppColorsDark.foreground : AppColors.foreground,
          border: isDark ? AppColorsDark.border : AppColors.border,
        );
    }
  }
}

class _BadgeColors {
  const _BadgeColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
