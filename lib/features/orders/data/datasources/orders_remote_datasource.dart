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
    // Fetch only a bounded page of the most recent orders using standard
    // pagination query parameters to avoid downloading an unbounded history
    // payload on every dashboard/orders load.
    final pagination = PaginationParams.withLimit(AppConstants.maxPageSize);
    try {
      final response = await _apiClient.get(
        AppConstants.ordersHistoryEndpoint,
        queryParameters: pagination.toQueryParams(),
      );
      final body = response.data;
      if (body is Map<String, dynamic> && body['ok'] != true) {
        throw ServerException(
          message: 'Orders history API returned ok: false',
        );
      }
      final List<dynamic> data = ExceptionHelper.validateListResponse(
        body,
        'fetching orders',
        dataKey: 'orders',
      );
      return data
          .map((json) => OrderModel.fromHistoryApi(
                json is Map<String, dynamic> ? json : <String, dynamic>{},
              ).toEntity())
          .toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch orders');
    }
  }

  @override
  Future<PaginatedResponse<OrderEntity>> getOrdersPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final allOrders = await getOrders();
      final totalItems = allOrders.length;
      final totalPages = (totalItems / params.limit).ceil();
      final startIndex = (params.page - 1) * params.limit;
      final endIndex = (startIndex + params.limit).clamp(0, totalItems);
      final paginatedOrders = allOrders.sublist(
        startIndex.clamp(0, totalItems),
        endIndex,
      );
      return PaginatedResponse<OrderEntity>(
        data: paginatedOrders,
        currentPage: params.page,
        totalPages: totalPages,
        totalItems: totalItems,
        perPage: params.limit,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to fetch orders');
    }
  }
}
