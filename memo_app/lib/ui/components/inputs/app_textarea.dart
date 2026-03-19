import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// A multi-line text input component with auto-height support.
class AppTextArea extends StatelessWidget {
  /// Creates an AppTextArea.
  const AppTextArea({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.focusNode,
    this.enabled = true,
    this.minLines = 3,
    this.maxLines,
    this.maxLength,
    this.showCounter = false,
    this.autoExpand = true,
  });

  /// The label text displayed above the textarea.
  final String? label;

  /// The placeholder text displayed when empty.
  final String? placeholder;

  /// The controller for the textarea.
  final TextEditingController? controller;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// The focus node for the textarea.
  final FocusNode? focusNode;

  /// Whether the textarea is enabled.
  final bool enabled;

  /// The minimum number of lines to display.
  final int minLines;

  /// The maximum number of lines to display.
  /// If null and autoExpand is true, expands indefinitely.
  final int? maxLines;

  /// The maximum length of the text.
  final int? maxLength;

  /// Whether to show the character counter.
  final bool showCounter;

  /// Whether to auto-expand as user types.
  final bool autoExpand;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fillColor = enabled
        ? (isDark ? AppColorsDark.input : AppColors.input)
        : (isDark ? AppColorsDark.muted : AppColors.muted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          maxLines: autoExpand ? maxLines : minLines,
          minLines: minLines,
          maxLength: maxLength,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          style: TextStyle(
            fontSize: 15,
            color: enabled
                ? (isDark ? AppColorsDark.foreground : AppColors.foreground)
                : (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground),
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
              fontSize: 15,
            ),
            filled: true,
            fillColor: fillColor,
            counterText: showCounter ? null : '',
            counterStyle: TextStyle(
              fontSize: 12,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColorsDark.primary : AppColors.primary,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
