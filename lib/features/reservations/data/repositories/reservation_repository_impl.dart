import 'package:dartz/dartz.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/repository_error_handler.dart';
import '../../domain/entities/reservation_entity.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/reservations_data_source.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationsDataSource reservationsDataSource;
  final NetworkInfo networkInfo;

  ReservationRepositoryImpl({
    required this.reservationsDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ReservationEntity>>> getReservations() async {
    // In development mode, skip network check to allow mock data
    final skipNetworkCheck =
        AppConfig.instance.environment == AppEnvironment.development;

    return RepositoryErrorHandler.handleOperation<List<ReservationEntity>>(
      operation: () async => await reservationsDataSource.getReservations(),
      networkInfo: networkInfo,
      operationName: 'loading reservations',
      skipNetworkCheck: skipNetworkCheck,
    );
  }
}
