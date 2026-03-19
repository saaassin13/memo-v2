import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';
import '../../../components/badges/category_chip.dart';

/// A horizontal scrollable category filter with add button.
class CategoryFilter extends StatelessWidget {
  /// Creates a CategoryFilter.
  const CategoryFilter({
    super.key,
    required this.categories,
    required this.activeCategory,
    required this.onCategoryChanged,
    this.onAddCategory,
  });

  /// The list of categories to display.
  final List<String> categories;

  /// The currently active/selected category.
  final String activeCategory;

  /// Called when a category is selected.
  final ValueChanged<String> onCategoryChanged;

  /// Called when add category button is tapped.
  final VoidCallback? onAddCategory;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ...categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CategoryChip(
                  label: cat,
                  selected: activeCategory == cat,
                  onTap: () => onCategoryChanged(cat),
                ),
              )),
          // Add category button
          if (onAddCategory != null)
            GestureDetector(
              onTap: onAddCategory,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isDark ? AppColorsDark.muted : AppColors.muted)
                      .withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.plus,
                  size: 18,
                  color: isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
