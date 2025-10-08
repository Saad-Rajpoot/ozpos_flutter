import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/menu/presentation/screens/menu_editor_screen.dart';
import '../../features/docket/presentation/screens/docket_designer_screen.dart';
import '../../features/menu/presentation/screens/menu_item_wizard_screen.dart';
import '../../features/addons/presentation/screens/addon_categories_screen.dart';
import '../../features/addons/presentation/bloc/addon_management_bloc.dart';
import '../../features/addons/presentation/bloc/addon_management_event.dart';
import '../../core/di/injection_container.dart' as di;
import '../../features/menu/domain/entities/menu_item_edit_entity.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/menu/presentation/screens/menu_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/tables/presentation/screens/tables_screen.dart';
import '../../features/tables/presentation/screens/move_table_screen.dart';
import '../../features/tables/presentation/bloc/table_management_bloc.dart';
import '../../features/tables/presentation/bloc/table_management_event.dart';
import '../../features/delivery/presentation/screens/delivery_screen.dart';
import '../../features/reservations/presentation/screens/reservations_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/error_screen.dart';

/// Centralized route management
///
/// All navigation should go through AppRouter for consistency
/// Use NavigationService for context-free navigation
class AppRouter {
  // ========================================================================
  // ROUTE NAMES - ALL routes must be defined here
  // ========================================================================

  static const String dashboard = '/';
  static const String menu = '/menu';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String tables = '/tables';
  static const String delivery = '/delivery';
  static const String reservations = '/reservations';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String menuEditor = '/menu-editor';
  static const String docketDesigner = '/docket-designer';
  static const String menuItemWizard = '/menu-item-wizard';
  static const String moveTable = '/move-table';
  static const String addonManagement = '/addon-management';

  // ========================================================================
  // ROUTE GENERATOR
  // ========================================================================

  /// Generate routes based on route settings
  ///
  /// Arguments can be passed via settings.arguments
  /// Example: NavigationService.pushNamed(AppRouter.menu, arguments: {'orderType': 'takeaway'})
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments if any
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );

      case menu:
        return MaterialPageRoute(
          builder: (_) => MenuScreen(orderType: args?['orderType'] as String?),
          settings: settings,
        );

      case checkout:
        return MaterialPageRoute(
          builder: (_) => const CheckoutScreen(),
          settings: settings,
        );

      case orders:
        return MaterialPageRoute(
          builder: (_) => const OrdersScreen(),
          settings: settings,
        );

      case tables:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<TableManagementBloc>.value(
            value: di.sl<TableManagementBloc>()..add(const LoadTablesEvent()),
            child: const TablesScreen(),
          ),
          settings: settings,
        );

      case delivery:
        return MaterialPageRoute(
          builder: (_) => const DeliveryScreen(),
          settings: settings,
        );

      case reservations:
        return MaterialPageRoute(
          builder: (_) => const ReservationsScreen(),
          settings: settings,
        );

      case reports:
        return MaterialPageRoute(
          builder: (_) => const ReportsScreen(),
          settings: settings,
        );

      case AppRouter.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      case menuEditor:
        return MaterialPageRoute(
          builder: (_) => const MenuEditorScreen(),
          settings: settings,
        );

      case docketDesigner:
        return MaterialPageRoute(
          builder: (_) => const DocketDesignerScreen(),
          settings: settings,
        );

      case menuItemWizard:
        return MaterialPageRoute(
          builder: (_) => MenuItemWizardScreen(
            existingItem: args?['existingItem'] as MenuItemEditEntity?,
            isDuplicate: args?['isDuplicate'] as bool? ?? false,
          ),
          settings: settings,
        );

      case moveTable:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<TableManagementBloc>.value(
            value: di.sl<TableManagementBloc>()
              ..add(const LoadMoveAvailableTablesEvent()),
            child: MoveTableScreen(sourceTable: args?['sourceTable']),
          ),
          settings: settings,
        );

      case addonManagement:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AddonManagementBloc>.value(
            value: di.sl<AddonManagementBloc>()
              ..add(const LoadAddonCategoriesEvent()),
            child: const AddonCategoriesScreen(),
          ),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const ErrorScreen(),
          settings: settings,
        );
    }
  }
}
