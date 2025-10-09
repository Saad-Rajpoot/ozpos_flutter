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
import '../../features/addons/data/datasources/addon_data_source.dart';
import '../../features/addons/data/datasources/addon_mock_datasource.dart';
import '../../features/addons/data/datasources/addon_remote_datasource.dart';
import '../../features/addons/data/repositories/addon_repository_impl.dart';
import '../../features/addons/domain/repositories/addon_repository.dart';
import '../../features/addons/domain/usecases/get_addon_categories.dart';
import '../../features/addons/presentation/bloc/addon_management_bloc.dart';
import '../../features/tables/data/datasources/table_data_source.dart';
import '../../features/tables/data/datasources/table_mock_datasource.dart';
import '../../features/tables/data/datasources/table_remote_datasource.dart';
import '../../features/tables/data/repositories/table_repository_impl.dart';
import '../../features/tables/domain/repositories/table_repository.dart';
import '../../features/tables/domain/usecases/get_tables.dart';
import '../../features/tables/domain/usecases/get_available_tables.dart';
import '../../features/tables/presentation/bloc/table_management_bloc.dart';
import '../../features/reservations/data/datasources/reservations_data_source.dart';
import '../../features/reservations/data/datasources/reservations_mock_datasource.dart';
import '../../features/reservations/data/datasources/reservations_remote_datasource.dart';
import '../../features/reservations/data/repositories/reservation_repository_impl.dart';
import '../../features/reservations/domain/repositories/reservation_repository.dart';
import '../../features/reservations/domain/usecases/get_reservations.dart';
import '../../features/reservations/presentation/bloc/reservation_management_bloc.dart';
import '../../features/reports/data/datasources/reports_data_source.dart';
import '../../features/reports/data/datasources/reports_mock_datasource.dart';
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/domain/usecases/get_reports_data.dart';
import '../../features/reports/presentation/bloc/reports_bloc.dart';
import '../../features/reports/data/datasources/reports_remote_datasource.dart';
import '../../features/orders/data/datasources/orders_data_source.dart';
import '../../features/orders/data/datasources/orders_mock_datasource.dart';
import '../../features/orders/data/datasources/orders_remote_datasource.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/usecases/get_orders.dart';
import '../../features/orders/presentation/bloc/orders_management_bloc.dart';
import '../../features/delivery/data/datasources/delivery_data_source.dart';
import '../../features/delivery/data/datasources/delivery_remote_datasource.dart';
import '../../features/delivery/data/datasources/delivery_mock_datasource.dart';
import '../../features/delivery/data/repositories/delivery_repository_impl.dart';
import '../../features/delivery/domain/repositories/delivery_repository.dart';
import '../../features/delivery/domain/usecases/get_delivery_data.dart';
import '../../features/delivery/presentation/bloc/delivery_bloc.dart';
import '../../features/docket/data/datasources/docket_data_source.dart';
import '../../features/docket/data/datasources/docket_mock_datasource.dart';
import '../../features/docket/data/datasources/docket_remote_datasource.dart';
import '../../features/docket/data/repositories/docket_repository_impl.dart';
import '../../features/docket/domain/repositories/docket_repository.dart';
import '../../features/docket/domain/usecases/get_dockets.dart';
import '../../features/docket/presentation/bloc/docket_management_bloc.dart';

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
    // ignore: avoid_print
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
  await _initAddons(sl);
  await _initTables(sl);
  await _initReservations(sl);
  await _initReports(sl);
  await _initOrders(sl);
  await _initDelivery(sl);
  await _initDocket(sl);
}

/// Initialize orders feature dependencies
Future<void> _initOrders(GetIt sl) async {
  // Environment-based data source selection
  sl.registerLazySingleton<OrdersDataSource>(() {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      // Use mock data source for development
      return OrdersMockDataSourceImpl();
    } else {
      // Use remote data source for production
      return OrdersRemoteDataSourceImpl(apiClient: sl());
    }
  });

  // Repository
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(ordersDataSource: sl(), networkInfo: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetOrders(sl()));

  // BLoC (Factory - new instance each time)
  sl.registerFactory(() => OrdersManagementBloc(getOrders: sl()));
}

/// Initialize menu feature dependencies
Future<void> _initMenu(GetIt sl) async {
  // Environment-based data source selection
  sl.registerLazySingleton<MenuRemoteDataSource>(() {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      // Use mock data source for development
      return MenuMockDataSourceImpl();
    } else {
      // Use remote data source for production
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

/// Initialize addon feature dependencies
Future<void> _initAddons(GetIt sl) async {
  // Environment-based data source selection
  sl.registerLazySingleton<AddonDataSource>(() {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      // Use mock data source for development
      return AddonMockDataSourceImpl();
    } else {
      // Use remote data source for production
      return AddonRemoteDataSourceImpl(apiClient: sl());
    }
  });

  // Repository
  sl.registerLazySingleton<AddonRepository>(
    () => AddonRepositoryImpl(addonDataSource: sl(), networkInfo: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAddonCategories(sl()));

  // BLoC (Factory - new instance each time)
  sl.registerFactory(() => AddonManagementBloc(getAddonCategories: sl()));
}

/// Initialize tables feature dependencies
Future<void> _initTables(GetIt sl) async {
  // Environment-based data source selection for main tables
  sl.registerLazySingleton<TableDataSource>(() {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      // Use mock data source for development
      return TableMockDataSourceImpl();
    } else {
      // Use remote data source for production
      return TableRemoteDataSourceImpl(apiClient: sl());
    }
  });

  // Repositories
  sl.registerLazySingleton<TableRepository>(
    () => TableRepositoryImpl(tableDataSource: sl(), networkInfo: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTables(sl()));
  sl.registerLazySingleton(() => GetMoveAvailableTables(sl()));

  // BLoCs (Factory - new instance each time)
  sl.registerFactory(
    () => TableManagementBloc(getTables: sl(), getMoveAvailableTables: sl()),
  );
}

/// Initialize reservations feature dependencies
Future<void> _initReservations(GetIt sl) async {
  // Environment-based data source selection
  sl.registerLazySingleton<ReservationsDataSource>(() {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      // Use mock data source for development
      return ReservationsMockDataSourceImpl();
    } else {
      // Use remote data source for production
      return ReservationsRemoteDataSourceImpl(apiClient: sl());
    }
  });

  // Repository
  sl.registerLazySingleton<ReservationRepository>(
    () => ReservationRepositoryImpl(
      reservationsDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetReservations(sl()));

  // BLoC (Factory - new instance each time)
  sl.registerFactory(() => ReservationManagementBloc(getReservations: sl()));
}

/// Initialize reports feature dependencies
Future<void> _initReports(GetIt sl) async {
  // Environment-based data source selection
  sl.registerLazySingleton<ReportsDataSource>(() {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      // Use mock data source for development
      return ReportsMockDataSourceImpl();
    } else {
      // Use remote data source for production
      return ReportsRemoteDataSourceImpl(client: sl());
    }
  });

  // Repository
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(reportsDataSource: sl(), networkInfo: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetReportsData(sl()));

  // BLoC (Factory - new instance each time)
  sl.registerFactory(() => ReportsBloc(getReportsData: sl()));
}

/// Initialize delivery feature dependencies
Future<void> _initDelivery(GetIt sl) async {
  // Environment-based data source selection
  sl.registerLazySingleton<DeliveryDataSource>(() {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      // Use local data source for development (JSON files)
      return DeliveryMockDataSourceImpl();
    } else {
      // Use remote data source for production
      return DeliveryRemoteDataSourceImpl(client: sl());
    }
  });

  // Repository
  sl.registerLazySingleton<DeliveryRepository>(
    () => DeliveryRepositoryImpl(deliveryDataSource: sl(), networkInfo: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDeliveryData(sl()));

  // BLoC (Factory - new instance each time)
  sl.registerFactory(() => DeliveryBloc(getDeliveryData: sl()));
}

/// Initialize docket feature dependencies
Future<void> _initDocket(GetIt sl) async {
  // Environment-based data source selection
  sl.registerLazySingleton<DocketDataSource>(() {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      // Use mock data source for development
      return DocketMockDataSourceImpl();
    } else {
      // Use remote data source for production
      return DocketRemoteDataSourceImpl(apiClient: sl());
    }
  });

  // Repository
  sl.registerLazySingleton<DocketRepository>(
    () => DocketRepositoryImpl(docketDataSource: sl(), networkInfo: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDockets(sl()));

  // BLoC (Factory - new instance each time)
  sl.registerFactory(() => DocketManagementBloc(getDockets: sl()));
}
