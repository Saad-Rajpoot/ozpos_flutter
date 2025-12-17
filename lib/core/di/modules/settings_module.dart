import 'package:get_it/get_it.dart';

import '../../../features/settings/data/datasources/settings_data_source.dart';
import '../../../features/settings/data/datasources/settings_mock_datasource.dart';
import '../../../features/settings/data/datasources/settings_remote_datasource.dart';
import '../../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../../features/settings/domain/repositories/settings_repository.dart';
import '../../../features/settings/domain/usecases/get_settings_categories.dart';
import '../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../config/app_config.dart';

/// Settings feature module for dependency injection
class SettingsModule {
  /// Initialize settings feature dependencies
  static Future<void> init(GetIt sl) async {
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
}

