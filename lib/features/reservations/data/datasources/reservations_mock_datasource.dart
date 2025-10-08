import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/entities/reservation_entity.dart';
import 'reservations_remote_datasource.dart';

/// Mock reservations data source that loads from JSON files
class ReservationsMockDataSourceImpl implements ReservationsRemoteDataSource {
  static const _successFile = 'assets/reservations_data/reservations.json';
  static const _errorFile = 'assets/reservations_data/reservations_error.json';

  /// Load reservations from JSON file
  static Future<List<ReservationEntity>> _getMockReservations() async {
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(_successFile);
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((reservation) {
        return ReservationEntity(
          reservationId: reservation['reservationId'],
          vendorId: reservation['vendorId'],
          branchId: reservation['branchId'],
          tableId: reservation['tableId'],
          guest: GuestInfo(
            name: reservation['guest']['name'],
            phone: reservation['guest']['phone'],
          ),
          party: PartyDetails(size: reservation['party']['size']),
          timing: ReservationTiming(
            startAt: DateTime.parse(reservation['timing']['startAt']),
            durationMinutes: reservation['timing']['durationMinutes'],
          ),
          status: ReservationStatus.values.firstWhere(
            (e) => e.toString().split('.').last == reservation['status'],
          ),
          source: ReservationSource.values.firstWhere(
            (e) => e.toString().split('.').last == reservation['source'],
          ),
          preferences: ReservationPreferences(
            tags: List<String>.from(reservation['preferences']['tags'] ?? []),
          ),
          financials: ReservationFinancials(
            depositAmount: reservation['financials']['depositAmount']
                ?.toDouble(),
            depositStatus: reservation['financials']['depositStatus'] != null
                ? DepositStatus.values.firstWhere(
                    (e) =>
                        e.toString().split('.').last ==
                        reservation['financials']['depositStatus'],
                  )
                : null,
          ),
          audit: AuditInfo(
            createdBy: reservation['audit']['createdBy'],
            createdAt: DateTime.parse(reservation['audit']['createdAt']),
          ),
        );
      }).toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(_errorFile);
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(errorData['message'] ?? 'Failed to load reservations');
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load reservations: $e');
      }
    }
  }

  @override
  Future<List<ReservationEntity>> getReservations() async {
    // Simulate network delay for realistic testing
    await Future.delayed(const Duration(milliseconds: 500));
    return await _getMockReservations();
  }

  @override
  Future<List<ReservationEntity>> getReservationsByDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final reservations = await _getMockReservations();
    return reservations.where((reservation) {
      final reservationDate = DateTime(
        reservation.timing.startAt.year,
        reservation.timing.startAt.month,
        reservation.timing.startAt.day,
      );
      return reservationDate.year == date.year &&
          reservationDate.month == date.month &&
          reservationDate.day == date.day;
    }).toList();
  }

  @override
  Future<ReservationEntity> getReservationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final reservations = await _getMockReservations();
    final reservation = reservations
        .where((res) => res.reservationId == id)
        .firstOrNull;
    if (reservation == null) {
      throw Exception('Reservation not found');
    }
    return reservation;
  }

  @override
  Future<ReservationEntity> createReservation(
    ReservationEntity reservation,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Simulate successful creation
    return reservation.copyWith(
      reservationId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  @override
  Future<ReservationEntity> updateReservation(
    ReservationEntity reservation,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Simulate successful update
    return reservation;
  }

  @override
  Future<void> cancelReservation(String reservationId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Simulate successful cancellation
  }

  @override
  Future<ReservationEntity> seatReservation(
    String reservationId,
    String tableId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final reservations = await _getMockReservations();
    final reservation = reservations
        .where((res) => res.reservationId == reservationId)
        .firstOrNull;
    if (reservation == null) {
      throw Exception('Reservation not found');
    }

    return reservation.copyWith(
      status: ReservationStatus.seated,
      tableId: tableId,
    );
  }

  @override
  Future<ReservationEntity> checkoutReservation(String reservationId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final reservations = await _getMockReservations();
    final reservation = reservations
        .where((res) => res.reservationId == reservationId)
        .firstOrNull;
    if (reservation == null) {
      throw Exception('Reservation not found');
    }

    return reservation.copyWith(status: ReservationStatus.completed);
  }
}

// Extension to add firstOrNull method if not available
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
