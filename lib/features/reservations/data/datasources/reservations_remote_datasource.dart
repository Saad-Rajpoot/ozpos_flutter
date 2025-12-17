import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import 'reservations_data_source.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/reservation_entity.dart';
import '../models/reservation_model.dart';
import '../../../../core/utils/exception_helper.dart';

class ReservationsRemoteDataSourceImpl implements ReservationsDataSource {
  final ApiClient _apiClient;

  ReservationsRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<ReservationEntity>> getReservations() async {
    try {
      final response = await _apiClient.get(
        AppConstants.getReservationsEndpoint,
      );
      final List<dynamic> data = ExceptionHelper.validateListResponse(
        response.data,
        'fetching reservations',
      );
      return data
          .map((json) => ReservationModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch reservations');
    }
  }

  @override
  Future<PaginatedResponse<ReservationEntity>> getReservationsPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final response = await _apiClient.get(
        AppConstants.getReservationsEndpoint,
        queryParameters: params.toQueryParams(),
      );
      return ExceptionHelper.validatePaginatedResponse<ReservationEntity>(
        response.data,
        (json) => ReservationModel.fromJson(json).toEntity(),
        'fetching reservations',
      );
    } catch (e) {
      throw ServerException(message: 'Failed to fetch reservations');
    }
  }
}
