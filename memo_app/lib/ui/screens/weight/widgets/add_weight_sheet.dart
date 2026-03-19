import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../components/buttons/app_button.dart';
import '../../../components/inputs/app_textarea.dart';

/// 体重记录数据
class WeightRecordData {
  /// 创建 WeightRecordData
  const WeightRecordData({
    required this.weight,
    required this.date,
    required this.hasExercise,
    this.note,
  });

  /// 体重值
  final double weight;

  /// 记录日期
  final DateTime date;

  /// 是否运动
  final bool hasExercise;

  /// 备注
  final String? note;
}

/// 添加体重记录底部弹窗
class AddWeightSheet extends StatefulWidget {
  /// 创建 AddWeightSheet
  const AddWeightSheet({
    super.key,
    required this.onSave,
    this.initialWeight,
  });

  /// 保存回调
  final ValueChanged<WeightRecordData> onSave;

  /// 初始体重值（用于预填）
  final double? initialWeight;

  @override
  State<AddWeightSheet> createState() => _AddWeightSheetState();
}

class _AddWeightSheetState extends State<AddWeightSheet> {
  DateTime _date = DateTime.now();
  bool _hasExercise = false;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _weightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialWeight != null) {
      _weightController.text = widget.initialWeight!.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
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
        _date = picked;
      });
    }
  }

  void _save() {
    final weightText = _weightController.text.trim();
    if (weightText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入体重')),
      );
      return;
    }

    final weight = double.tryParse(weightText);
    if (weight == null || weight <= 0 || weight > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的体重值（0-500 kg）')),
      );
      return;
    }

    // 组合备注
    String? note = _noteController.text.trim();
    if (_hasExercise && note.isEmpty) {
      note = '运动';
    } else if (_hasExercise && !note.contains('运动')) {
      note = '运动 | $note';
    }
    if (note.isEmpty) {
      note = null;
    }

    final data = WeightRecordData(
      weight: weight,
      date: _date,
      hasExercise: _hasExercise,
      note: note,
    );

    widget.onSave(data);
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '今天';
    } else if (dateOnly == yesterday) {
      return '昨天';
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
              // 拖拽手柄
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
              // 标题
              Text(
                '记录体重',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 24),
              // 体重输入
              _buildWeightInput(isDark),
              const SizedBox(height: 20),
              // 日期选择
              _buildDatePicker(isDark),
              const SizedBox(height: 16),
              // 是否运动
              _buildExerciseToggle(isDark),
              const SizedBox(height: 16),
              // 备注输入
              AppTextArea(
                controller: _noteController,
                placeholder: '添加备注（可选）',
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              // 保存按钮
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

  Widget _buildWeightInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '体重',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.input : AppColors.input,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  focusNode: _weightFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                  ],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.0',
                    hintStyle: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: (isDark
                              ? AppColorsDark.mutedForeground
                              : AppColors.mutedForeground)
                          .withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                  ),
                  autofocus: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'kg',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                  ),
                ),
              ),
            ],
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
          '日期',
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
                    _formatDate(_date),
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                    ),
                  ),
                ),
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

  Widget _buildExerciseToggle(bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _hasExercise = !_hasExercise),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.input : AppColors.input,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.dumbbell,
              size: 20,
              color: _hasExercise
                  ? const Color(0xFF22C55E)
                  : (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '今天有运动',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
              ),
            ),
            // 开关
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 28,
              decoration: BoxDecoration(
                color: _hasExercise
                    ? const Color(0xFF22C55E)
                    : (isDark ? AppColorsDark.border : AppColors.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: _hasExercise ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
