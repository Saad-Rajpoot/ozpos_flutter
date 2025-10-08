import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reservation_entity.dart';

/// Abstract repository interface for reservations
abstract class ReservationRepository {
  Future<Either<Failure, List<ReservationEntity>>> getReservations();
}
