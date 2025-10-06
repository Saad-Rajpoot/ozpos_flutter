import 'package:flutter/material.dart';

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

  static BuildContext get context => navigatorKey.currentContext!;

  static NavigatorState get navigator => navigatorKey.currentState!;

  // ========================================================================
  // NAVIGATION METHODS
  // ========================================================================

  /// Navigate to a route by name
  static Future<T?> go<T>(String routeName) {
    return navigator.pushNamed<T>(routeName);
  }

  /// Navigate to a route by name with arguments
  static Future<T?> goNamed<T>(
    String routeName, {
    Object? arguments,
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
  }) {
    return navigator.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Push a route by name
  static Future<T?> push<T>(String routeName) {
    return navigator.pushNamed<T>(routeName);
  }

  /// Push a route by name with arguments
  static Future<T?> pushNamed<T>(
    String routeName, {
    Object? arguments,
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
  }) {
    return navigator.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Pop the current route
  static void pop<T>([T? result]) {
    if (canPop()) {
      navigator.pop<T>(result);
    }
  }

  /// Pop until a specific route
  static void popUntil(String routeName) {
    navigator.popUntil(ModalRoute.withName(routeName));
  }

  /// Replace current route with a new one
  static Future<T?> replace<T>(String routeName) {
    return navigator.pushReplacementNamed<T, dynamic>(routeName);
  }

  /// Replace current route with arguments
  static Future<T?> replaceNamed<T>(
    String routeName, {
    Object? arguments,
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
  }) {
    return navigator.pushReplacementNamed<T, dynamic>(
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
    return navigator.pushNamedAndRemoveUntil<T>(
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
    return navigator.pushNamedAndRemoveUntil<T>(
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
    return navigator.canPop();
  }

  /// Get the current route name
  static String getCurrentLocation() {
    return ModalRoute.of(context)?.settings.name ?? '';
  }

  /// Check if the current route matches the given route name
  static bool isCurrentRoute(String routeName) {
    return getCurrentLocation() == routeName;
  }

  /// Get the current route arguments
  static Object? getCurrentArguments() {
    return ModalRoute.of(context)?.settings.arguments;
  }

  /// Show a dialog
  static Future<T?> showAppDialog<T>({
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  /// Show a bottom sheet
  static Future<T?> showAppBottomSheet<T>({
    required Widget Function(BuildContext) builder,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      builder: builder,
    );
  }

  /// Show a snackbar
  static void showSnackBar(
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
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
