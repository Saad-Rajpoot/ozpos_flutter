import 'package:flutter/foundation.dart';
import 'package:ozpos_flutter/core/config/app_config.dart';

/// Sentry configuration for the OZPOS application
class SentryConfig {
  /// Sentry DSN for error reporting
  ///
  /// **SECURITY**: Must be provided via --dart-define=SENTRY_DSN=your_dsn
  /// Never hard-code DSN values in source code as they will be exposed in compiled builds.
  ///
  /// Example build command:
  /// flutter build apk --dart-define=SENTRY_DSN=https://your-dsn@sentry.io/project-id
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  /// Check if Sentry DSN is configured
  static bool get isConfigured => sentryDsn.isNotEmpty;

  /// Get Sentry DSN with validation
  ///
  /// Throws [StateError] if DSN is not configured in production.
  /// Returns empty string in development if not configured (allows graceful degradation).
  static String get validatedDsn {
    if (sentryDsn.isEmpty) {
      if (AppConfig.instance.environment == AppEnvironment.production) {
        throw StateError(
          'SENTRY_DSN is required in production. '
          'Provide it via --dart-define=SENTRY_DSN=your_dsn',
        );
      }
      // In development, allow empty DSN (Sentry will be disabled)
      return '';
    }
    return sentryDsn;
  }

  /// App version for Sentry releases
  static const String appVersion = '1.0.0+1';

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
      if (isConfigured) {
        final preview = sentryDsn.length > 20
            ? '${sentryDsn.substring(0, 20)}...'
            : sentryDsn;
        print('   DSN: Configured ($preview)');
      } else {
        print('   DSN: ⚠️  NOT CONFIGURED (Sentry disabled)');
        print('   To enable: --dart-define=SENTRY_DSN=your_dsn');
      }
      print('   Sample Rate: $sentrySampleRate');
      print('   Performance Sample Rate: $sentryPerformanceSampleRate');
      print('   Debug Logging: $sentryDebug');
      print('   Attach Screenshots: $attachScreenshots');
      print('   Max Breadcrumbs: $maxBreadcrumbs');
      print('');
    }
  }
}
