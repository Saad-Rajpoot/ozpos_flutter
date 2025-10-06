import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../network/api_client.dart';
import '../network/network_info.dart';
import '../utils/database_helper.dart';

import '../../features/pos/data/datasources/menu_remote_datasource.dart';
import '../../features/pos/data/datasources/menu_local_datasource.dart';
import '../../features/pos/data/datasources/mock_menu_local_datasource.dart';
import '../../features/pos/data/repositories/menu_repository_impl.dart';
import '../../features/pos/domain/repositories/menu_repository.dart';
import '../../features/pos/domain/usecases/get_menu_items.dart';
import '../../features/pos/domain/usecases/get_menu_categories.dart';
import '../../features/pos/presentation/bloc/menu_bloc.dart';

import '../../features/cart/data/datasources/cart_local_datasource.dart';
import '../../features/cart/data/datasources/mock_cart_local_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/add_to_cart.dart';
import '../../features/cart/domain/usecases/remove_from_cart.dart';
import '../../features/cart/domain/usecases/update_cart_item.dart';
import '../../features/cart/domain/usecases/clear_cart.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';

import '../../features/combos/presentation/bloc/combo_management_bloc.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> init() async {
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
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(connectivity: Connectivity()));
  sl.registerLazySingleton(() => ApiClient(sharedPreferences: sl()));
  
  // Features
  await _initMenu(sl);
  await _initCart(sl);
  await _initCombos(sl);
}

/// Initialize menu feature dependencies
Future<void> _initMenu(GetIt sl) async {
  // Data sources
  sl.registerLazySingleton<MenuRemoteDataSource>(
    () => MenuRemoteDataSourceImpl(apiClient: sl()),
  );

  // Only register local data source if database is available
  if (sl.isRegistered<Database>()) {
    sl.registerLazySingleton<MenuLocalDataSource>(
      () => MenuLocalDataSourceImpl(database: sl()),
    );
  } else {
    // For web, register a mock local data source
    sl.registerLazySingleton<MenuLocalDataSource>(
      () => MockMenuLocalDataSource(),
    );
  }
  
  // Repository
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Use cases
  sl.registerLazySingleton(() => GetMenuItems(repository: sl()));
  sl.registerLazySingleton(() => GetMenuCategories(repository: sl()));
  
  // BLoC (Factory - new instance each time)
  sl.registerFactory(() => MenuBloc(
    getMenuItems: sl(),
    getMenuCategories: sl(),
  ));
}

/// Initialize cart feature dependencies
Future<void> _initCart(GetIt sl) async {
  // Data sources
  if (sl.isRegistered<Database>()) {
    sl.registerLazySingleton<CartLocalDataSource>(
      () => CartLocalDataSourceImpl(database: sl()),
    );
  } else {
    // For web, register a mock local data source
    sl.registerLazySingleton<CartLocalDataSource>(
      () => MockCartLocalDataSource(),
    );
  }
  
  // Repository
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(localDataSource: sl()),
  );
  
  // Use cases
  sl.registerLazySingleton(() => AddToCart(repository: sl()));
  sl.registerLazySingleton(() => RemoveFromCart(repository: sl()));
  sl.registerLazySingleton(() => UpdateCartItem(repository: sl()));
  sl.registerLazySingleton(() => ClearCart(repository: sl()));
  
        // BLoC (Factory - new instance each time)
        sl.registerFactory(() => CartBloc(
          addToCart: sl(),
          removeFromCart: sl(),
          updateCartItem: sl(),
          clearCart: sl(),
          cartRepository: sl(),
        ));
}

/// Initialize combo feature dependencies
Future<void> _initCombos(GetIt sl) async {
  // BLoC (Factory - new instance each time)
  sl.registerFactory(() => ComboManagementBloc());
}
