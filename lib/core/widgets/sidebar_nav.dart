import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../navigation/app_router.dart';
import '../navigation/navigation_service.dart';

/// Sidebar Navigation - Icon-only dark slate design from reference
/// Fixed width 80dp
class SidebarNav extends StatelessWidget {
  final String activeRoute;

  const SidebarNav({super.key, this.activeRoute = '/'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.sidebarWidth,
      decoration: const BoxDecoration(color: AppColors.sidebarBg),
      child: Column(
        children: [
          // Logo/Header
          Container(
            height: AppSizes.appBarHeight,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sidebarItemPaddingV,
            ),
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: [
                _NavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: AppRouter.dashboard,
                  isActive: activeRoute == AppRouter.dashboard,
                ),
                _NavItem(
                  icon: Icons.restaurant_menu,
                  label: 'Menu',
                  route: AppRouter.menu,
                  isActive: activeRoute == AppRouter.menu,
                ),
                _NavItem(
                  icon: Icons.receipt_long,
                  label: 'Orders',
                  route: AppRouter.orders,
                  isActive: activeRoute == AppRouter.orders,
                ),
                _NavItem(
                  icon: Icons.table_bar,
                  label: 'Tables',
                  route: AppRouter.tables,
                  isActive: activeRoute == AppRouter.tables,
                ),
                _NavItem(
                  icon: Icons.delivery_dining,
                  label: 'Delivery',
                  route: AppRouter.delivery,
                  isActive: activeRoute == AppRouter.delivery,
                ),
              ],
            ),
          ),

          // Bottom items
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              children: [
                _NavItem(
                  icon: Icons.bar_chart,
                  label: 'Reports',
                  route: AppRouter.reports,
                  isActive: activeRoute == AppRouter.reports,
                ),
                _NavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  route: AppRouter.settings,
                  isActive: activeRoute == AppRouter.settings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.isActive = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sidebarItemPaddingH,
        vertical: 4,
      ),
      child: Tooltip(
        message: widget.label,
        preferBelow: false,
        verticalOffset: 0,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Material(
            color: widget.isActive
                ? AppColors.sidebarItemActive.withValues(alpha: 0.12)
                : (_isHovered
                      ? AppColors.sidebarItemHover
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              onTap: () => NavigationService.pushNamed(widget.route),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  widget.icon,
                  color: widget.isActive
                      ? AppColors.sidebarItemActive
                      : (_isHovered
                            ? AppColors.sidebarText
                            : AppColors.sidebarTextMuted),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
