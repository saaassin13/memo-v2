import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// Category color mapping.
const categoryColors = {
  '工作': AppColors.chart1,
  '生活': AppColors.accent,
  '学习': AppColors.chart3,
  '杂项': AppColors.mutedForeground,
};

/// A chip component for category selection with selected state support.
class CategoryChip extends StatelessWidget {
  /// Creates a CategoryChip.
  const CategoryChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.color,
  });

  /// The category label.
  final String label;

  /// Whether this chip is selected.
  final bool selected;

  /// Called when the chip is tapped.
  final VoidCallback? onTap;

  /// Custom color. If not specified, uses categoryColors mapping.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipColor = color ?? categoryColors[label] ?? AppColors.mutedForeground;

    final backgroundColor = selected
        ? chipColor.withOpacity(isDark ? 0.3 : 0.2)
        : (isDark ? AppColorsDark.muted : AppColors.muted).withOpacity(0.5);

    final textColor = selected
        ? chipColor
        : (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground);

    final borderColor = selected ? chipColor : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

/// A horizontal scrollable list of category chips.
class CategoryChipList extends StatelessWidget {
  /// Creates a CategoryChipList.
  const CategoryChipList({
    super.key,
    required this.categories,
    this.selectedCategory,
    this.onCategorySelected,
    this.padding,
  });

  /// The list of categories to display.
  final List<String> categories;

  /// The currently selected category.
  final String? selectedCategory;

  /// Called when a category is selected.
  final ValueChanged<String>? onCategorySelected;

  /// Padding around the list.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (int i = 0; i < categories.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            CategoryChip(
              label: categories[i],
              selected: categories[i] == selectedCategory,
              onTap: onCategorySelected != null
                  ? () => onCategorySelected!(categories[i])
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
