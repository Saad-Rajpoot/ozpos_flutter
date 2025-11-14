import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../config/app_config.dart';
import '../../network/api_client.dart' as api_client;
import '../../network/network_info.dart';
import '../../utils/database_helper.dart';

/// Core module for shared dependencies
/// This module registers dependencies that are used across multiple features
class CoreModule {
  /// Initialize core dependencies
  static Future<void> init(GetIt sl) async {
    // External dependencies
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton(() => sharedPreferences);

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
        baseUrl: AppConfig.instance.baseUrl,
      ),
    );
  }
}
