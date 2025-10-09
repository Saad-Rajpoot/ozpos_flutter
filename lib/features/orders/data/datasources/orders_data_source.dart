import '../../domain/entities/order_entity.dart';

/// Abstract data source for orders
abstract class OrdersDataSource {
  /// Get all orders
  Future<List<OrderEntity>> getOrders();
}
