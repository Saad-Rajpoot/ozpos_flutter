import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/theme/data/datasources/theme_local_datasource.dart';
import '../../../features/theme/data/repositories/theme_repository_impl.dart';
import '../../../features/theme/domain/repositories/theme_repository.dart';
import '../../../features/theme/domain/usecases/get_theme_mode_usecase.dart';
import '../../../features/theme/domain/usecases/set_theme_mode_usecase.dart';

/// Theme feature module for dependency injection.
class ThemeModule {
  static Future<void> init(GetIt sl) async {
    // Data source
    sl.registerLazySingleton<ThemeLocalDataSource>(
      () => ThemeLocalDataSource(
        sharedPreferences: sl<SharedPreferences>(),
      ),
    );

    // Repository
    sl.registerLazySingleton<ThemeRepository>(
      () => ThemeRepositoryImpl(localDataSource: sl()),
    );

    // Use cases
    sl.registerLazySingleton(() => GetThemeModeUsecase(sl()));
    sl.registerLazySingleton(() => SetThemeModeUsecase(sl()));
  }
}
