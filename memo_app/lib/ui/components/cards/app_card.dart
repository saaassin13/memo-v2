import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// A customizable card component with support for elevation, padding, and tap interactions.
class AppCard extends StatelessWidget {
  /// Creates an AppCard.
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevated = false,
    this.borderRadius,
    this.margin,
    this.color,
  });

  /// The widget to display inside the card.
  final Widget child;

  /// The padding inside the card.
  /// Defaults to EdgeInsets.all(16) if not specified.
  final EdgeInsets? padding;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Whether to show elevated shadow effect.
  final bool elevated;

  /// The border radius of the card.
  /// Defaults to 12.0 if not specified.
  final double? borderRadius;

  /// The margin around the card.
  final EdgeInsets? margin;

  /// The background color of the card.
  /// If not specified, uses theme card color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? (isDark ? AppColorsDark.card : AppColors.card);
    final radius = borderRadius ?? 12.0;

    final boxShadow = elevated
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ];

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: boxShadow,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          splashColor: (isDark ? AppColorsDark.primary : AppColors.primary).withOpacity(0.1),
          highlightColor: (isDark ? AppColorsDark.muted : AppColors.muted).withOpacity(0.3),
          child: card,
        ),
      );
    }

    return card;
  }
}
