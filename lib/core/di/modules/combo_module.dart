import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../../features/combos/data/datasources/combo_data_source.dart';
import '../../../features/combos/data/datasources/combo_mock_datasource.dart';
import '../../../features/combos/data/datasources/combo_remote_datasource.dart';
import '../../../features/combos/data/repositories/combo_repository_impl.dart';
import '../../../features/combos/domain/repositories/combo_repository.dart';
import '../../../features/combos/domain/usecases/calculate_pricing.dart';
import '../../../features/combos/domain/usecases/create_combo.dart';
import '../../../features/combos/domain/usecases/delete_combo.dart';
import '../../../features/combos/domain/usecases/get_combos.dart';
import '../../../features/combos/domain/usecases/update_combo.dart';
import '../../../features/combos/domain/usecases/validate_combo.dart';
import '../../../features/combos/presentation/bloc/crud/combo_crud_bloc.dart';
import '../../../features/combos/presentation/bloc/editor/combo_editor_bloc.dart';
import '../../../features/combos/presentation/bloc/filter/combo_filter_bloc.dart';
import '../../config/app_config.dart';

/// Combo feature module for dependency injection
class ComboModule {
  /// Initialize combo feature dependencies
  static Future<void> init(GetIt sl) async {
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
    sl.registerLazySingleton(() => const ValidateCombo());
    sl.registerLazySingleton(() => CalculatePricing(repository: sl()));

    // BLoCs (Factory - new instance each time)
    sl.registerFactory(() => ComboCrudBloc(
          uuid: const Uuid(),
          getCombos: sl(),
          createCombo: sl(),
          updateCombo: sl(),
          deleteCombo: sl(),
        ));

    sl.registerFactoryParam<ComboFilterBloc, ComboCrudBloc, void>(
      (crudBloc, _) => ComboFilterBloc(crudBloc: crudBloc),
    );

    sl.registerFactoryParam<ComboEditorBloc, ComboCrudBloc, void>(
      (crudBloc, _) => ComboEditorBloc(
        uuid: const Uuid(),
        validateCombo: sl(),
        calculatePricing: sl(),
        crudBloc: crudBloc,
      ),
    );
  }
}

