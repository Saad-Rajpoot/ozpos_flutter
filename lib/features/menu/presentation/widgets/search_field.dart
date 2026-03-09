import 'package:flutter/material.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: AppSizes.searchFieldHeight,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: TextField(
        onChanged: onSearch,
        decoration: InputDecoration(
          hintText: hintText ?? 'Search menu items...',
          hintStyle: AppTypography.body2.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurfaceVariant,
            size: AppSizes.iconBase,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
        ),
        style: AppTypography.body2.copyWith(color: colorScheme.onSurface),
      ),
    );
  }
}
