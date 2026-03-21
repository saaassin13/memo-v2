import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../../data/database/app_database.dart';
import '../../../components/buttons/app_button.dart';
import '../../../components/inputs/app_input.dart';
import '../../../components/inputs/app_textarea.dart';
import '../../../components/badges/category_chip.dart';

/// Data class for todo creation/update.
class TodoData {
  /// Creates a TodoData.
  const TodoData({
    required this.title,
    required this.category,
    this.dueDate,
    this.note,
    this.remind = false,
  });

  /// The todo title.
  final String title;

  /// The category.
  final String category;

  /// Optional due date.
  final DateTime? dueDate;

  /// Optional note.
  final String? note;

  /// Whether to enable reminder notification.
  final bool remind;
}

/// A bottom sheet for creating or editing a todo.
class TodoEditSheet extends StatefulWidget {
  /// Creates a TodoEditSheet.
  const TodoEditSheet({
    super.key,
    this.todo,
    required this.onSave,
  });

  /// The todo to edit. If null, creates a new todo.
  final Todo? todo;

  /// Called when save is pressed.
  final ValueChanged<TodoData> onSave;

  @override
  State<TodoEditSheet> createState() => _TodoEditSheetState();
}

class _TodoEditSheetState extends State<TodoEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  String _category = '杂项';
  DateTime? _dueDate;
  bool _remind = false;

  static const List<String> _categories = ['工作', '生活', '学习', '杂项'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title);
    _noteController = TextEditingController(text: widget.todo?.note);
    _category = widget.todo?.category ?? '杂项';
    _dueDate = widget.todo?.dueDate;
    _remind = widget.todo?.remind ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
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
        _dueDate = picked;
      });
    }
  }

  void _clearDate() {
    setState(() {
      _dueDate = null;
      _remind = false;
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      return;
    }

    final data = TodoData(
      title: title,
      category: _category,
      dueDate: _dueDate,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      remind: _remind,
    );
    widget.onSave(data);
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '今天';
    } else if (dateOnly == tomorrow) {
      return '明天';
    } else if (date.year == now.year) {
      return '${date.month}月${date.day}日';
    } else {
      return '${date.year}年${date.month}月${date.day}日';
    }
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
        child: SingleChildScrollView(
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
                  color: (isDark ? AppColorsDark.border : AppColors.border),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              widget.todo != null ? '编辑待办' : '新建待办',
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
              placeholder: '待办事项',
              autofocus: true,
            ),
            const SizedBox(height: 16),
            // Category selector
            _buildCategorySelector(isDark),
            const SizedBox(height: 16),
            // Date picker
            _buildDatePicker(isDark),
            // Reminder toggle (only when due date is set)
            if (_dueDate != null) ...[
              const SizedBox(height: 16),
              _buildReminderToggle(isDark),
            ],
            const SizedBox(height: 16),
            // Note input
            AppTextArea(
              controller: _noteController,
              placeholder: '添加备注（可选）',
              minLines: 2,
              maxLines: 4,
            ),
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
      ),
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
            children: _categories.map((cat) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CategoryChip(
                  label: cat,
                  selected: _category == cat,
                  onTap: () {
                    setState(() {
                      _category = cat;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '截止日期',
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
                  color: isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _dueDate != null ? _formatDate(_dueDate!) : '选择日期（可选）',
                    style: TextStyle(
                      fontSize: 15,
                      color: _dueDate != null
                          ? (isDark ? AppColorsDark.foreground : AppColors.foreground)
                          : (isDark
                              ? AppColorsDark.mutedForeground
                              : AppColors.mutedForeground),
                    ),
                  ),
                ),
                if (_dueDate != null)
                  GestureDetector(
                    onTap: _clearDate,
                    child: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderToggle(bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _remind = !_remind;
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
              LucideIcons.bell,
              size: 20,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '到期提醒',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                    ),
                  ),
                  Text(
                    '提前1天和当天各提醒一次',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _remind,
              onChanged: (value) {
                setState(() {
                  _remind = value;
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
