import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../../data/database/app_database.dart';
import '../../../components/buttons/app_button.dart';
import '../../../components/inputs/app_input.dart';
import 'countdown_card.dart';

/// Data class for countdown creation/update.
class CountdownData {
  /// Creates a CountdownData.
  const CountdownData({
    required this.title,
    required this.targetDate,
    required this.type,
    required this.repeatYearly,
  });

  /// The countdown title.
  final String title;

  /// The target date.
  final DateTime targetDate;

  /// The category type (birthday/festival/important).
  final String type;

  /// Whether to repeat yearly.
  final bool repeatYearly;
}

/// A bottom sheet for creating or editing a countdown.
class CountdownEditSheet extends StatefulWidget {
  /// Creates a CountdownEditSheet.
  const CountdownEditSheet({
    super.key,
    this.countdown,
    required this.onSave,
  });

  /// The countdown to edit. If null, creates a new countdown.
  final Countdown? countdown;

  /// Called when save is pressed.
  final ValueChanged<CountdownData> onSave;

  @override
  State<CountdownEditSheet> createState() => _CountdownEditSheetState();
}

class _CountdownEditSheetState extends State<CountdownEditSheet> {
  late final TextEditingController _titleController;
  DateTime _targetDate = DateTime.now();
  CountdownCategory _category = CountdownCategory.important;
  bool _repeatYearly = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.countdown?.title);
    if (widget.countdown != null) {
      _targetDate = widget.countdown!.targetDate;
      _category = CountdownCategory.fromString(widget.countdown!.type);
      _repeatYearly = widget.countdown!.repeatYearly;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme(
              brightness: isDark ? Brightness.dark : Brightness.light,
              primary: isDark ? AppColorsDark.primary : AppColors.primary,
              onPrimary:
                  isDark ? AppColorsDark.primaryForeground : AppColors.primaryForeground,
              secondary: isDark ? AppColorsDark.accent : AppColors.accent,
              onSecondary:
                  isDark ? AppColorsDark.accentForeground : AppColors.accentForeground,
              error: isDark ? AppColorsDark.destructive : AppColors.destructive,
              onError: isDark
                  ? AppColorsDark.destructiveForeground
                  : AppColors.destructiveForeground,
              surface: isDark ? AppColorsDark.card : AppColors.card,
              onSurface: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
            dialogBackgroundColor: isDark ? AppColorsDark.card : AppColors.card,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入名称')),
      );
      return;
    }

    final data = CountdownData(
      title: title,
      targetDate: _targetDate,
      type: _category.value,
      repeatYearly: _repeatYearly,
    );
    widget.onSave(data);
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.card : AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: bottomPadding + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColorsDark.border : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              widget.countdown != null ? '编辑倒数日' : '新建倒数日',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColorsDark.foreground : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 20),
            // Title input
            AppInput(
              controller: _titleController,
              placeholder: '名称',
              autofocus: true,
            ),
            const SizedBox(height: 16),
            // Date picker
            _buildDatePicker(isDark),
            const SizedBox(height: 16),
            // Category selector
            _buildCategorySelector(isDark),
            const SizedBox(height: 16),
            // Repeat yearly toggle
            _buildRepeatToggle(isDark),
            const SizedBox(height: 20),
            // Save button
            AppButton(
              label: '保存',
              onPressed: _save,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '目标日期',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColorsDark.input : AppColors.input,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 20,
                  color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _formatDate(_targetDate),
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分类',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: CountdownCategory.values.map((cat) {
              final isSelected = _category == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _category = cat;
                      // Auto-enable repeat for birthdays
                      if (cat == CountdownCategory.birthday) {
                        _repeatYearly = true;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cat.color.withOpacity(isDark ? 0.3 : 0.15)
                          : (isDark ? AppColorsDark.muted : AppColors.muted),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? cat.color
                            : (isDark ? AppColorsDark.border : AppColors.border),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat.icon,
                          size: 16,
                          color: isSelected
                              ? cat.color
                              : (isDark
                                  ? AppColorsDark.mutedForeground
                                  : AppColors.mutedForeground),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? cat.color
                                : (isDark
                                    ? AppColorsDark.foreground
                                    : AppColors.foreground),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatToggle(bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _repeatYearly = !_repeatYearly;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.input : AppColors.input,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.repeat,
              size: 20,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '每年重复',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                    ),
                  ),
                  Text(
                    '如生日、纪念日等每年循环的日期',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _repeatYearly,
              onChanged: (value) {
                setState(() {
                  _repeatYearly = value;
                });
              },
              activeColor: isDark ? AppColorsDark.primary : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
