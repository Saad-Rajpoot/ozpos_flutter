import 'dart:async';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Service for configuring and managing Sentry error tracking
class SentryService {
  /// Report an error to Sentry with additional context
  static Future<void> reportError(
    dynamic error,
    dynamic stackTrace, {
    String? hint,
    Map<String, dynamic>? extra,
    SentryLevel level = SentryLevel.error,
  }) async {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (hint != null) {
          scope.addBreadcrumb(Breadcrumb(
            message: hint,
            level: level,
            timestamp: DateTime.now(),
          ));
        }

        if (extra != null) {
          for (final entry in extra.entries) {
            scope.setTag('extra_${entry.key}', entry.value.toString());
          }
        }
      },
    );
  }

  /// Report a custom message to Sentry
  static Future<void> reportMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? extra,
    Map<String, String>? tags,
  }) async {
    await Sentry.captureMessage(
      message,
      level: level,
      withScope: (scope) {
        if (extra != null) {
          for (final entry in extra.entries) {
            scope.setTag('extra_${entry.key}', entry.value.toString());
          }
        }

        if (tags != null) {
          for (final entry in tags.entries) {
            scope.setTag(entry.key, entry.value);
          }
        }
      },
    );
  }

  /// Add a breadcrumb for debugging
  static void addBreadcrumb({
    required String message,
    String? category,
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? data,
  }) {
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: category,
      level: level,
      data: data,
      timestamp: DateTime.now(),
    ));
  }

  /// Set user context for error tracking
  static Future<void> setUser({
    String? id,
    String? email,
    String? username,
    Map<String, dynamic>? extras,
  }) async {
    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: id,
        email: email,
        username: username,
        data: extras,
      ));
    });
  }

  /// Clear user context
  static Future<void> clearUser() async {
    await Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  /// Set custom context for errors
  static Future<void> setContext(
      String key, Map<String, dynamic> context) async {
    await Sentry.configureScope((scope) {
      // Use setTag for simple key-value pairs or handle context differently
      for (final entry in context.entries) {
        scope.setTag('${key}_${entry.key}', entry.value.toString());
      }
    });
  }

  /// Set a custom tag
  static Future<void> setTag(String key, String value) async {
    await Sentry.configureScope((scope) {
      scope.setTag(key, value);
    });
  }

  /// Performance monitoring - start a transaction
  static ISentrySpan startTransaction(
    String name,
    String operation, {
    String? description,
    Map<String, dynamic>? data,
  }) {
    return Sentry.startTransaction(
      name,
      operation,
      description: description,
    )..setData('custom_data', data ?? {});
  }

  /// Performance monitoring - start a span
  static ISentrySpan startSpan(
    String operation, {
    String? description,
    ISentrySpan? parent,
  }) {
    if (parent != null) {
      return parent.startChild(operation, description: description);
    }
    return Sentry.getSpan()?.startChild(operation, description: description) ??
        Sentry.startTransaction('manual', operation);
  }

  /// Business logic error tracking for POS operations
  static Future<void> reportPOSError(
    String operation,
    dynamic error,
    dynamic stackTrace, {
    String? orderId,
    String? tableId,
    Map<String, dynamic>? context,
  }) async {
    await reportError(
      error,
      stackTrace,
      hint: 'POS Operation Failed: $operation',
      extra: {
        'operation': operation,
        'order_id': orderId,
        'table_id': tableId,
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
      level: SentryLevel.error,
    );
  }

  /// Payment error tracking
  static Future<void> reportPaymentError(
    String paymentMethod,
    dynamic error,
    dynamic stackTrace, {
    String? transactionId,
    double? amount,
    String? currency,
  }) async {
    await reportError(
      error,
      stackTrace,
      hint: 'Payment Processing Failed',
      extra: {
        'payment_method': paymentMethod,
        'transaction_id': transactionId,
        'amount': amount,
        'currency': currency,
        'timestamp': DateTime.now().toIso8601String(),
      },
      level: SentryLevel.error,
    );
  }

  /// Network error tracking
  static Future<void> reportNetworkError(
    String endpoint,
    int? statusCode,
    dynamic error,
    dynamic stackTrace,
  ) async {
    await reportError(
      error,
      stackTrace,
      hint: 'Network Request Failed',
      extra: {
        'endpoint': endpoint,
        'status_code': statusCode,
        'timestamp': DateTime.now().toIso8601String(),
      },
      level: statusCode != null && statusCode >= 500
          ? SentryLevel.error
          : SentryLevel.warning,
    );
  }

  /// Database error tracking
  static Future<void> reportDatabaseError(
    String operation,
    dynamic error,
    dynamic stackTrace, {
    String? query,
    Map<String, dynamic>? parameters,
  }) async {
    await reportError(
      error,
      stackTrace,
      hint: 'Database Operation Failed',
      extra: {
        'operation': operation,
        'query': query,
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
      },
      level: SentryLevel.error,
    );
  }
}
