import 'package:flutter/material.dart';
import '../../../../theme/tokens.dart';
import 'addon_management/addon_categories_screen.dart';

class MenuEditorScreen extends StatelessWidget {
  const MenuEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Editor'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Manage Add-on Categories',
            onPressed: () {
              Navigator.of(context).push(
                AddonCategoriesScreen.route(),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_note,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Menu Editor Screen',
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'This screen will allow editing menu items',
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  AddonCategoriesScreen.route(),
                );
              },
              icon: const Icon(Icons.category),
              label: const Text('Manage Add-on Categories'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
