import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_responsive.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../dashboard/presentation/widgets/dashboard_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = context.isWide ? 1440.0 : double.infinity;

          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: CustomScrollView(
                slivers: [
                  // Grid of settings tiles
                  SliverPadding(
                    padding: EdgeInsets.all(context.pageHorizontalPadding),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.gridColumns,
                        childAspectRatio: 1.8,
                        crossAxisSpacing: AppSpacing.gridGap,
                        mainAxisSpacing: AppSpacing.gridGap,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tiles = _getSettingsTiles();
                          if (index >= tiles.length) return null;
                          final tile = tiles[index];
                          return DashboardTile(
                            title: tile.title,
                            subtitle: tile.subtitle,
                            icon: tile.icon,
                            gradient: tile.gradient,
                            onTap: () => _handleTileTap(tile.action, context),
                          );
                        },
                        childCount: _getSettingsTiles().length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<_SettingsTileData> _getSettingsTiles() {
    return [
      _SettingsTileData(
        title: 'Printer Management',
        subtitle: 'Manage network and Bluetooth printers',
        icon: Icons.print,
        gradient: const LinearGradient(
          colors: [AppColors.tilePrinting, AppColors.tilePrintingEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        action: 'printing',
      ),
      _SettingsTileData(
        title: 'General Settings',
        subtitle: 'App preferences and configuration',
        icon: Icons.settings_applications,
        gradient: const LinearGradient(
          colors: [AppColors.tileGeneral, AppColors.tileGeneralEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        action: 'general',
      ),
      _SettingsTileData(
        title: 'Database',
        subtitle: 'Manage local database',
        icon: Icons.storage,
        gradient: const LinearGradient(
          colors: [AppColors.tileDatabase, AppColors.tileDatabaseEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        action: 'database',
      ),
    ];
  }

  void _handleTileTap(String action, BuildContext context) {
    switch (action) {
      case 'printing':
        Navigator.pushNamed(context, AppRouter.printingManagement);
        break;
      case 'general':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coming soon')),
        );
        break;
      case 'database':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coming soon')),
        );
        break;
    }
  }
}

class _SettingsTileData {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final String action;

  _SettingsTileData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.action,
  });
}
