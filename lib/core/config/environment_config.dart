import 'package:flutter/foundation.dart';

/// Environment configuration for the OZPOS application
class EnvironmentConfig {
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'debug',
  );

  /// Current environment (debug, staging, production)
  static String get environment => _environment;

  /// Check if we're in debug mode
  static bool get isDebug => kDebugMode || _environment == 'debug';

  /// Check if we're in staging environment
  static bool get isStaging => _environment == 'staging';

  /// Check if we're in production environment
  static bool get isProduction => _environment == 'production';

  /// Check if we should enable Sentry error reporting
  static bool get enableSentry => true; // Always enabled for testing

  /// Sentry DSN for error reporting
  /// Can be overridden with --dart-define=SENTRY_DSN=your_dsn
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue:
        'https://5043c056bceb3ca2e4a92d2e6e2b0235@o4509604948869120.ingest.us.sentry.io/4510112203341824',
  );

  /// App version for Sentry releases
  static const String appVersion = '1.0.0+1';

  /// Get Sentry sample rates based on environment
  static double get sentrySampleRate {
    if (isDebug) return 1.0; // 100% sampling in debug
    if (isStaging) return 0.5; // 50% sampling in staging
    return 0.1; // 10% sampling in production
  }

  /// Get performance monitoring sample rate
  static double get sentryPerformanceSampleRate {
    if (isDebug) return 1.0; // 100% performance monitoring in debug
    if (isStaging) return 0.3; // 30% in staging
    return 0.05; // 5% in production
  }

  /// Whether to attach screenshots to error reports
  static bool get attachScreenshots => !kIsWeb && (isDebug || isStaging);

  /// Whether to attach view hierarchy to error reports
  static bool get attachViewHierarchy => isDebug || isStaging;

  /// Whether to enable debug logging in Sentry
  static bool get sentryDebug => isDebug;

  /// Get API base URL based on environment
  /// Can be overridden with --dart-define=API_BASE_URL=your_url
  static String get apiBaseUrl {
    const customUrl = String.fromEnvironment('API_BASE_URL');
    if (customUrl.isNotEmpty) return customUrl;

    switch (_environment) {
      case 'production':
        return 'https://api.ozpos.com/v1';
      case 'staging':
        return 'https://staging-api.ozpos.com/v1';
      default:
        return 'http://localhost:8000/api/v1';
    }
  }

  /// Get Firebase project configuration based on environment
  static Map<String, String> get firebaseConfig {
    switch (_environment) {
      case 'production':
        return {'project_id': 'ozpos-production', 'environment': 'production'};
      case 'staging':
        return {'project_id': 'ozpos-staging', 'environment': 'staging'};
      default:
        return {'project_id': 'ozpos-development', 'environment': 'debug'};
    }
  }

  /// Whether to enable analytics tracking
  static bool get enableAnalytics => !isDebug;

  /// Whether to enable crash reporting
  static bool get enableCrashReporting => enableSentry;

  /// Whether to enable performance monitoring
  static bool get enablePerformanceMonitoring => !isDebug;

  /// Whether to log network requests
  static bool get logNetworkRequests => isDebug || isStaging;

  /// Whether to log database queries
  static bool get logDatabaseQueries => isDebug;

  /// Maximum number of breadcrumbs to keep
  static int get maxBreadcrumbs {
    if (isDebug) return 200; // More breadcrumbs for debugging
    if (isStaging) return 100; // Moderate amount for staging
    return 50; // Fewer breadcrumbs for production
  }

  /// Session tracking interval
  static Duration get sessionTrackingInterval {
    if (isDebug)
      return const Duration(seconds: 10); // Frequent tracking in debug
    if (isStaging)
      return const Duration(seconds: 30); // Moderate tracking in staging
    return const Duration(minutes: 2); // Less frequent in production
  }

  /// Print configuration summary
  static void printConfig() {
    if (kDebugMode) {
      print('🔧 OZPOS Environment Configuration:');
      print('   Environment: $environment');
      print('   Sentry Enabled: $enableSentry');
      print('   API Base URL: $apiBaseUrl');
      print('   Sample Rate: $sentrySampleRate');
      print('   Performance Sample Rate: $sentryPerformanceSampleRate');
      print('   Debug Logging: $sentryDebug');
      print('   Attach Screenshots: $attachScreenshots');
      print('   Max Breadcrumbs: $maxBreadcrumbs');
      print('');
    }
  }

  /// Get build configuration for Sentry
  static Map<String, dynamic> get buildConfig => {
    'environment': environment,
    'debug': isDebug,
    'version': appVersion,
    'build_time': DateTime.now().toIso8601String(),
    'platform': defaultTargetPlatform.name,
  };
}
