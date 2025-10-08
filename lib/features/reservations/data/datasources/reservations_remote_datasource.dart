import '../../domain/entities/reservation_entity.dart';

/// Remote data source interface for reservations
abstract class ReservationsRemoteDataSource {
  /// Get all reservations
  Future<List<ReservationEntity>> getReservations();

  /// Get reservations by date
  Future<List<ReservationEntity>> getReservationsByDate(DateTime date);

  /// Get reservation by ID
  Future<ReservationEntity> getReservationById(String id);

  /// Create new reservation
  Future<ReservationEntity> createReservation(ReservationEntity reservation);

  /// Update reservation
  Future<ReservationEntity> updateReservation(ReservationEntity reservation);

  /// Cancel reservation
  Future<void> cancelReservation(String reservationId);

  /// Seat reservation
  Future<ReservationEntity> seatReservation(
    String reservationId,
    String tableId,
  );

  /// Checkout reservation
  Future<ReservationEntity> checkoutReservation(String reservationId);
}
