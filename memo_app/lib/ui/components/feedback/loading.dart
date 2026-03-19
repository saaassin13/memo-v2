import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// A loading indicator component with fullscreen and inline modes.
class Loading extends StatelessWidget {
  /// Creates a Loading indicator.
  const Loading({
    super.key,
    this.message,
    this.size = 32,
    this.strokeWidth = 3,
    this.color,
  });

  /// Creates a fullscreen loading overlay.
  const Loading.fullscreen({
    super.key,
    this.message,
    this.size = 40,
    this.strokeWidth = 4,
    this.color,
  });

  /// Creates a small inline loading indicator.
  const Loading.inline({
    super.key,
    this.message,
    this.size = 20,
    this.strokeWidth = 2.5,
    this.color,
  });

  /// Optional message to display below the indicator.
  final String? message;

  /// The size of the loading indicator.
  final double size;

  /// The stroke width of the indicator.
  final double strokeWidth;

  /// The color of the indicator. Uses primary color if not specified.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final indicatorColor = color ?? (isDark ? AppColorsDark.primary : AppColors.primary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// A fullscreen loading overlay that covers the entire screen.
class LoadingOverlay extends StatelessWidget {
  /// Creates a LoadingOverlay.
  const LoadingOverlay({
    super.key,
    this.message,
    this.backgroundColor,
  });

  /// Optional message to display.
  final String? message;

  /// The background color of the overlay.
  final Color? backgroundColor;

  /// Shows a loading overlay on top of the current screen.
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black26,
      builder: (context) => LoadingOverlay(message: message),
    );
  }

  /// Hides the loading overlay.
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: backgroundColor ?? (isDark ? AppColorsDark.card : AppColors.card),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Loading.fullscreen(message: message),
        ),
      ),
    );
  }
}

/// A widget that shows a loading indicator while content is loading.
class LoadingContainer extends StatelessWidget {
  /// Creates a LoadingContainer.
  const LoadingContainer({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingWidget,
  });

  /// Whether the content is loading.
  final bool isLoading;

  /// The content to display when not loading.
  final Widget child;

  /// Custom loading widget. Uses default Loading if not specified.
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: loadingWidget ?? const Loading(),
      );
    }
    return child;
  }
}

/// A shimmer loading placeholder.
class ShimmerLoading extends StatefulWidget {
  /// Creates a ShimmerLoading.
  const ShimmerLoading({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 4,
  });

  /// The width of the placeholder. Uses parent width if not specified.
  final double? width;

  /// The height of the placeholder.
  final double height;

  /// The border radius of the placeholder.
  final double borderRadius;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColorsDark.muted : AppColors.muted;
    final highlightColor = isDark
        ? AppColorsDark.muted.withOpacity(0.5)
        : AppColors.muted.withOpacity(0.5);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
            ),
          ),
        );
      },
    );
  }
}
