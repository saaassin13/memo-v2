import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

/// Mood enum for diary entries
enum Mood {
  happy('happy', '开心', '😊'),
  joy('joy', '喜悦', '😄'),
  love('love', '爱', '❤️'),
  calm('calm', '平静', '😌'),
  sad('sad', '难过', '😢'),
  angry('angry', '愤怒', '😠');

  final String value;
  final String label;
  final String emoji;

  const Mood(this.value, this.label, this.emoji);

  /// Get Mood enum from string value
  static Mood? fromValue(String? value) {
    if (value == null) return null;
    return Mood.values.where((m) => m.value == value).firstOrNull;
  }
}

/// A selector widget for choosing mood.
class MoodSelector extends StatelessWidget {
  /// Creates a MoodSelector.
  const MoodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  /// The currently selected mood.
  final Mood selected;

  /// Called when the selection changes.
  final ValueChanged<Mood> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Mood.values.map((mood) {
        final isSelected = mood == selected;
        return GestureDetector(
          onTap: () => onChanged(mood),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppColorsDark.primary : AppColors.primary)
                  : (isDark ? AppColorsDark.card : AppColors.card),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? (isDark ? AppColorsDark.primary : AppColors.primary)
                    : (isDark ? AppColorsDark.border : AppColors.border),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mood.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 4),
                Text(
                  mood.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColorsDark.foreground
                            : AppColors.foreground),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
