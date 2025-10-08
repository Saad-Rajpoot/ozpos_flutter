import '../../domain/entities/reservation_entity.dart';

/// Remote data source interface for reservations
abstract class ReservationsDataSource {
  /// Get all reservations
  Future<List<ReservationEntity>> getReservations();
}
