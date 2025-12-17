import 'package:get_it/get_it.dart';

import '../../../features/reservations/data/datasources/reservations_data_source.dart';
import '../../../features/reservations/data/datasources/reservations_mock_datasource.dart';
import '../../../features/reservations/data/datasources/reservations_remote_datasource.dart';
import '../../../features/reservations/data/repositories/reservation_repository_impl.dart';
import '../../../features/reservations/domain/repositories/reservation_repository.dart';
import '../../../features/reservations/domain/usecases/get_reservations.dart';
import '../../../features/reservations/presentation/bloc/reservation_management_bloc.dart';
import '../../config/app_config.dart';

/// Reservation feature module for dependency injection
class ReservationModule {
  /// Initialize reservation feature dependencies
  static Future<void> init(GetIt sl) async {
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
}

