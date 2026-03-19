import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

/// A circular progress indicator with percentage display.
class ProgressRing extends StatelessWidget {
  /// Creates a ProgressRing.
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 10,
    this.backgroundColor,
    this.progressColor,
    this.showPercentage = true,
    this.centerWidget,
  });

  /// The progress value from 0.0 to 1.0.
  final double progress;

  /// The size (diameter) of the ring.
  final double size;

  /// The width of the ring stroke.
  final double strokeWidth;

  /// The background color of the ring.
  final Color? backgroundColor;

  /// The color of the progress arc.
  final Color? progressColor;

  /// Whether to show the percentage text in the center.
  final bool showPercentage;

  /// Custom widget to display in the center. Overrides percentage display.
  final Widget? centerWidget;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        backgroundColor ?? (isDark ? AppColorsDark.muted : AppColors.muted);
    final fgColor =
        progressColor ?? (isDark ? AppColorsDark.primary : AppColors.primary);

    // Clamp progress between 0 and 1
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percentage = (clampedProgress * 100).round();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: 1.0,
              color: bgColor,
              strokeWidth: strokeWidth,
            ),
          ),
          // Progress ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: clampedProgress,
              color: fgColor,
              strokeWidth: strokeWidth,
            ),
          ),
          // Center content
          if (centerWidget != null)
            centerWidget!
          else if (showPercentage)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
                ),
                if (size >= 80)
                  Text(
                    '已完成',
                    style: TextStyle(
                      fontSize: size * 0.1,
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Custom painter for drawing the progress ring.
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw arc starting from top (-90 degrees)
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// A smaller inline progress ring for use in lists or cards.
class MiniProgressRing extends StatelessWidget {
  /// Creates a MiniProgressRing.
  const MiniProgressRing({
    super.key,
    required this.progress,
    this.size = 40,
    this.strokeWidth = 4,
    this.backgroundColor,
    this.progressColor,
  });

  /// The progress value from 0.0 to 1.0.
  final double progress;

  /// The size (diameter) of the ring.
  final double size;

  /// The width of the ring stroke.
  final double strokeWidth;

  /// The background color of the ring.
  final Color? backgroundColor;

  /// The color of the progress arc.
  final Color? progressColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percentage = (clampedProgress * 100).round();

    return ProgressRing(
      progress: clampedProgress,
      size: size,
      strokeWidth: strokeWidth,
      backgroundColor: backgroundColor,
      progressColor: progressColor,
      showPercentage: false,
      centerWidget: Text(
        '$percentage%',
        style: TextStyle(
          fontSize: size * 0.28,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColorsDark.foreground : AppColors.foreground,
        ),
      ),
    );
  }
}
