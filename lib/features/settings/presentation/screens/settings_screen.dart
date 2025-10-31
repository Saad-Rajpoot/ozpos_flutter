import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_state.dart';
import '../../../../core/navigation/app_router.dart';
import '../widgets/appearance_theme_section.dart';
import '../widgets/food_item_colors_preview.dart';
import '../widgets/expandable_category_list.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/status_overview_row.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Configuration'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SettingsError) {
            return Center(child: Text(state.message));
          }
          if (state is SettingsLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const AppearanceThemeSection(),
                const SizedBox(height: 16),
                const FoodItemColorsPreview(),
                const SizedBox(height: 24),
                const StatusOverviewRow(),
                const SizedBox(height: 24),
                ExpandableCategoryList(
                  categories: state.categories,
                  onAction: (action) => _handleItemTap(context, action),
                ),
                const SizedBox(height: 24),
                const QuickActionsRow(),
                const SizedBox(height: 24),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _handleItemTap(BuildContext context, String action) {
    if (action.startsWith('nav:')) {
      final route = action.substring(4);
      switch (route) {
        case 'docket-designer':
          Navigator.pushNamed(context, AppRouter.docketDesigner);
          break;
        case 'printing-management':
          Navigator.pushNamed(context, AppRouter.printingManagement);
          break;
        case 'menu-management':
          Navigator.pushNamed(context, AppRouter.menuEditor);
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unhandled nav: $route')),
          );
      }
    } else if (action.startsWith('toast:')) {
      final msg = action.substring(6);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }
}

// Obsolete inlined widgets removed; replaced by extracted widgets.

// Moved ExpandableCategoryList to widgets/expandable_category_list.dart

// Moved CategoryCard to widgets/expandable_category_list.dart

// Moved CategoryItemTile to widgets/expandable_category_list.dart

// Moved QuickActionsRow to widgets/quick_actions_row.dart

// Moved QuickAction helpers to widgets/quick_actions_row.dart

// Moved StatusOverviewRow to widgets/status_overview_row.dart

// Moved StatusCard to widgets/status_overview_row.dart
