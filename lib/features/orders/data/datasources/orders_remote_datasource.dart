import '../../domain/entities/order_entity.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import '../models/order_model.dart';
import 'orders_data_source.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/exception_helper.dart';

class OrdersRemoteDataSourceImpl implements OrdersDataSource {
  final ApiClient _apiClient;

  OrdersRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<OrderEntity>> getOrders() async {
    try {
      final response = await _apiClient.get(AppConstants.getOrdersEndpoint);
      final List<dynamic> data = ExceptionHelper.validateListResponse(
        response.data,
        'fetching orders',
      );
      return data.map((json) => OrderModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch orders');
    }
  }

  @override
  Future<PaginatedResponse<OrderEntity>> getOrdersPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final response = await _apiClient.get(
        AppConstants.getOrdersEndpoint,
        queryParameters: params.toQueryParams(),
      );
      return ExceptionHelper.validatePaginatedResponse<OrderEntity>(
        response.data,
        (json) => OrderModel.fromJson(json).toEntity(),
        'fetching orders',
      );
    } catch (e) {
      throw ServerException(message: 'Failed to fetch orders');
    }
  }
}
