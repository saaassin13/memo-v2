import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../../data/database/app_database.dart';
import '../../../components/buttons/app_button.dart';

/// Sheet for updating goal progress with note
class ProgressUpdateSheet extends StatefulWidget {
  /// The goal to update
  final Goal goal;

  /// Callback when progress is updated
  final void Function(int newValue, String? note) onUpdate;

  const ProgressUpdateSheet({
    super.key,
    required this.goal,
    required this.onUpdate,
  });

  @override
  State<ProgressUpdateSheet> createState() => _ProgressUpdateSheetState();
}

class _ProgressUpdateSheetState extends State<ProgressUpdateSheet> {
  late TextEditingController _valueController;
  final _noteController = TextEditingController();
  late int _changeAmount;
  bool _isIncrement = true;

  @override
  void initState() {
    super.initState();
    _changeAmount = 1;
    _valueController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int get _previewValue {
    final change = _changeAmount * (_isIncrement ? 1 : -1);
    return (widget.goal.currentValue + change).clamp(0, 999999);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.card : AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                '更新进度',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current progress info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColorsDark.muted : AppColors.muted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.goal.currentValue}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColorsDark.foreground
                        : AppColors.foreground,
                  ),
                ),
                Text(
                  ' / ${widget.goal.targetValue}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColorsDark.mutedForeground
                        : AppColors.mutedForeground,
                  ),
                ),
                if (widget.goal.unit != null &&
                    widget.goal.unit!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    widget.goal.unit!,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Increment/Decrement toggle
          Row(
            children: [
              Expanded(
                child: _buildToggleButton(
                  label: '增加',
                  icon: LucideIcons.plus,
                  isSelected: _isIncrement,
                  onTap: () => setState(() => _isIncrement = true),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildToggleButton(
                  label: '减少',
                  icon: LucideIcons.minus,
                  isSelected: !_isIncrement,
                  onTap: () => setState(() => _isIncrement = false),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick amount buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [1, 5, 10, 20, 50].map((amount) {
              final isSelected = _changeAmount == amount;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _changeAmount = amount;
                    _valueController.text = amount.toString();
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColorsDark.primary : AppColors.primary)
                        : (isDark ? AppColorsDark.muted : AppColors.muted),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$amount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? (isDark
                              ? AppColorsDark.primaryForeground
                              : AppColors.primaryForeground)
                          : (isDark
                              ? AppColorsDark.foreground
                              : AppColors.foreground),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Custom amount input
          Row(
            children: [
              Text(
                '自定义：',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColorsDark.foreground
                        : AppColors.foreground,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    final parsed = int.tryParse(value) ?? 0;
                    setState(() => _changeAmount = parsed);
                  },
                ),
              ),
              const Spacer(),
              // Preview
              Text(
                '${_isIncrement ? "+" : "-"}$_changeAmount = $_previewValue',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColorsDark.primary : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Note input
          Text(
            '备注（可选）',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColorsDark.mutedForeground
                  : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: '记录这次进度更新的说明...',
              hintStyle: TextStyle(
                color: isDark
                    ? AppColorsDark.mutedForeground
                    : AppColors.mutedForeground,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 24),

          // Confirm button
          AppButton(
            label: '确认更新',
            icon: LucideIcons.check,
            fullWidth: true,
            onPressed: _changeAmount > 0
                ? () {
                    final note = _noteController.text.trim();
                    widget.onUpdate(
                      _previewValue,
                      note.isNotEmpty ? note : null,
                    );
                    Navigator.pop(context);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColorsDark.primary : AppColors.primary)
              : (isDark ? AppColorsDark.muted : AppColors.muted),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? (isDark
                      ? AppColorsDark.primaryForeground
                      : AppColors.primaryForeground)
                  : (isDark
                      ? AppColorsDark.foreground
                      : AppColors.foreground),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? (isDark
                        ? AppColorsDark.primaryForeground
                        : AppColors.primaryForeground)
                    : (isDark
                        ? AppColorsDark.foreground
                        : AppColors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
