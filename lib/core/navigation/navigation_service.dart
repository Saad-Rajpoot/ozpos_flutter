import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Navigation Service - Context-free navigation using GlobalKey
///
/// Usage:
/// ```dart
/// NavigationService.push(AppRouter.menu);
/// NavigationService.pushNamed(AppRouter.checkout, arguments: {...});
/// NavigationService.pop();
/// ```
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Current navigator context; null until the widget tree attaches the key.
  static BuildContext? get context => navigatorKey.currentContext;

  /// Current navigator instance; null until the widget tree attaches the key.
  static NavigatorState? get navigator => navigatorKey.currentState;

  static void _logNavigatorMissing(String method) {
    debugPrint(
      'NavigationService.$method ignored: navigator is not ready yet.',
    );
  }

  static void _logContextMissing(String method) {
    debugPrint(
      'NavigationService.$method ignored: context is not ready yet.',
    );
  }

  // ========================================================================
  // NAVIGATION METHODS
  // ========================================================================

  /// Push a route by name
  static Future<T?> push<T>(String routeName) {
    final nav = navigator;
    if (nav == null) {
      _logNavigatorMissing('push');
      return Future.value(null);
    }
    return nav.pushNamed<T>(routeName);
  }

  /// Push a route by name with arguments
  static Future<T?> pushNamed<T>(
    String routeName, {
    Object? arguments,
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
  }) {
    final nav = navigator;
    if (nav == null) {
      _logNavigatorMissing('pushNamed');
      return Future.value(null);
    }
    return nav.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Pop the current route
  static void pop<T>([T? result]) {
    final nav = navigator;
    if (nav == null) {
      _logNavigatorMissing('pop');
      return;
    }
    if (nav.canPop()) {
      nav.pop<T>(result);
    }
  }

  /// Pop until a specific route
  static void popUntil(String routeName) {
    final nav = navigator;
    if (nav == null) {
      _logNavigatorMissing('popUntil');
      return;
    }
    nav.popUntil(ModalRoute.withName(routeName));
  }

  /// Replace current route with a new one
  static Future<T?> replace<T>(String routeName) {
    final nav = navigator;
    if (nav == null) {
      _logNavigatorMissing('replace');
      return Future.value(null);
    }
    return nav.pushReplacementNamed<T, dynamic>(routeName);
  }

  /// Replace current route with arguments
  static Future<T?> replaceNamed<T>(
    String routeName, {
    Object? arguments,
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
  }) {
    final nav = navigator;
    if (nav == null) {
      _logNavigatorMissing('replaceNamed');
      return Future.value(null);
    }
    return nav.pushReplacementNamed<T, dynamic>(
      routeName,
      arguments: arguments,
    );
  }

  /// Push and remove all previous routes
  static Future<T?> pushAndRemoveUntil<T>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    final nav = navigator;
    if (nav == null) {
      _logNavigatorMissing('pushAndRemoveUntil');
      return Future.value(null);
    }
    return nav.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  /// Push and remove all routes until the first route
  static Future<T?> pushAndClearStack<T>(
    String routeName, {
    Object? arguments,
  }) {
    final nav = navigator;
    if (nav == null) {
      _logNavigatorMissing('pushAndClearStack');
      return Future.value(null);
    }
    return nav.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  // ========================================================================
  // UTILITY METHODS
  // ========================================================================

  /// Check if we can pop the current route
  static bool canPop() {
    final nav = navigator;
    if (nav == null) {
      return false;
    }
    return nav.canPop();
  }

  /// Get the current route name
  static String getCurrentLocation() {
    final ctx = context;
    if (ctx == null) {
      return '';
    }
    return ModalRoute.of(ctx)?.settings.name ?? '';
  }

  /// Check if the current route matches the given route name
  static bool isCurrentRoute(String routeName) {
    return getCurrentLocation() == routeName;
  }

  /// Get the current route arguments
  static Object? getCurrentArguments() {
    final ctx = context;
    if (ctx == null) {
      return null;
    }
    return ModalRoute.of(ctx)?.settings.arguments;
  }

  /// Show a dialog
  static Future<T?> showAppDialog<T>({
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) {
    final ctx = context;
    if (ctx == null) {
      _logContextMissing('showAppDialog');
      return Future.value(null);
    }
    return showDialog<T>(
      context: ctx,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  /// Show a bottom sheet
  static Future<T?> showAppBottomSheet<T>({
    required Widget Function(BuildContext) builder,
    bool isDismissible = true,
  }) {
    final ctx = context;
    if (ctx == null) {
      _logContextMissing('showAppBottomSheet');
      return Future.value(null);
    }
    return showModalBottomSheet<T>(
      context: ctx,
      isDismissible: isDismissible,
      builder: builder,
    );
  }

  /// Show a snackbar
  static void showSnackBar(
    String message, {
    Color? backgroundColor,
    Duration duration = AppConstants.snackbarDefaultDuration,
  }) {
    final ctx = context;
    if (ctx == null) {
      _logContextMissing('showSnackBar');
      return;
    }
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show an error snackbar
  static void showError(String message) {
    showSnackBar(message, backgroundColor: const Color(0xFFEF4444));
  }

  /// Show a success snackbar
  static void showSuccess(String message) {
    showSnackBar(message, backgroundColor: const Color(0xFF10B981));
  }
}
