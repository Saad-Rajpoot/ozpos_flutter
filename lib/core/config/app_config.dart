/// Application configuration using environment-based approach
/// This replaces simple boolean flags for production-grade configuration management
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  static AppConfig get instance => _instance;

  AppEnvironment _environment = AppEnvironment.development;

  AppConfig._internal();

  /// Initialize the app configuration with the specified environment
  void initialize({required AppEnvironment environment}) {
    _environment = environment;
  }

  /// Get the current environment
  AppEnvironment get environment => _environment;

  /// Check if using mock data (development mode)
  /// In production, this should always return false
  bool get useMockData {
    switch (_environment) {
      case AppEnvironment.development:
        return true; // Use mock data for development
      case AppEnvironment.staging:
        return false; // Use real API for staging
      case AppEnvironment.production:
        return false; // Use real API for production
    }
  }

  /// Get the base URL for API calls based on environment
  String get baseUrl {
    switch (_environment) {
      case AppEnvironment.development:
        return 'http://localhost:8000/api/v1';
      case AppEnvironment.staging:
        return 'https://staging-api.ozpos.com/v1';
      case AppEnvironment.production:
        return 'https://api.ozpos.com/v1';
    }
  }

  /// Check if we're in debug mode
  bool get isDebug => _environment == AppEnvironment.development;

  /// Check if we're in staging environment
  bool get isStaging => _environment == AppEnvironment.staging;

  /// Check if we're in production environment
  bool get isProduction => _environment == AppEnvironment.production;
}

/// Application environments
enum AppEnvironment { development, staging, production }

/// Extension to provide user-friendly environment names
extension AppEnvironmentExtension on AppEnvironment {
  String get displayName {
    switch (this) {
      case AppEnvironment.development:
        return 'Development';
      case AppEnvironment.staging:
        return 'Staging';
      case AppEnvironment.production:
        return 'Production';
    }
  }
}
