import 'package:flutter/foundation.dart';

/// Application configuration using environment-based approach
/// This replaces simple boolean flags for production-grade configuration management
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  static AppConfig get instance => _instance;

  AppEnvironment _environment = AppEnvironment.development;

  AppConfig._internal();

  /// Initialize the app configuration with environment
  void initialize({required AppEnvironment environment}) {
    _environment = environment;
  }

  /// Get the current environment
  AppEnvironment get environment => _environment;

  /// Get the base URL for API calls (alias for apiBaseUrl)
  String get baseUrl => apiBaseUrl;

  /// Get API base URL based on environment
  /// Can be overridden with --dart-define=API_BASE_URL=your_url
  String get apiBaseUrl {
    const customUrl = String.fromEnvironment('API_BASE_URL');
    if (customUrl.isNotEmpty) return customUrl;

    switch (_environment) {
      case AppEnvironment.production:
        return 'https://api.ozpos.com/v1';
      default:
        return 'http://localhost:8000/api/v1';
    }
  }

  /// Get Firebase project configuration based on environment
  Map<String, String> get firebaseConfig {
    switch (_environment) {
      case AppEnvironment.production:
        return {'project_id': 'ozpos-production', 'environment': 'production'};
      default:
        return {'project_id': 'ozpos-development', 'environment': 'debug'};
    }
  }

  /// Whether to enable analytics tracking (automatically based on environment)
  bool get enableAnalytics => _environment == AppEnvironment.production;

  /// Whether to enable crash reporting (automatically based on environment)
  bool get enableCrashReporting => true;

  /// Whether to enable performance monitoring (automatically based on environment)
  bool get enablePerformanceMonitoring =>
      _environment == AppEnvironment.production;

  /// Whether to log network requests (automatically based on environment)
  bool get logNetworkRequests => _environment == AppEnvironment.development;

  /// Whether to log database queries (automatically based on environment)
  bool get logDatabaseQueries => _environment == AppEnvironment.development;

  /// Print configuration summary
  void printConfig() {
    if (kDebugMode) {
      print('🔧 OZPOS Configuration:');
      print(
        '   Mode: ${_environment == AppEnvironment.development ? 'MOCK DATA' : 'REMOTE API'}',
      );
      print('   Environment: $_environment');
      print('   API Base URL: $apiBaseUrl');
      print('   Analytics: $enableAnalytics');
      print('   Performance Monitoring: $enablePerformanceMonitoring');
      print('   Network Logging: $logNetworkRequests');
      print('   Database Logging: $logDatabaseQueries');
      print('');
    }
  }
}

/// Application environments
enum AppEnvironment { development, production }

/// Extension to provide user-friendly environment names
extension AppEnvironmentExtension on AppEnvironment {
  String get displayName {
    switch (this) {
      case AppEnvironment.development:
        return 'Development';
      case AppEnvironment.production:
        return 'Production';
    }
  }
}
