import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../components/buttons/app_button.dart';
import '../../../components/inputs/app_textarea.dart';
import 'category_config.dart';

/// 交易记录数据
class TransactionData {
  /// 创建 TransactionData
  const TransactionData({
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  /// 金额
  final double amount;

  /// 类型 (income/expense)
  final String type;

  /// 分类
  final String category;

  /// 日期
  final DateTime date;

  /// 备注
  final String? note;
}

/// 新增交易记录底部弹窗
class AddTransactionSheet extends StatefulWidget {
  /// 创建 AddTransactionSheet
  const AddTransactionSheet({
    super.key,
    required this.onSave,
    this.initialType = 'expense',
  });

  /// 保存回调
  final ValueChanged<TransactionData> onSave;

  /// 初始类型
  final String initialType;

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  late String _type;
  late String _category;
  DateTime _date = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _category = _type == 'income' ? '工资' : '餐饮';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<CategoryConfig> get _categories {
    return _type == 'income'
        ? IncomeCategories.all
        : ExpenseCategories.all;
  }

  void _toggleType(String type) {
    if (_type == type) return;
    setState(() {
      _type = type;
      // 切换类型时重置分类到第一个
      _category = _categories.first.name;
    });
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
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入金额')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效金额')),
      );
      return;
    }

    final data = TransactionData(
      amount: amount,
      type: _type,
      category: _category,
      date: _date,
      note: _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : null,
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
                '记一笔',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 20),
              // 类型切换
              _buildTypeToggle(isDark),
              const SizedBox(height: 20),
              // 金额输入
              _buildAmountInput(isDark),
              const SizedBox(height: 20),
              // 分类选择
              _buildCategorySelector(isDark),
              const SizedBox(height: 16),
              // 日期选择
              _buildDatePicker(isDark),
              const SizedBox(height: 16),
              // 备注输入
              AppTextArea(
                controller: _noteController,
                placeholder: '添加备注（可选）',
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 20),
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

  Widget _buildTypeToggle(bool isDark) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.input : AppColors.input,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _toggleType('expense'),
              child: Container(
                decoration: BoxDecoration(
                  color: _type == 'expense'
                      ? const Color(0xFFEF4444)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.all(4),
                child: Center(
                  child: Text(
                    '支出',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _type == 'expense'
                          ? Colors.white
                          : (isDark
                              ? AppColorsDark.mutedForeground
                              : AppColors.mutedForeground),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _toggleType('income'),
              child: Container(
                decoration: BoxDecoration(
                  color: _type == 'income'
                      ? const Color(0xFF22C55E)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.all(4),
                child: Center(
                  child: Text(
                    '收入',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _type == 'income'
                          ? Colors.white
                          : (isDark
                              ? AppColorsDark.mutedForeground
                              : AppColors.mutedForeground),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '金额',
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
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '¥',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: _type == 'expense'
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF22C55E),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: (isDark
                              ? AppColorsDark.mutedForeground
                              : AppColors.mutedForeground)
                          .withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                  ),
                  autofocus: true,
                ),
              ),
            ],
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
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _categories.map((config) {
            final isSelected = _category == config.name;
            return GestureDetector(
              onTap: () => setState(() => _category = config.name),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? config.color
                          : config.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: config.color, width: 2)
                          : null,
                    ),
                    child: Icon(
                      config.icon,
                      size: 24,
                      color: isSelected ? Colors.white : config.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? config.color
                          : (isDark
                              ? AppColorsDark.foreground
                              : AppColors.foreground),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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
}
