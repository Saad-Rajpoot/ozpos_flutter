import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';

import '../config/app_config.dart';
import '../network/api_client.dart' as api_client;
import '../network/network_info.dart';
import '../utils/database_helper.dart';

import '../../features/menu/data/datasources/menu_data_source.dart';
import '../../features/menu/data/datasources/menu_remote_datasource.dart';
import '../../features/menu/data/datasources/menu_mock_datasource.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
import '../../features/menu/domain/usecases/get_menu_items.dart';
import '../../features/menu/domain/usecases/get_menu_categories.dart';
import '../../features/menu/presentation/bloc/menu_bloc.dart';
import '../../features/checkout/presentation/bloc/cart_bloc.dart';
import '../../features/checkout/presentation/bloc/checkout_bloc.dart';
import '../../features/checkout/domain/usecases/initialize_checkout.dart';
import '../../features/checkout/domain/usecases/process_payment.dart';
import '../../features/checkout/domain/usecases/apply_voucher.dart';
import '../../features/checkout/domain/usecases/calculate_totals.dart';
import '../../features/checkout/data/repositories/checkout_repository_impl.dart';
import '../../features/checkout/data/datasources/checkout_local_datasource.dart';
import '../../features/checkout/data/datasources/checkout_mock_datasource.dart';
import '../../features/checkout/data/datasources/checkout_datasource.dart';
import '../../features/checkout/domain/repositories/checkout_repository.dart';
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
import '../../features/customer_display/data/datasources/customer_display_data_source.dart';
import '../../features/customer_display/data/datasources/customer_display_mock_datasource.dart';
import '../../features/customer_display/data/datasources/customer_display_local_datasource.dart';
import '../../features/customer_display/data/datasources/customer_display_remote_datasource.dart';
import '../../features/customer_display/data/repositories/customer_display_repository_impl.dart';
import '../../features/customer_display/domain/repositories/customer_display_repository.dart';
import '../../features/customer_display/domain/usecases/get_customer_display.dart';
import '../../features/customer_display/presentation/bloc/customer_display_bloc.dart';
// Removed - docket management feature removed
// import '../../features/docket/data/datasources/docket_data_source.dart';
// import '../../features/docket/data/datasources/docket_mock_datasource.dart';
// import '../../features/docket/data/datasources/docket_remote_datasource.dart';
// import '../../features/docket/data/repositories/docket_repository_impl.dart';
// import '../../features/docket/domain/repositories/docket_repository.dart';
import '../../features/printing/data/datasources/printing_data_source.dart';
import '../../features/printing/data/datasources/printing_mock_datasource.dart';
import '../../features/printing/data/datasources/printing_remote_datasource.dart';
import '../../features/printing/data/repositories/printing_repository_impl.dart';
import '../../features/printing/domain/repositories/printing_repository.dart';
import '../../features/printing/domain/usecases/get_printers.dart';
import '../../features/printing/domain/usecases/add_printer.dart';
import '../../features/printing/presentation/bloc/printing_bloc.dart';
import '../../features/combos/data/datasources/combo_data_source.dart';
import '../../features/combos/data/datasources/combo_mock_datasource.dart';
import '../../features/combos/data/datasources/combo_remote_datasource.dart';
import '../../features/combos/data/repositories/combo_repository_impl.dart';
import '../../features/combos/domain/repositories/combo_repository.dart';
import '../../features/combos/domain/usecases/get_combos.dart';
import '../../features/combos/domain/usecases/create_combo.dart';
import '../../features/combos/domain/usecases/update_combo.dart';
import '../../features/combos/domain/usecases/delete_combo.dart';
import '../../features/combos/domain/usecases/validate_combo.dart';
import '../../features/combos/domain/usecases/calculate_pricing.dart';

// Settings feature imports
import '../../features/settings/data/datasources/settings_data_source.dart';
import '../../features/settings/data/datasources/settings_mock_datasource.dart';
import '../../features/settings/data/datasources/settings_remote_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_settings_categories.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';

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
    () => api_client.ApiClient(
        sharedPreferences: sl(), baseUrl: AppConfig.instance.baseUrl),
  );

  // Features
  await _initMenu(sl);
  await _initCart(sl);
  await _initCheckout(sl);
  await _initCombos(sl);
  await _initAddons(sl);
  await _initTables(sl);
  await _initReservations(sl);
  await _initReports(sl);
  await _initOrders(sl);
  await _initDelivery(sl);
  // await _initDocket(sl); // Removed - docket management feature removed
  await _initPrinting(sl);
  await _initSettings(sl);
  await _initCustomerDisplay(sl);
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
  sl.registerLazySingleton<MenuDataSource>(() {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      // Use mock data source for development
      return MenuMockDataSourceImpl();
    } else {
      // Use remote data source for production
      return MenuRemoteDataSourceImpl(apiClient: sl());
    }
  });

  // Repository
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(
      menuDataSource: sl(),
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
  // BLoC (Singleton - cart persists across entire app lifecycle)
  // This is appropriate for a POS system where the cart should persist
  // across navigation and be accessible from anywhere in the app
  sl.registerLazySingleton(() => CartBloc()..add(const InitializeCart()));
}

/// Initialize checkout feature dependencies
Future<void> _initCheckout(GetIt sl) async {
  // Data source - handle database availability
  sl.registerLazySingleton<CheckoutDataSource>(() {
    if (sl.isRegistered<Database>()) {
      return CheckoutLocalDataSource(database: sl());
    } else {
      // Fallback for web or when database is not available
      return CheckoutMockDataSource();
    }
  });

  // Repository
  sl.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(checkoutDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => InitializeCheckoutUseCase());
  sl.registerLazySingleton(() => ProcessPaymentUseCase(repository: sl()));
  sl.registerLazySingleton(() => ApplyVoucherUseCase(repository: sl()));
  sl.registerLazySingleton(() => CalculateTotalsUseCase());

  // BLoC (Factory - new instance each time)
  sl.registerFactory(() => CheckoutBloc(
        initializeCheckoutUseCase: sl(),
        processPaymentUseCase: sl(),
        applyVoucherUseCase: sl(),
        calculateTotalsUseCase: sl(),
      ));
}

/// Initialize combo feature dependencies
Future<void> _initCombos(GetIt sl) async {
  // Environment-based data source selection
  sl.registerLazySingleton<ComboDataSource>(() {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      // Use mock data source for development
      return ComboMockDataSourceImpl();
    } else {
      // Use remote data source for production
      return ComboRemoteDataSourceImpl(apiClient: sl());
    }
  });

  // Repository
  sl.registerLazySingleton<ComboRepository>(
    () => ComboRepositoryImpl(comboDataSource: sl(), networkInfo: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCombos(sl()));
  sl.registerLazySingleton(() => CreateCombo(repository: sl()));
  sl.registerLazySingleton(() => UpdateCombo(repository: sl()));
  sl.registerLazySingleton(() => DeleteCombo(repository: sl()));
  sl.registerLazySingleton(() => ValidateCombo(repository: sl()));
  sl.registerLazySingleton(() => CalculatePricing(repository: sl()));

  // BLoC (Factory - new instance each time)
  sl.registerFactory(() => ComboManagementBloc(
        uuid: const Uuid(),
        getCombos: sl(),
        createCombo: sl(),
        updateCombo: sl(),
        deleteCombo: sl(),
        validateCombo: sl(),
        calculatePricing: sl(),
      ));
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
    () => AddonRepositoryImpl(
      addonDataSource: sl(),
      networkInfo: sl(),
    ),
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
      return ReportsRemoteDataSourceImpl(apiClient: sl());
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
      return DeliveryRemoteDataSourceImpl(apiClient: sl());
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

Future<void> _initCustomerDisplay(GetIt sl) async {
  sl.registerLazySingleton<CustomerDisplayDataSource>(() {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      return CustomerDisplayMockDataSourceImpl();
    }
    if (sl.isRegistered<Database>()) {
      return CustomerDisplayLocalDataSourceImpl(database: sl());
    }
    return CustomerDisplayRemoteDataSourceImpl(apiClient: sl());
  });

  sl.registerLazySingleton<CustomerDisplayRepository>(
    () => CustomerDisplayRepositoryImpl(dataSource: sl()),
  );

  sl.registerLazySingleton(() => GetCustomerDisplay(repository: sl()));

  sl.registerFactory(() => CustomerDisplayBloc(getCustomerDisplay: sl()));
}

/// Initialize docket feature dependencies
// Removed - docket management feature removed
// Future<void> _initDocket(GetIt sl) async {
//   // Environment-based data source selection
//   sl.registerLazySingleton<DocketDataSource>(() {
//     if (AppConfig.instance.environment == AppEnvironment.development) {
//       // Use mock data source for development
//       return DocketMockDataSourceImpl();
//     } else {
//       // Use remote data source for production
//       return DocketRemoteDataSourceImpl(apiClient: sl());
//     }
//   });

//   // Repository
//   sl.registerLazySingleton<DocketRepository>(
//     () => DocketRepositoryImpl(docketDataSource: sl(), networkInfo: sl()),
//   );

//   // Use cases
//   // BLoC (Factory - new instance each time)
// }

/// Initialize printing feature dependencies
Future<void> _initPrinting(GetIt sl) async {
  // Environment-based data source selection
  sl.registerLazySingleton<PrintingDataSource>(() {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      // Use mock data source for development
      return PrintingMockDataSourceImpl();
    } else {
      // Use remote data source for production
      return PrintingRemoteDataSourceImpl(apiClient: sl());
    }
  });

  // Repository
  sl.registerLazySingleton<PrintingRepository>(
    () => PrintingRepositoryImpl(
      printingDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases - Simple CRUD operations only
  sl.registerLazySingleton(() => GetPrinters(repository: sl()));
  sl.registerLazySingleton(() => AddPrinter(repository: sl()));

  // BLoC (Factory - new instance each time)
  sl.registerFactory(() => PrintingBloc(
        getPrinters: sl(),
        addPrinter: sl(),
        printingRepository: sl(),
      ));
}

/// Initialize settings feature dependencies
Future<void> _initSettings(GetIt sl) async {
  // Data source (environment-based)
  sl.registerLazySingleton<SettingsDataSource>(() {
    if (AppConfig.instance.environment == AppEnvironment.development) {
      return SettingsMockDataSourceImpl();
    } else {
      return SettingsRemoteDataSourceImpl(apiClient: sl());
    }
  });

  // Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(dataSource: sl(), networkInfo: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSettingsCategories(repository: sl()));

  // BLoC
  sl.registerFactory(() => SettingsBloc(getSettingsCategories: sl()));
}
