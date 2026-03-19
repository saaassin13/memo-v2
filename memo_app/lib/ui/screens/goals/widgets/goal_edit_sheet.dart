import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../../data/database/app_database.dart';
import '../../../components/buttons/app_button.dart';
import '../../../components/inputs/app_input.dart';
import 'goal_card.dart';

/// Data class for goal creation/update.
class GoalData {
  /// Creates a GoalData.
  const GoalData({
    required this.title,
    this.description,
    required this.type,
    required this.targetValue,
    this.unit,
    required this.startDate,
    this.endDate,
  });

  /// The goal title.
  final String title;

  /// Optional description.
  final String? description;

  /// The goal type (daily/weekly/monthly/yearly/custom).
  final String type;

  /// The target value to achieve.
  final int targetValue;

  /// Optional unit for the value (e.g., "pages", "km", "times").
  final String? unit;

  /// The start date of the goal.
  final DateTime startDate;

  /// Optional end date (deadline) for the goal.
  final DateTime? endDate;
}

/// A bottom sheet for creating or editing a goal.
class GoalEditSheet extends StatefulWidget {
  /// Creates a GoalEditSheet.
  const GoalEditSheet({
    super.key,
    this.goal,
    required this.onSave,
  });

  /// The goal to edit. If null, creates a new goal.
  final Goal? goal;

  /// Called when save is pressed.
  final ValueChanged<GoalData> onSave;

  @override
  State<GoalEditSheet> createState() => _GoalEditSheetState();
}

class _GoalEditSheetState extends State<GoalEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _targetValueController;
  late final TextEditingController _unitController;

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  GoalCategory _category = GoalCategory.custom;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title);
    _descriptionController =
        TextEditingController(text: widget.goal?.description);
    _targetValueController = TextEditingController(
      text: widget.goal?.targetValue.toString() ?? '1',
    );
    _unitController = TextEditingController(text: widget.goal?.unit);

    if (widget.goal != null) {
      _startDate = widget.goal!.startDate;
      _endDate = widget.goal!.endDate;
      _category = GoalCategory.fromString(widget.goal!.type);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await _showDatePicker(_startDate);
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, clear it
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await _showDatePicker(_endDate ?? _startDate);
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<DateTime?> _showDatePicker(DateTime initialDate) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme(
              brightness: isDark ? Brightness.dark : Brightness.light,
              primary: isDark ? AppColorsDark.primary : AppColors.primary,
              onPrimary: isDark
                  ? AppColorsDark.primaryForeground
                  : AppColors.primaryForeground,
              secondary: isDark ? AppColorsDark.accent : AppColors.accent,
              onSecondary: isDark
                  ? AppColorsDark.accentForeground
                  : AppColors.accentForeground,
              error: isDark ? AppColorsDark.destructive : AppColors.destructive,
              onError: isDark
                  ? AppColorsDark.destructiveForeground
                  : AppColors.destructiveForeground,
              surface: isDark ? AppColorsDark.card : AppColors.card,
              onSurface:
                  isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
            dialogBackgroundColor: isDark ? AppColorsDark.card : AppColors.card,
          ),
          child: child!,
        );
      },
    );
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入目标名称')),
      );
      return;
    }

    final targetValue = int.tryParse(_targetValueController.text) ?? 1;
    if (targetValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('目标值必须大于 0')),
      );
      return;
    }

    final data = GoalData(
      title: title,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      type: _category.value,
      targetValue: targetValue,
      unit:
          _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.card : AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fixed header
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Column(
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
                  widget.goal != null ? '编辑目标' : '新建目标',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: bottomPadding + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title input
                  AppInput(
                    controller: _titleController,
                    label: '目标名称',
                    placeholder: '例如：每天阅读 30 分钟',
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  // Description input
                  AppInput(
                    controller: _descriptionController,
                    label: '描述（可选）',
                    placeholder: '添加更多说明',
                  ),
                  const SizedBox(height: 16),
                  // Category selector
                  _buildCategorySelector(isDark),
                  const SizedBox(height: 16),
                  // Target value and unit
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: AppInput(
                          controller: _targetValueController,
                          label: '目标值',
                          placeholder: '1',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: AppInput(
                          controller: _unitController,
                          label: '单位（可选）',
                          placeholder: '例如：次、页、公里',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Date pickers
                  _buildDatePicker(
                    label: '开始日期',
                    date: _startDate,
                    onTap: _selectStartDate,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildDatePicker(
                    label: '截止日期（可选）',
                    date: _endDate,
                    onTap: _selectEndDate,
                    isDark: isDark,
                    placeholder: '无截止日期',
                    onClear: _endDate != null
                        ? () => setState(() => _endDate = null)
                        : null,
                  ),
                  const SizedBox(height: 24),
                  // Save button
                  AppButton(
                    label: '保存',
                    onPressed: _save,
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '目标类型',
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
            children: GoalCategory.values.map((cat) {
              final isSelected = _category == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _category = cat;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
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

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required bool isDark,
    String? placeholder,
    VoidCallback? onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
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
                  color: isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null ? _formatDate(date) : (placeholder ?? '选择日期'),
                    style: TextStyle(
                      fontSize: 15,
                      color: date != null
                          ? (isDark
                              ? AppColorsDark.foreground
                              : AppColors.foreground)
                          : (isDark
                              ? AppColorsDark.mutedForeground
                              : AppColors.mutedForeground),
                    ),
                  ),
                ),
                if (onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                  )
                else
                  Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: isDark
                        ? AppColorsDark.mutedForeground
                        : AppColors.mutedForeground,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
