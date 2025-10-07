import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/responsive.dart';
import '../../../menu/presentation/bloc/menu_bloc.dart';
import '../../../pos/presentation/widgets/dashboard_tile.dart';
import '../../../pos/presentation/widgets/active_orders_panel.dart';
import '../../../../core/widgets/sidebar_nav.dart';

/// Dashboard Screen - Pixel-perfect match to reference image
/// Responsive breakpoints:
/// - compact (\u2264900dp): 2 columns, right panel as drawer
/// - medium (901-1279dp): 3 columns, right panel toggleable
/// - large (\u22651280dp): 4 columns, right panel fixed 360dp
/// - wide (\u22651600dp): 4 columns, content max 1440dp centered
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
  bool _showRightPanel = true; // Default open on desktop

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
        backgroundColor: AppColors.bgPrimary,
        // Right drawer for compact breakpoint
        endDrawer: context.isCompact
            ? Drawer(
                width: MediaQuery.of(context).size.width * 0.85,
                child: const ActiveOrdersPanel(),
              )
            : null,
        body: Row(
          children: [
            // Left Sidebar (fixed 80dp) - always show on desktop
            if (context.isDesktopOrLarger)
              const SidebarNav(activeRoute: AppRouter.dashboard),

            // Main content area
            Expanded(child: _buildMainContent(context)),

            // Right panel (fixed on large/wide)
            if (_showRightPanel && context.showRightPanelFixed)
              const ActiveOrdersPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Container(
      color: AppColors.bgPrimary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Content with max width 1440dp on ultra-wide
          final maxWidth = context.isWide
              ? AppSizes.maxContentWidth
              : double.infinity;

          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: CustomScrollView(
                slivers: [
                  // Sticky App Bar
                  _buildSliverAppBar(context),

                  // Grid of tiles
                  _buildSliverGrid(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.bgPrimary,
      elevation: 0,
      pinned: true,
      toolbarHeight: AppSizes.appBarHeight,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.pageHorizontalPadding,
            vertical: 8,
          ),
          child: Row(
            children: [
              // Restaurant info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.restaurant,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Billy\'s Burgers',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Main Branch',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Time and profile
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Time
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      TimeOfDay.now().format(context),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right panel toggle (tablet/desktop)
                    if (context.showRightPanelToggle)
                      IconButton(
                        onPressed: () {
                          if (context.isCompact) {
                            _scaffoldKey.currentState?.openEndDrawer();
                          } else {
                            setState(() {
                              _showRightPanel = !_showRightPanel;
                            });
                          }
                        },
                        icon: Icon(
                          context.isCompact || !_showRightPanel
                              ? Icons.menu
                              : Icons.close,
                          color: AppColors.textSecondary,
                        ),
                        tooltip: 'Active Orders',
                      ),

                    // Profile
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverGrid(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.all(context.pageHorizontalPadding),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.gridColumns,
          childAspectRatio: AppSizes.tileAspectRatio,
          crossAxisSpacing: AppSpacing.gridGap,
          mainAxisSpacing: AppSpacing.gridGap,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final tiles = _getDashboardTiles();
          if (index >= tiles.length) return null;
          final tile = tiles[index];
          return DashboardTile(
            title: tile.title,
            subtitle: tile.subtitle,
            icon: tile.icon,
            gradient: tile.gradient,
            onTap: () => _handleTileTap(tile.action, context),
          );
        }, childCount: _getDashboardTiles().length),
      ),
    );
  }

  List<_TileData> _getDashboardTiles() {
    return [
      _TileData(
        title: 'Takeaway',
        subtitle: 'Quick takeaway orders',
        icon: Icons.shopping_bag,
        gradient: const LinearGradient(
          colors: [AppColors.tileTakeaway, AppColors.tileTakeawayEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        action: 'takeaway',
      ),
      _TileData(
        title: 'Dine In',
        subtitle: 'Dine in service',
        icon: Icons.restaurant,
        gradient: const LinearGradient(
          colors: [AppColors.tileDineIn, AppColors.tileDineInEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        action: 'dine-in',
      ),
      _TileData(
        title: 'Tables',
        subtitle: 'Manage tables',
        icon: Icons.table_restaurant,
        gradient: const LinearGradient(
          colors: [AppColors.tileTables, AppColors.tileTablesEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        action: 'tables',
      ),
      _TileData(
        title: 'Delivery',
        subtitle: 'Delivery Service',
        icon: Icons.delivery_dining,
        gradient: const LinearGradient(
          colors: [AppColors.tileDelivery, AppColors.tileDeliveryEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        action: 'delivery',
      ),
      _TileData(
        title: 'Reservations',
        subtitle: 'Booking management',
        icon: Icons.calendar_month,
        gradient: const LinearGradient(
          colors: [AppColors.tileReservations, AppColors.tileReservationsEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        action: 'reservations',
      ),
      _TileData(
        title: 'Edit Menu',
        subtitle: 'Update menu items',
        icon: Icons.edit_note,
        gradient: const LinearGradient(
          colors: [AppColors.tileEditMenu, AppColors.tileEditMenuEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        action: 'menu-editor',
      ),
      _TileData(
        title: 'Reports',
        subtitle: 'Sales analytics',
        icon: Icons.bar_chart,
        gradient: const LinearGradient(
          colors: [AppColors.tileReports, AppColors.tileReportsEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        action: 'reports',
      ),
      _TileData(
        title: 'Settings',
        subtitle: 'System configuration',
        icon: Icons.settings,
        gradient: const LinearGradient(
          colors: [AppColors.tileSettings, AppColors.tileSettingsEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        action: 'settings',
      ),
    ];
  }

  void _handleTileTap(String action, BuildContext context) {
    switch (action) {
      case 'takeaway':
        NavigationService.pushNamed(
          AppRouter.menu,
          arguments: {'orderType': 'takeaway'},
        );
        break;
      case 'dine-in':
        NavigationService.pushNamed(
          AppRouter.menu,
          arguments: {'orderType': 'dine-in'},
        );
        break;
      case 'delivery':
        NavigationService.pushNamed(
          AppRouter.menu,
          arguments: {'orderType': 'delivery'},
        );
        break;
      case 'tables':
        NavigationService.pushNamed(AppRouter.tables);
        break;
      case 'reservations':
        NavigationService.pushNamed(AppRouter.reservations);
        break;
      case 'menu-editor':
        NavigationService.pushNamed(AppRouter.menuEditor);
        break;
      case 'reports':
        NavigationService.pushNamed(AppRouter.reports);
        break;
      case 'settings':
        NavigationService.pushNamed(AppRouter.settings);
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
