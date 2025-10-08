import 'package:dartz/dartz.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
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
    // In development mode, always use mock data for testing
    if (AppConfig.instance.environment == AppEnvironment.development) {
      try {
        final reservations = await reservationsDataSource.getReservations();
        return Right(reservations);
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to load mock data: $e'));
      }
    }

    // In production, check network connectivity
    if (await networkInfo.isConnected) {
      try {
        final reservations = await reservationsDataSource.getReservations();
        return Right(reservations);
      } on ServerException {
        return Left(ServerFailure(message: 'Server error'));
      }
    } else {
      return Left(NetworkFailure(message: 'Network error'));
    }
  }
}
