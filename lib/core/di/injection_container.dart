import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../utils/database_helper.dart';

import '../../features/menu/data/datasources/menu_remote_datasource.dart';
import '../../features/menu/data/datasources/menu_mock_datasource.dart';
import '../../features/menu/data/datasources/menu_local_datasource.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
import '../../features/menu/domain/usecases/get_menu_items.dart';
import '../../features/menu/domain/usecases/get_menu_categories.dart';
import '../../features/menu/presentation/bloc/menu_bloc.dart';
import '../../features/checkout/presentation/bloc/cart_bloc.dart';
import '../../features/combos/presentation/bloc/combo_management_bloc.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> init() async {
  // Initialize AppConfig first - this should be done in main.dart
  // AppConfig.instance.initialize(environment: AppEnvironment.development);

  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Database - handle web compatibility
  try {
    final database = await DatabaseHelper.database;
    sl.registerLazySingleton<Database>(() => database);
  } catch (e) {
    // For web, register a mock database or skip database operations
    print('Database not available on web: $e');
  }

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: Connectivity()),
  );

  // API Client with environment-based configuration
  sl.registerLazySingleton(
    () =>
        ApiClient(sharedPreferences: sl(), baseUrl: AppConfig.instance.baseUrl),
  );

  // Features
  await _initMenu(sl);
  await _initCart(sl);
  await _initCombos(sl);
}

/// Initialize menu feature dependencies
Future<void> _initMenu(GetIt sl) async {
  // Environment-based data source selection
  sl.registerLazySingleton<MenuRemoteDataSource>(() {
    if (AppConfig.instance.useMockData) {
      // Use mock data source for development
      return MenuMockDataSourceImpl();
    } else {
      // Use remote data source for staging/production
      return MenuRemoteDataSourceImpl(apiClient: sl());
    }
  });

  // Only register local data source if database is available
  if (sl.isRegistered<Database>()) {
    sl.registerLazySingleton<MenuLocalDataSource>(
      () => MenuLocalDataSourceImpl(database: sl()),
    );
  }

  // Repository
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl.isRegistered<MenuLocalDataSource>()
          ? sl<MenuLocalDataSource>()
          : null,
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetMenuItems(repository: sl()));
  sl.registerLazySingleton(() => GetMenuCategories(repository: sl()));

  // BLoC (Factory - new instance each time)
  sl.registerFactory(
    () => MenuBloc(getMenuItems: sl(), getMenuCategories: sl()),
  );
}

/// Initialize cart feature dependencies
Future<void> _initCart(GetIt sl) async {
  // BLoC (Singleton - shared cart across the app)
  sl.registerLazySingleton(() => CartBloc()..add(const InitializeCart()));
}

/// Initialize combo feature dependencies
Future<void> _initCombos(GetIt sl) async {
  // BLoC (Factory - new instance each time)
  sl.registerFactory(() => ComboManagementBloc());
}
