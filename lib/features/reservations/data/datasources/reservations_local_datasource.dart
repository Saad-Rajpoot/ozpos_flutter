import '../../../../core/errors/exceptions.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/reservation_entity.dart';
import '../models/reservation_model.dart';
import 'reservations_data_source.dart';

class ReservationsLocalDataSourceImpl implements ReservationsDataSource {
  final Database database;

  ReservationsLocalDataSourceImpl({required this.database});

  @override
  Future<List<ReservationEntity>> getReservations() async {
    try {
      // Assuming a local table named 'reservations'
      final List<Map<String, dynamic>> maps = await database.query(
        'reservations',
      );
      return maps
          .map((json) => ReservationModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch reservations from local database',
      );
    }
  }
}
