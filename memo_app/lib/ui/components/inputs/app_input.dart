import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';

/// A customizable text input component with label, icons, and validation support.
class AppInput extends StatefulWidget {
  /// Creates an AppInput.
  const AppInput({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.maxLength,
    this.inputFormatters,
    this.textInputAction,
    this.autofocus = false,
    this.errorText,
  });

  /// The label text displayed above the input.
  final String? label;

  /// The placeholder text displayed when the input is empty.
  final String? placeholder;

  /// The controller for the input field.
  final TextEditingController? controller;

  /// The validation function that returns an error message or null.
  final String? Function(String?)? validator;

  /// The icon displayed at the start of the input.
  final IconData? prefixIcon;

  /// The icon displayed at the end of the input.
  final IconData? suffixIcon;

  /// Called when the suffix icon is tapped.
  final VoidCallback? onSuffixIconTap;

  /// Whether to obscure the text (for passwords).
  final bool obscureText;

  /// The keyboard type to use.
  final TextInputType? keyboardType;

  /// Called when the input value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the input.
  final ValueChanged<String>? onSubmitted;

  /// The focus node for the input.
  final FocusNode? focusNode;

  /// Whether the input is enabled.
  final bool enabled;

  /// The maximum length of the input.
  final int? maxLength;

  /// Input formatters to apply.
  final List<TextInputFormatter>? inputFormatters;

  /// The action to take when the user presses the keyboard action button.
  final TextInputAction? textInputAction;

  /// Whether to autofocus this input.
  final bool autofocus;

  /// Error text to display below the input. Overrides validator error.
  final String? errorText;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  String? _errorText;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _errorText = widget.errorText;
  }

  @override
  void didUpdateWidget(AppInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText) {
      setState(() {
        _errorText = widget.errorText;
      });
    }
  }

  void _validate(String? value) {
    if (widget.validator != null && _hasInteracted) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = _errorText != null && _errorText!.isNotEmpty;

    final fillColor = widget.enabled
        ? (isDark ? AppColorsDark.input : AppColors.input)
        : (isDark ? AppColorsDark.muted : AppColors.muted);

    final borderColor = hasError
        ? (isDark ? AppColorsDark.destructive : AppColors.destructive)
        : (isDark ? AppColorsDark.primary : AppColors.primary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          style: TextStyle(
            fontSize: 15,
            color: widget.enabled
                ? (isDark ? AppColorsDark.foreground : AppColors.foreground)
                : (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground),
          ),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: TextStyle(
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
              fontSize: 15,
            ),
            filled: true,
            fillColor: fillColor,
            counterText: '',
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    size: 20,
                    color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                  )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: widget.onSuffixIconTap,
                    child: Icon(
                      widget.suffixIcon,
                      size: 20,
                      color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: hasError
                  ? BorderSide(color: borderColor, width: 1)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColorsDark.destructive : AppColors.destructive,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColorsDark.destructive : AppColors.destructive,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            _hasInteracted = true;
            _validate(value);
            widget.onChanged?.call(value);
          },
          onFieldSubmitted: widget.onSubmitted,
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            _errorText!,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColorsDark.destructive : AppColors.destructive,
            ),
          ),
        ],
      ],
    );
  }
}
