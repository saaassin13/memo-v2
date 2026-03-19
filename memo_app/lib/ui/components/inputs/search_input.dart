import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';

/// A search input component with search icon and clear button.
class SearchInput extends StatefulWidget {
  /// Creates a SearchInput.
  const SearchInput({
    super.key,
    this.placeholder = '搜索',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.focusNode,
    this.autofocus = false,
  });

  /// The placeholder text.
  final String placeholder;

  /// The controller for the input field.
  final TextEditingController? controller;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (presses search on keyboard).
  final ValueChanged<String>? onSubmitted;

  /// Called when the clear button is pressed.
  final VoidCallback? onClear;

  /// The focus node for the input.
  final FocusNode? focusNode;

  /// Whether to autofocus this input.
  final bool autofocus;

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late TextEditingController _controller;
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _showClear = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _showClear) {
      setState(() {
        _showClear = hasText;
      });
    }
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      style: TextStyle(
        fontSize: 15,
        color: isDark ? AppColorsDark.foreground : AppColors.foreground,
      ),
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: TextStyle(
          color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
          fontSize: 15,
        ),
        filled: true,
        fillColor: isDark ? AppColorsDark.input : AppColors.input,
        prefixIcon: Icon(
          LucideIcons.search,
          size: 20,
          color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
        ),
        suffixIcon: _showClear
            ? GestureDetector(
                onTap: _handleClear,
                child: Icon(
                  LucideIcons.x,
                  size: 18,
                  color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                ),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      ),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
  }
}
