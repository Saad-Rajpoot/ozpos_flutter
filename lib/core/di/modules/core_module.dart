import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../../auth/auth_cubit.dart';
import '../../auth/auth_repository.dart';
import '../../config/app_config.dart';
import '../../network/api_client.dart' as api_client;
import '../../network/network_info.dart';
import '../../storage/secure_storage_service.dart';
import '../../utils/database_helper.dart';

/// Core module for shared dependencies
/// This module registers dependencies that are used across multiple features
class CoreModule {
  /// Initialize core dependencies
  static Future<void> init(GetIt sl) async {
    // External dependencies
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton(() => sharedPreferences);

    // Secure storage for sensitive data (tokens, API keys)
    sl.registerLazySingleton<SecureStorageService>(
      () => SecureStorageService(),
    );

    // Authentication repository & cubit
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepository(
        secureStorage: sl(),
        sharedPreferences: sharedPreferences,
      ),
    );
    sl.registerLazySingleton<AuthCubit>(
      () => AuthCubit(authRepository: sl()),
    );

    // Migrate tokens from SharedPreferences to secure storage (one-time migration)
    final secureStorage = sl<SecureStorageService>();
    await _migrateTokensToSecureStorage(sharedPreferences, secureStorage);

    // Database - handle web compatibility
    try {
      final database = await DatabaseHelper.database;
      sl.registerLazySingleton<Database>(() => database);
    } catch (e) {
      // For web, register a mock database or skip database operations
      // ignore: avoid_print
      print('Database not available on web: $e');
    }

    // Core services
    sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(connectivity: Connectivity()),
    );

    // API Client with environment-based configuration
    sl.registerLazySingleton(
      () => api_client.ApiClient(
        sharedPreferences: sl(),
        secureStorage: sl(),
        baseUrl: AppConfig.instance.baseUrl,
      ),
    );
  }

  /// Migrate tokens from SharedPreferences to secure storage
  ///
  /// This is a one-time migration for existing users who have tokens
  /// stored in plain-text SharedPreferences. After migration, tokens
  /// are removed from SharedPreferences and stored securely.
  static Future<void> _migrateTokensToSecureStorage(
    SharedPreferences sharedPreferences,
    SecureStorageService secureStorage,
  ) async {
    try {
      // Check if tokens exist in SharedPreferences
      final oldAccessToken = sharedPreferences.getString('token');
      final oldRefreshToken = sharedPreferences.getString('refresh_token');

      // Check if tokens already exist in secure storage
      final hasSecureAccessToken = await secureStorage.hasAccessToken();
      final hasSecureRefreshToken = await secureStorage.hasRefreshToken();

      // Only migrate if:
      // 1. Tokens exist in SharedPreferences
      // 2. Tokens don't exist in secure storage yet
      if ((oldAccessToken != null || oldRefreshToken != null) &&
          (!hasSecureAccessToken || !hasSecureRefreshToken)) {
        if (kDebugMode) {
          debugPrint(
              '🔄 Migrating tokens from SharedPreferences to secure storage...');
        }

        // Migrate access token
        if (oldAccessToken != null && !hasSecureAccessToken) {
          await secureStorage.saveAccessToken(oldAccessToken);
          if (kDebugMode) {
            debugPrint('✅ Access token migrated to secure storage');
          }
        }

        // Migrate refresh token
        if (oldRefreshToken != null && !hasSecureRefreshToken) {
          await secureStorage.saveRefreshToken(oldRefreshToken);
          if (kDebugMode) {
            debugPrint('✅ Refresh token migrated to secure storage');
          }
        }

        // Remove tokens from SharedPreferences after successful migration
        await sharedPreferences.remove('token');
        await sharedPreferences.remove('refresh_token');

        if (kDebugMode) {
          debugPrint(
              '✅ Token migration completed. Tokens removed from SharedPreferences.');
        }
      }
    } catch (e) {
      // Log error but don't fail initialization
      // Tokens will remain in SharedPreferences if migration fails
      if (kDebugMode) {
        debugPrint('⚠️ Token migration failed: $e');
        debugPrint(
            '   Tokens will remain in SharedPreferences until next app start.');
      }
    }
  }
}
