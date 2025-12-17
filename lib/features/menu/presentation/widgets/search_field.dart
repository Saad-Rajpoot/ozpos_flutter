import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_sizes.dart';

class SearchField extends StatelessWidget {
  final Function(String) onSearch;
  final String? hintText;

  const SearchField({super.key, required this.onSearch, this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.searchFieldHeight,
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextField(
        onChanged: onSearch,
        decoration: InputDecoration(
          hintText: hintText ?? 'Search menu items...',
          hintStyle: AppTypography.body2.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textTertiary,
            size: AppSizes.iconBase,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
        ),
        style: AppTypography.body2.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
