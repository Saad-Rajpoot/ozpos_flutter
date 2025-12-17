import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/order_entity.dart';

/// Abstract data source for orders
abstract class OrdersDataSource {
  /// Get all orders
  Future<List<OrderEntity>> getOrders();

  /// Get all orders with pagination
  Future<PaginatedResponse<OrderEntity>> getOrdersPaginated({
    PaginationParams? pagination,
  });
}
