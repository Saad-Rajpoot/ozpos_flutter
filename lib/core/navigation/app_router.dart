import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/menu/presentation/screens/menu_editor_screen.dart';
import '../../features/menu/presentation/screens/menu_item_wizard_screen.dart';
import '../../features/addons/presentation/screens/addon_categories_screen.dart';
import '../../features/addons/presentation/bloc/addon_management_bloc.dart';
import '../../features/addons/presentation/bloc/addon_management_event.dart';
import '../../core/di/injection_container.dart' as di;
import '../../features/menu/domain/entities/menu_item_edit_entity.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/menu/presentation/screens/menu_screen.dart';
import '../../features/menu/presentation/bloc/menu_bloc.dart';
import '../../features/menu/presentation/bloc/menu_event.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/checkout/presentation/bloc/checkout_bloc.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/orders/presentation/bloc/orders_management_event.dart';
import '../../features/orders/presentation/bloc/orders_management_bloc.dart';
import '../../features/tables/presentation/screens/tables_screen.dart';
import '../../features/tables/presentation/screens/move_table_screen.dart';
import '../../features/tables/presentation/bloc/table_management_bloc.dart';
import '../../features/tables/presentation/bloc/table_management_event.dart';
import '../../features/delivery/presentation/screens/delivery_screen.dart';
import '../../features/delivery/presentation/bloc/delivery_bloc.dart';
import '../../features/delivery/presentation/bloc/delivery_event.dart';
import '../../features/reservations/presentation/screens/reservations_screen.dart';
import '../../features/reservations/presentation/bloc/reservation_management_bloc.dart';
import '../../features/reservations/presentation/bloc/reservation_management_event.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/reports/presentation/bloc/reports_event.dart';
import '../../features/reports/presentation/bloc/reports_bloc.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/settings/presentation/bloc/settings_event.dart';
import '../widgets/error_screen.dart';
import '../../features/docket/presentation/screens/docket_designer_screen.dart';
import '../../features/printing/presentation/bloc/printing_bloc.dart';
import '../../features/printing/presentation/bloc/printing_event.dart';
import '../../features/printing/presentation/screens/printing_management_screen.dart';
import '../../features/customer_display/presentation/screens/customer_display_screen.dart';
import '../../features/customer_display/presentation/bloc/customer_display_bloc.dart';
import '../../features/customer_display/presentation/bloc/customer_display_event.dart';
import '../../features/combos/presentation/bloc/crud/combo_crud_bloc.dart';
import '../../features/combos/presentation/bloc/filter/combo_filter_bloc.dart';
import '../../features/combos/presentation/bloc/editor/combo_editor_bloc.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/auth_splash_screen.dart';
import '../../core/auth/auth_cubit.dart';

/// Centralized route management
///
/// All navigation should go through AppRouter for consistency
/// Use NavigationService for context-free navigation
class AppRouter {
  // ========================================================================
  // ROUTE NAMES - ALL routes must be defined here
  // ========================================================================

  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/';
  static const String menu = '/menu';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String tables = '/tables';
  static const String delivery = '/delivery';
  static const String reservations = '/reservations';
  static const String reports = '/reports';
  static const String settingsScreen = '/settings-screen';
  static const String menuEditor = '/menu-editor';
  static const String menuItemWizard = '/menu-item-wizard';
  static const String moveTable = '/move-table';
  static const String addonManagement = '/addon-management';
  static const String docketDesigner = '/docket-designer';
  static const String printingManagement = '/printing-management';
  static const String customerDisplay = '/customer-display';
  static const Set<String> _publicRoutes = {splash, login};

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
    final requiresAuth = !_publicRoutes.contains(settings.name);
    if (requiresAuth) {
      final authCubit = di.sl<AuthCubit>();
      if (!authCubit.state.isAuthenticated) {
        return MaterialPageRoute(
          builder: (_) => LoginScreen(
            initialMessage: authCubit.state.message,
          ),
          settings: const RouteSettings(name: login),
        );
      }
    }

    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const AuthSplashScreen(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(
            initialMessage: args?['message'] as String?,
          ),
          settings: settings,
        );

      case dashboard:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<MenuBloc>(
            create: (_) => di.sl<MenuBloc>()..add(const LoadMenuData()),
            child: const DashboardScreen(),
          ),
          settings: settings,
        );

      case menu:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<MenuBloc>(
            create: (_) => di.sl<MenuBloc>()..add(const LoadMenuData()),
            child: MenuScreen(orderType: args?['orderType'] as String?),
          ),
          settings: settings,
        );

      case checkout:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<CheckoutBloc>(
            create: (_) => di.sl<CheckoutBloc>(),
            child: const CheckoutScreen(),
          ),
          settings: settings,
        );

      case orders:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<OrdersManagementBloc>(
            create: (_) =>
                di.sl<OrdersManagementBloc>()..add(const LoadOrdersEvent()),
            child: const OrdersScreen(),
          ),
          settings: settings,
        );

      case tables:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<TableManagementBloc>(
            create: (_) =>
                di.sl<TableManagementBloc>()..add(const LoadTablesEvent()),
            child: const TablesScreen(),
          ),
          settings: settings,
        );

      case delivery:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<DeliveryBloc>(
            create: (_) =>
                di.sl<DeliveryBloc>()..add(const LoadDeliveryDataEvent()),
            child: const DeliveryScreen(),
          ),
          settings: settings,
        );

      case reservations:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ReservationManagementBloc>(
            create: (_) => di.sl<ReservationManagementBloc>()
              ..add(const LoadReservationsEvent()),
            child: const ReservationsScreen(),
          ),
          settings: settings,
        );

      case reports:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ReportsBloc>(
            create: (_) =>
                di.sl<ReportsBloc>()..add(const LoadReportsDataEvent()),
            child: const ReportsScreen(),
          ),
          settings: settings,
        );

      case settingsScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<SettingsBloc>(
            create: (_) => di.sl<SettingsBloc>()..add(const LoadSettings()),
            child: const SettingsScreen(),
          ),
          settings: settings,
        );

      case menuEditor:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<MenuBloc>(
                create: (_) =>
                    di.sl<MenuBloc>()..add(const GetMenuItemsEvent()),
              ),
              BlocProvider<ComboCrudBloc>(
                create: (_) => di.sl<ComboCrudBloc>(),
              ),
              BlocProvider<ComboFilterBloc>(
                create: (context) => di.sl<ComboFilterBloc>(
                  param1: context.read<ComboCrudBloc>(),
                ),
              ),
              BlocProvider<ComboEditorBloc>(
                create: (context) => di.sl<ComboEditorBloc>(
                  param1: context.read<ComboCrudBloc>(),
                ),
              ),
            ],
            child: const MenuEditorScreen(),
          ),
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
          builder: (_) => BlocProvider<TableManagementBloc>(
            create: (_) => di.sl<TableManagementBloc>()
              ..add(const LoadMoveAvailableTablesEvent()),
            child: MoveTableScreen(sourceTable: args?['sourceTable']),
          ),
          settings: settings,
        );

      case addonManagement:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AddonManagementBloc>(
            create: (_) => di.sl<AddonManagementBloc>()
              ..add(const LoadAddonCategoriesEvent()),
            child: const AddonCategoriesScreen(),
          ),
          settings: settings,
        );

      case docketDesigner:
        return MaterialPageRoute(
          builder: (_) => const DocketDesignerScreen(),
          settings: settings,
        );

      case printingManagement:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<PrintingBloc>(
            create: (_) => di.sl<PrintingBloc>()..add(LoadPrinters()),
            child: const PrintingManagementScreen(),
          ),
          settings: settings,
        );

      case customerDisplay:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<CustomerDisplayBloc>(
            create: (_) => di.sl<CustomerDisplayBloc>()
              ..add(const CustomerDisplayOpened()),
            child: const CustomerDisplayScreen(),
          ),
          settings: settings,
          fullscreenDialog: true,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const ErrorScreen(),
          settings: settings,
        );
    }
  }
}
