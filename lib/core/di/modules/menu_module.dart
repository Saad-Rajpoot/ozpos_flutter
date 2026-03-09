import 'package:get_it/get_it.dart';

import '../../../features/menu/data/datasources/menu_data_source.dart';
import '../../../features/menu/data/datasources/menu_mock_datasource.dart';
import '../../../features/menu/data/datasources/menu_remote_datasource.dart';
import '../../../features/menu/data/datasources/single_vendor_remote_datasource.dart';
import '../../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../../features/menu/data/repositories/single_vendor_repository_impl.dart';
import '../../../features/menu/domain/repositories/menu_repository.dart';
import '../../../features/menu/domain/repositories/single_vendor_repository.dart';
import '../../../features/menu/domain/usecases/get_menu_categories.dart';
import '../../../features/menu/domain/usecases/get_menu_items.dart';
import '../../../features/menu/domain/usecases/get_single_vendor_usecase.dart';
import '../../../features/menu/presentation/bloc/menu_bloc.dart';
import '../../config/app_config.dart';

/// Menu feature module for dependency injection
class MenuModule {
  /// Initialize menu feature dependencies
  static Future<void> init(GetIt sl) async {
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

    // Single vendor remote data source (uses ApiClient - token from interceptor)
    sl.registerLazySingleton<SingleVendorRemoteDataSource>(
      () => SingleVendorRemoteDataSourceImpl(apiClient: sl()),
    );

    // Repositories
    sl.registerLazySingleton<MenuRepository>(
      () => MenuRepositoryImpl(
        menuDataSource: sl(),
        networkInfo: sl(),
      ),
    );

    sl.registerLazySingleton<SingleVendorRepository>(
      () => SingleVendorRepositoryImpl(
        remoteDataSource: sl(),
        sharedPreferences: sl(),
        networkInfo: sl(),
        menuSnapshotDao: sl(),
      ),
    );

    // Use cases
    sl.registerLazySingleton(() => GetMenuItems(repository: sl()));
    sl.registerLazySingleton(() => GetMenuCategories(repository: sl()));
    sl.registerLazySingleton(
      () => GetSingleVendorUsecase(repository: sl<SingleVendorRepository>()),
    );

    // BLoC (Factory - new instance each time)
    sl.registerFactory(
      () => MenuBloc(
        getMenuItems: sl(),
        getMenuCategories: sl(),
        getSingleVendorUsecase: sl(),
      ),
    );
  }
}

