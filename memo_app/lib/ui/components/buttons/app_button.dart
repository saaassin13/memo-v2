import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// Button variants for different use cases
enum ButtonVariant {
  /// Primary action button with solid background
  primary,

  /// Secondary action button with muted background
  secondary,

  /// Ghost button with transparent background
  ghost,

  /// Destructive action button (delete, remove, etc.)
  destructive,
}

/// Button sizes
enum ButtonSize {
  /// Small button - compact size
  sm,

  /// Medium button - default size
  md,

  /// Large button - prominent size
  lg,
}

/// A customizable button component that supports multiple variants and sizes.
///
/// Use [AppButton] for standard buttons with text and optional icons.
/// Use [AppButton.icon] factory for icon-only buttons.
class AppButton extends StatelessWidget {
  /// Creates an AppButton.
  const AppButton({
    super.key,
    this.label,
    this.icon,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.loading = false,
    this.fullWidth = false,
  });

  /// Creates an icon-only button.
  factory AppButton.icon({
    Key? key,
    required IconData icon,
    VoidCallback? onPressed,
    ButtonVariant variant = ButtonVariant.ghost,
    ButtonSize size = ButtonSize.md,
    bool loading = false,
  }) {
    return AppButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
      variant: variant,
      size: size,
      loading: loading,
      fullWidth: false,
    );
  }

  /// The button label text.
  final String? label;

  /// The button icon displayed before the label.
  final IconData? icon;

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  /// The visual style variant of the button.
  final ButtonVariant variant;

  /// The size of the button.
  final ButtonSize size;

  /// Whether to show a loading indicator.
  final bool loading;

  /// Whether the button should expand to fill the available width.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _getColors(isDark);
    final dimensions = _getDimensions();

    final isDisabled = onPressed == null || loading;
    final isIconOnly = label == null && icon != null;

    Widget child;
    if (loading) {
      child = SizedBox(
        width: dimensions.iconSize,
        height: dimensions.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(colors.foreground),
        ),
      );
    } else if (isIconOnly) {
      child = Icon(icon, size: dimensions.iconSize);
    } else {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dimensions.iconSize),
            SizedBox(width: dimensions.iconSpacing),
          ],
          if (label != null)
            Text(
              label!,
              style: TextStyle(
                fontSize: dimensions.fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      );
    }

    final buttonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.background.withOpacity(0.5);
        }
        if (states.contains(WidgetState.pressed)) {
          return colors.pressedBackground;
        }
        return colors.background;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.foreground.withOpacity(0.5);
        }
        return colors.foreground;
      }),
      overlayColor: WidgetStateProperty.all(colors.overlay),
      padding: WidgetStateProperty.all(
        isIconOnly ? EdgeInsets.all(dimensions.iconPadding) : dimensions.padding,
      ),
      minimumSize: WidgetStateProperty.all(
        isIconOnly
            ? Size(dimensions.iconButtonSize, dimensions.iconButtonSize)
            : Size(dimensions.minWidth, dimensions.height),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
          side: variant == ButtonVariant.secondary
              ? BorderSide(color: isDark ? AppColorsDark.border : AppColors.border)
              : BorderSide.none,
        ),
      ),
      elevation: WidgetStateProperty.all(0),
    );

    Widget button = TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: buttonStyle,
      child: child,
    );

    if (fullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  _ButtonColors _getColors(bool isDark) {
    switch (variant) {
      case ButtonVariant.primary:
        return _ButtonColors(
          background: isDark ? AppColorsDark.primary : AppColors.primary,
          foreground: isDark ? AppColorsDark.primaryForeground : AppColors.primaryForeground,
          pressedBackground: isDark
              ? AppColorsDark.primary.withOpacity(0.9)
              : AppColors.primary.withOpacity(0.9),
          overlay: Colors.white.withOpacity(0.1),
        );
      case ButtonVariant.secondary:
        return _ButtonColors(
          background: isDark ? AppColorsDark.secondary : AppColors.secondary,
          foreground: isDark ? AppColorsDark.secondaryForeground : AppColors.secondaryForeground,
          pressedBackground: isDark
              ? AppColorsDark.secondary.withOpacity(0.8)
              : AppColors.secondary.withOpacity(0.8),
          overlay: (isDark ? AppColorsDark.foreground : AppColors.foreground).withOpacity(0.05),
        );
      case ButtonVariant.ghost:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: isDark ? AppColorsDark.foreground : AppColors.foreground,
          pressedBackground: (isDark ? AppColorsDark.muted : AppColors.muted).withOpacity(0.5),
          overlay: (isDark ? AppColorsDark.foreground : AppColors.foreground).withOpacity(0.05),
        );
      case ButtonVariant.destructive:
        return _ButtonColors(
          background: isDark ? AppColorsDark.destructive : AppColors.destructive,
          foreground:
              isDark ? AppColorsDark.destructiveForeground : AppColors.destructiveForeground,
          pressedBackground: isDark
              ? AppColorsDark.destructive.withOpacity(0.9)
              : AppColors.destructive.withOpacity(0.9),
          overlay: Colors.white.withOpacity(0.1),
        );
    }
  }

  _ButtonDimensions _getDimensions() {
    switch (size) {
      case ButtonSize.sm:
        return const _ButtonDimensions(
          height: 32,
          minWidth: 64,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          fontSize: 13,
          iconSize: 16,
          iconSpacing: 6,
          borderRadius: 8,
          iconPadding: 6,
          iconButtonSize: 32,
        );
      case ButtonSize.md:
        return const _ButtonDimensions(
          height: 40,
          minWidth: 80,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          fontSize: 14,
          iconSize: 18,
          iconSpacing: 8,
          borderRadius: 10,
          iconPadding: 8,
          iconButtonSize: 40,
        );
      case ButtonSize.lg:
        return const _ButtonDimensions(
          height: 48,
          minWidth: 96,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          fontSize: 16,
          iconSize: 20,
          iconSpacing: 10,
          borderRadius: 12,
          iconPadding: 10,
          iconButtonSize: 48,
        );
    }
  }
}

class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.foreground,
    required this.pressedBackground,
    required this.overlay,
  });

  final Color background;
  final Color foreground;
  final Color pressedBackground;
  final Color overlay;
}

class _ButtonDimensions {
  const _ButtonDimensions({
    required this.height,
    required this.minWidth,
    required this.padding,
    required this.fontSize,
    required this.iconSize,
    required this.iconSpacing,
    required this.borderRadius,
    required this.iconPadding,
    required this.iconButtonSize,
  });

  final double height;
  final double minWidth;
  final EdgeInsets padding;
  final double fontSize;
  final double iconSize;
  final double iconSpacing;
  final double borderRadius;
  final double iconPadding;
  final double iconButtonSize;
}
