import 'package:flutter/foundation.dart';
import 'package:ozpos_flutter/core/config/app_config.dart';

/// Sentry configuration for the OZPOS application
class SentryConfig {
  /// Sentry DSN for error reporting
  /// Can be overridden with --dart-define=SENTRY_DSN=your_dsn
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue:
        'https://5043c056bceb3ca2e4a92d2e6e2b0235@o4509604948869120.ingest.us.sentry.io/4510112203341824',
  );

  /// App version for Sentry releases
  static const String appVersion = '1.0.0+1';

  /// Check if we should enable Sentry error reporting
  static bool get enableSentry => true; // Always enabled for testing

  /// Get Sentry sample rates (automatically based on environment)
  static double get sentrySampleRate {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      return 1.0;
    } // 100% sampling in debug
    return 0.1; // 10% sampling in production
  }

  /// Get performance monitoring sample rate (automatically based on environment)
  static double get sentryPerformanceSampleRate {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      return 1.0; // 100% performance monitoring in debug
    }
    return 0.05; // 5% in production
  }

  /// Whether to attach screenshots to error reports (automatically based on environment)
  static bool get attachScreenshots =>
      !kIsWeb && AppConfig.instance.environment == AppEnvironment.development;

  /// Whether to attach view hierarchy to error reports (automatically based on environment)
  static bool get attachViewHierarchy =>
      AppConfig.instance.environment == AppEnvironment.development;

  /// Whether to enable debug logging in Sentry (automatically based on environment)
  static bool get sentryDebug =>
      AppConfig.instance.environment == AppEnvironment.development;

  /// Maximum number of breadcrumbs to keep (automatically based on environment)
  static int get maxBreadcrumbs {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      return 200; // More breadcrumbs for debugging
    }
    return 50; // Fewer breadcrumbs for production
  }

  /// Session tracking interval (automatically based on environment)
  static Duration get sessionTrackingInterval {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      return const Duration(seconds: 10); // Frequent tracking in debug
    }
    return const Duration(minutes: 2); // Less frequent in production
  }

  /// Get build configuration for Sentry
  static Map<String, dynamic> get buildConfig => {
        'environment': AppConfig.instance.environment.name,
        'debug': AppConfig.instance.environment == AppEnvironment.development,
        'version': appVersion,
        'build_time': DateTime.now().toIso8601String(),
        'platform': defaultTargetPlatform.name,
      };

  /// Print Sentry configuration summary
  static void printConfig() {
    if (kDebugMode) {
      print('🔧 Sentry Configuration:');
      print('   Enabled: $enableSentry');
      print('   Sample Rate: $sentrySampleRate');
      print('   Performance Sample Rate: $sentryPerformanceSampleRate');
      print('   Debug Logging: $sentryDebug');
      print('   Attach Screenshots: $attachScreenshots');
      print('   Max Breadcrumbs: $maxBreadcrumbs');
      print('');
    }
  }
}
