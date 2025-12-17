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
  ///
  /// **SECURITY**: HTTPS is enforced in production. HTTP is only allowed in development.
  String get apiBaseUrl {
    const customUrl = String.fromEnvironment('API_BASE_URL');
    if (customUrl.isNotEmpty) {
      // Validate HTTPS in production
      if (_environment == AppEnvironment.production &&
          !customUrl.startsWith('https://')) {
        throw StateError(
          'Production API URL must use HTTPS. Provided: $customUrl',
        );
      }
      return customUrl;
    }

    switch (_environment) {
      case AppEnvironment.production:
        return 'https://api.ozpos.com/v1';
      default:
        // Allow HTTP only in development
        return 'http://localhost:8000/api/v1';
    }
  }

  /// Whether to enforce HTTPS for all API calls
  ///
  /// In production, HTTPS is always enforced.
  /// In development, HTTP is allowed for local testing.
  bool get enforceHttps => _environment == AppEnvironment.production;

  /// Certificate pinning configuration
  ///
  /// **SECURITY**: Certificate pinning prevents MITM attacks by verifying
  /// the server's certificate matches expected fingerprints.
  ///
  /// To enable certificate pinning, provide certificate SHA-256 fingerprints
  /// via --dart-define=CERT_PIN_1=sha256/... --dart-define=CERT_PIN_2=sha256/...
  ///
  /// To get certificate fingerprints:
  ///   openssl s_client -servername api.ozpos.com -connect api.ozpos.com:443 < /dev/null 2>/dev/null | openssl x509 -fingerprint -sha256 -noout -in /dev/stdin
  ///
  /// Returns empty list if not configured (pinning disabled).
  List<String> get certificatePins {
    const pin1 = String.fromEnvironment('CERT_PIN_1');
    const pin2 = String.fromEnvironment('CERT_PIN_2');
    const pin3 = String.fromEnvironment('CERT_PIN_3');

    final pins = <String>[];
    if (pin1.isNotEmpty) pins.add(pin1);
    if (pin2.isNotEmpty) pins.add(pin2);
    if (pin3.isNotEmpty) pins.add(pin3);

    return pins;
  }

  /// Whether certificate pinning is enabled
  bool get isCertificatePinningEnabled => certificatePins.isNotEmpty;

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
      print('   HTTPS Enforced: $enforceHttps');
      if (isCertificatePinningEnabled) {
        print(
            '   Certificate Pinning: ✅ Enabled (${certificatePins.length} pins)');
      } else {
        print('   Certificate Pinning: ⚠️  Disabled');
        if (_environment == AppEnvironment.production) {
          print('      To enable: --dart-define=CERT_PIN_1=sha256/...');
        }
      }
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
