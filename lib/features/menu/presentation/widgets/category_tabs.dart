import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/menu_category_entity.dart';

class CategoryTabs extends StatelessWidget {
  final List<MenuCategoryEntity> categories;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const CategoryTabs({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1, // +1 for "All" tab
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryTab(
              label: 'All',
              isSelected: selectedCategory == null,
              onTap: () => onCategorySelected(null),
            );
          }

          final category = categories[index - 1];
          return _CategoryTab(
            label: category.name,
            isSelected: selectedCategory == category.id,
            onTap: () => onCategorySelected(category.id),
          );
        },
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: isSelected ? AppColors.primary : AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              label,
              style: AppTypography.body2.copyWith(
                color: isSelected
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected
                    ? AppTypography.medium
                    : AppTypography.regular,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
