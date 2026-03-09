import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/auth/auth_cubit.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_responsive.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/widgets/sidebar_nav.dart';
import '../../../combos/presentation/widgets/debug_combo_builder_button.dart';
import '../../../customer_display/presentation/widgets/customer_display_button.dart';
import '../../../menu/presentation/bloc/menu_bloc.dart';
import '../../../menu/presentation/bloc/menu_event.dart';
import '../../../orders/presentation/bloc/orders_management_bloc.dart';
import '../../../orders/presentation/bloc/orders_management_event.dart';
import '../../../orders/presentation/widgets/active_orders_panel.dart';
import '../widgets/dashboard_tile.dart';
import '../../../../core/network/network_info.dart';

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
  bool _forceOffline = false;

  @override
  void initState() {
    super.initState();
    // Load menu from single-vendor API when dashboard initializes
    context.read<MenuBloc>().add(const FetchMenuEvent());
    // Sync local toggle with current debug override so the app
    // stays offline/online across navigations until the button is pressed.
    if (kDebugMode) {
      final networkInfo = di.sl<NetworkInfo>();
      if (networkInfo is NetworkInfoImpl) {
        _forceOffline = networkInfo.overrideIsConnected == false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrdersManagementBloc>(
      create: (_) =>
          di.sl<OrdersManagementBloc>()..add(const LoadOrdersEvent()),
      child: BlocProvider(
        create: (_) => DashboardViewCubit(),
        child: BlocBuilder<DashboardViewCubit, bool>(
          builder: (context, showRightPanel) {
            return ClampedTextScaling(
              child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  Expanded(child: _buildMainContent(context, showRightPanel)),

                  // Right panel (fixed on large/wide)
                  if (showRightPanel && context.showRightPanelFixed)
                    const ActiveOrdersPanel(),
                ],
              ),
            ),
          );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, bool showRightPanel) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Content with max width 1440dp on ultra-wide
          final maxWidth =
              context.isWide ? AppSizes.maxContentWidth : double.infinity;

          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      // Sticky App Bar
                      _buildSliverAppBar(context, showRightPanel),

                      // Grid of tiles
                      _buildSliverGrid(context),
                    ],
                  ),
                  if (kDebugMode)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: _buildDebugOfflineButton(context),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDebugOfflineButton(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'debug_offline_toggle',
      backgroundColor:
          _forceOffline ? Colors.red.withOpacity(0.9) : Colors.white,
      foregroundColor:
          _forceOffline ? Colors.white : AppColors.textSecondary,
      onPressed: () {
        setState(() {
          _forceOffline = !_forceOffline;
        });
        final networkInfo = di.sl<NetworkInfo>();
        if (networkInfo is NetworkInfoImpl) {
          networkInfo.setOverrideIsConnected(
            _forceOffline ? false : null,
          );
        }
      },
      tooltip: _forceOffline ? 'Offline (test)' : 'Online (test)',
      child: Icon(_forceOffline ? Icons.wifi_off : Icons.wifi, size: 18),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool showRightPanel) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
              Column(
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
                      Text(
                        'Billy\'s Burgers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Main Branch',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // Time and profile
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CustomerDisplayButton(),
                    const SizedBox(width: 8),
                    const DebugComboBuilderButton(),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      TimeOfDay.now().format(context),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                            context
                                .read<DashboardViewCubit>()
                                .toggleRightPanel();
                          }
                        },
                        icon: Icon(
                          context.isCompact || !showRightPanel
                              ? Icons.menu
                              : Icons.close,
                          color: AppColors.textSecondary,
                        ),
                        tooltip: 'Active Orders',
                      ),

                    // Profile dropdown (Logout)
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      offset: const Offset(0, 40),
                      icon: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.person,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      tooltip: 'Account',
                      onSelected: (value) {
                        if (value == 'logout') {
                          context.read<AuthCubit>().logout();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 20),
                              SizedBox(width: 12),
                              Text('Logout'),
                            ],
                          ),
                        ),
                      ],
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
        title: 'Pickup',
        subtitle: 'Quick pickup orders',
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
        NavigationService.pushNamed(AppRouter.settingsScreen);
        break;
      default:
        if (widget.onNavigate != null) {
          widget.onNavigate!(action);
        }
    }
  }
}

class DashboardViewCubit extends Cubit<bool> {
  DashboardViewCubit() : super(true);

  void toggleRightPanel() => emit(!state);

  void setRightPanelVisibility(bool isVisible) => emit(isVisible);
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
