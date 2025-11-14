import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/reservation_entity.dart';

/// Remote data source interface for reservations
abstract class ReservationsDataSource {
  /// Get all reservations
  Future<List<ReservationEntity>> getReservations();

  /// Get all reservations with pagination
  Future<PaginatedResponse<ReservationEntity>> getReservationsPaginated({
    PaginationParams? pagination,
  });
}
