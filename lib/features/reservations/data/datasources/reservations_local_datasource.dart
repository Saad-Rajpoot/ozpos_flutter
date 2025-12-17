import '../../../../core/errors/exceptions.dart';
import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
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

  @override
  Future<PaginatedResponse<ReservationEntity>> getReservationsPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final allMaps = await database.query('reservations');
      final allItems = allMaps
          .map((json) => ReservationModel.fromJson(json).toEntity())
          .toList();
      
      final totalItems = allItems.length;
      final totalPages = (totalItems / params.limit).ceil();
      final startIndex = (params.page - 1) * params.limit;
      final endIndex = (startIndex + params.limit).clamp(0, totalItems);
      final paginatedItems = allItems.sublist(
        startIndex.clamp(0, totalItems),
        endIndex,
      );

      return PaginatedResponse<ReservationEntity>(
        data: paginatedItems,
        currentPage: params.page,
        totalPages: totalPages,
        totalItems: totalItems,
        perPage: params.limit,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch reservations from local database',
      );
    }
  }
}
