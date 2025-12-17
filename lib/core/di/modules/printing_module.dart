import 'package:get_it/get_it.dart';

import '../../../features/printing/data/datasources/printing_data_source.dart';
import '../../../features/printing/data/datasources/printing_mock_datasource.dart';
import '../../../features/printing/data/datasources/printing_remote_datasource.dart';
import '../../../features/printing/data/repositories/printing_repository_impl.dart';
import '../../../features/printing/domain/repositories/printing_repository.dart';
import '../../../features/printing/domain/usecases/add_printer.dart';
import '../../../features/printing/domain/usecases/get_printers.dart';
import '../../../features/printing/presentation/bloc/printing_bloc.dart';
import '../../config/app_config.dart';

/// Printing feature module for dependency injection
class PrintingModule {
  /// Initialize printing feature dependencies
  static Future<void> init(GetIt sl) async {
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
}

