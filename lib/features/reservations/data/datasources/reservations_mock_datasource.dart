import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/entities/reservation_entity.dart';
import '../models/reservation_model.dart';
import 'reservations_data_source.dart';

/// Mock reservations data source that loads from JSON files
class ReservationsMockDataSourceImpl implements ReservationsDataSource {
  static const _successFile = 'assets/reservations_data/reservations.json';
  static const _errorFile = 'assets/reservations_data/reservations_error.json';

  @override
  Future<List<ReservationEntity>> getReservations() async {
    // Simulate network delay for realistic testing
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(_successFile);
      final List<dynamic> jsonData = json.decode(jsonString);

      final reservations = jsonData.map((reservationData) {
        final reservationModel = ReservationModel.fromJson(
          reservationData as Map<String, dynamic>,
        );
        return reservationModel.toEntity();
      }).toList();

      return reservations;
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(_errorFile);
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(errorData['message'] ?? 'Failed to load reservations');
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load reservations: ${e.toString()}');
      }
    }
  }
}
