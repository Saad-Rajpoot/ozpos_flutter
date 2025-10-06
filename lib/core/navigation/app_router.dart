import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../debug/sentry_test_screen.dart';
import '../debug/simple_sentry_test.dart';
import '../../features/pos/presentation/screens/dashboard_screen.dart';
import '../../features/pos/presentation/screens/menu_screen.dart';
import '../../features/pos/presentation/screens/menu_screen_new.dart';
import '../../features/pos/presentation/screens/checkout/checkout_screen_v2.dart';
import '../../features/pos/presentation/screens/orders/orders_screen_v2.dart';
import '../../features/pos/presentation/screens/tables/tables_screen_v2.dart';
import '../../features/pos/presentation/screens/delivery/delivery_screen.dart';
import '../../features/pos/presentation/screens/reservations/reservations_screen_v2.dart';
import '../../features/pos/presentation/screens/reports/reports_screen_v2.dart';
import '../../features/pos/presentation/screens/settings_screen.dart';
import '../../features/pos/presentation/screens/menu_editor_screen.dart';
import '../../features/pos/presentation/screens/menu_editor_screen_new.dart';
import '../../features/pos/presentation/screens/menu_editor_screen_v3.dart';
import '../../features/pos/presentation/screens/docket_designer_screen.dart';

/// Centralized route management
class AppRouter {
  // Route names - ALL routes must be defined here
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
  static const String sentryTest = '/sentry-test'; // Debug only
  static const String simpleSentryTest = '/simple-sentry-test'; // Debug only

  /// Generate routes based on route settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );

      case menu:
        return MaterialPageRoute(
          builder: (_) => const MenuScreenNew(),
          settings: settings,
        );

      case checkout:
        return MaterialPageRoute(
          builder: (_) => const CheckoutScreenV2(),
          settings: settings,
        );

      case orders:
        return MaterialPageRoute(
          builder: (_) => const OrdersScreenV2(),
          settings: settings,
        );

      case tables:
        return MaterialPageRoute(
          builder: (_) => const TablesScreenV2(),
          settings: settings,
        );

      case delivery:
        return MaterialPageRoute(
          builder: (_) => const DeliveryScreen(),
          settings: settings,
        );

      case reservations:
        return MaterialPageRoute(
          builder: (_) => const ReservationsScreenV2(),
          settings: settings,
        );

      case reports:
        return MaterialPageRoute(
          builder: (_) => const ReportsScreenV2(),
          settings: settings,
        );

      case AppRouter.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      case menuEditor:
        return MaterialPageRoute(
          builder: (_) => const MenuEditorScreenV3(),
          settings: settings,
        );

      case docketDesigner:
        return MaterialPageRoute(
          builder: (_) => const DocketDesignerScreen(),
          settings: settings,
        );

      case sentryTest:
        // Only available in debug mode
        if (kDebugMode) {
          return MaterialPageRoute(
            builder: (_) => const SentryTestScreen(),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => const ErrorScreen(),
          settings: settings,
        );

      case simpleSentryTest:
        // Always available - simple test
        return MaterialPageRoute(
          builder: (_) => const SimpleSentryTest(),
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

/// Error screen for unknown routes
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Page not found', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text(
              'The requested page could not be found.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
