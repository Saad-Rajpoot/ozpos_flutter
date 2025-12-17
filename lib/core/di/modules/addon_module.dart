import 'package:get_it/get_it.dart';

import '../../../features/addons/data/datasources/addon_data_source.dart';
import '../../../features/addons/data/datasources/addon_mock_datasource.dart';
import '../../../features/addons/data/datasources/addon_remote_datasource.dart';
import '../../../features/addons/data/repositories/addon_repository_impl.dart';
import '../../../features/addons/domain/repositories/addon_repository.dart';
import '../../../features/addons/domain/usecases/get_addon_categories.dart';
import '../../../features/addons/presentation/bloc/addon_management_bloc.dart';
import '../../config/app_config.dart';

/// Addon feature module for dependency injection
class AddonModule {
  /// Initialize addon feature dependencies
  static Future<void> init(GetIt sl) async {
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
}

