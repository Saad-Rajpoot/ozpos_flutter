import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../theme/tokens.dart';
import '../../../../utils/responsive.dart';
import '../bloc/menu_bloc.dart';
import '../../../../widgets/dashboard_tile.dart';
import '../../../../widgets/active_orders_panel.dart';
import '../../../../widgets/sidebar_nav.dart';

class DashboardScreen extends StatefulWidget {
  final Function(String)? onNavigate;
  final String activeSection;
  final bool showOwnSidebar;

  const DashboardScreen({
    this.onNavigate,
    this.activeSection = 'dashboard',
    this.showOwnSidebar = false,
    super.key,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showRightPanel = false;

  @override
  void initState() {
    super.initState();
    // Load menu data when dashboard initializes
    context.read<MenuBloc>().add(GetMenuItemsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return ClampedTextScaling(
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: context.isCompact
            ? Drawer(
                width: MediaQuery.of(context).size.width * 0.85,
                child: ActiveOrdersPanel(
                ),
              )
            : null,
        body: Row(
          children: [
            if (widget.showOwnSidebar && context.isDesktopOrLarger)
              SidebarNav(
              ),
            Expanded(
              child: Container(
                color: AppColors.bgPrimary,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.bgGradientStart,
                        AppColors.bgGradientMid.withOpacity(0.3),
                        AppColors.bgGradientEnd.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMainContent(context),
                      ),
                      if (_showRightPanel && context.isTabletOrLarger)
                        ActiveOrdersPanel(
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(context),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: _buildTilesGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: AppTypography.heading1.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Welcome back! Here\'s what\'s happening today.',
                style: AppTypography.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (context.isTabletOrLarger)
          IconButton(
            onPressed: () {
              setState(() {
                _showRightPanel = !_showRightPanel;
              });
            },
            icon: Icon(
              _showRightPanel ? Icons.close : Icons.menu,
              color: AppColors.textSecondary,
            ),
          ),
        if (context.isCompact)
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
            icon: const Icon(Icons.menu),
          ),
      ],
    );
  }

  Widget _buildTilesGrid(BuildContext context) {
    final tiles = _getDashboardTiles(context);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isCompact ? 2 : 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return DashboardTile(
          title: tile.title,
          subtitle: tile.subtitle,
          icon: tile.icon,
          gradient: tile.gradient,
          onTap: () => _handleTileTap(tile.action, context),
        );
      },
    );
  }

  List<_TileData> _getDashboardTiles(BuildContext context) {
    return [
      _TileData(
        title: 'New Order',
        subtitle: 'Start taking orders',
        icon: Icons.add_shopping_cart,
        gradient: const LinearGradient(
          colors: [AppColors.textPrimary, AppColors.textSecondary],
        ),
        action: 'new-order',
      ),
      _TileData(
        title: 'Takeaway',
        subtitle: 'Pickup orders',
        icon: Icons.takeout_dining,
        gradient: const LinearGradient(
          colors: [AppColors.tileTakeaway, AppColors.tileTakeawayEnd],
        ),
        action: 'takeaway',
      ),
      _TileData(
        title: 'Dine In',
        subtitle: 'Table service',
        icon: Icons.table_restaurant,
        gradient: const LinearGradient(
          colors: [AppColors.tileDineIn, AppColors.tileDineInEnd],
        ),
        action: 'dine-in',
      ),
      _TileData(
        title: 'Delivery',
        subtitle: 'Delivery orders',
        icon: Icons.delivery_dining,
        gradient: const LinearGradient(
          colors: [AppColors.tileDelivery, AppColors.tileDeliveryEnd],
        ),
        action: 'delivery',
      ),
      _TileData(
        title: 'Orders',
        subtitle: 'View all orders',
        icon: Icons.list_alt,
        gradient:  LinearGradient(
          colors: [AppColors.tileDineIn, AppColors.tileDineInEnd],
        ),
        action: 'orders',
      ),
      _TileData(
        title: 'Tables',
        subtitle: 'Manage tables',
        icon: Icons.table_chart,
        gradient: const LinearGradient(
          colors: [AppColors.tileTables, AppColors.tileTablesEnd],
        ),
        action: 'tables',
      ),
      _TileData(
        title: 'Reports',
        subtitle: 'View analytics',
        icon: Icons.analytics,
        gradient: const LinearGradient(
          colors: [AppColors.tileReports, AppColors.tileReportsEnd],
        ),
        action: 'reports',
      ),
      _TileData(
        title: 'Settings',
        subtitle: 'App settings',
        icon: Icons.settings,
        gradient: const LinearGradient(
          colors: [AppColors.tileSettings, AppColors.tileSettingsEnd],
        ),
        action: 'settings',
      ),
    ];
  }

  void _handleTileTap(String action, BuildContext context) {
    switch (action) {
      case 'new-order':
        Navigator.pushNamed(context, AppRouter.menu);
        break;
      case 'takeaway':
        Navigator.pushNamed(context, AppRouter.menu);
        break;
      case 'dine-in':
        Navigator.pushNamed(context, AppRouter.tables);
        break;
      case 'delivery':
        Navigator.pushNamed(context, AppRouter.delivery);
        break;
      case 'orders':
        Navigator.pushNamed(context, AppRouter.orders);
        break;
      case 'tables':
        Navigator.pushNamed(context, AppRouter.tables);
        break;
      case 'reports':
        Navigator.pushNamed(context, AppRouter.reports);
        break;
      case 'settings':
        Navigator.pushNamed(context, AppRouter.settings);
        break;
      default:
        if (widget.onNavigate != null) {
          widget.onNavigate!(action);
        }
    }
  }
}

class _TileData {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final String action;

  _TileData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.action,
  });
}
