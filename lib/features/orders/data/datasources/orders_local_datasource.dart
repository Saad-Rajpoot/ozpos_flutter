import '../../domain/entities/order_entity.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import 'orders_data_source.dart';
import 'package:sqflite/sqflite.dart';
import '../models/order_model.dart';

class OrdersLocalDataSourceImpl implements OrdersDataSource {
  final Database database;

  OrdersLocalDataSourceImpl({required this.database});

  @override
  Future<List<OrderEntity>> getOrders() async {
    try {
      // Assuming a local table named 'orders'
      final List<Map<String, dynamic>> maps = await database.query('orders');
      return maps.map((json) => OrderModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch orders from local database',
      );
    }
  }

  @override
  Future<PaginatedResponse<OrderEntity>> getOrdersPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final allMaps = await database.query('orders');
      final allItems = allMaps
          .map((json) => OrderModel.fromJson(json).toEntity())
          .toList();
      
      final totalItems = allItems.length;
      final totalPages = (totalItems / params.limit).ceil();
      final startIndex = (params.page - 1) * params.limit;
      final endIndex = (startIndex + params.limit).clamp(0, totalItems);
      final paginatedItems = allItems.sublist(
        startIndex.clamp(0, totalItems),
        endIndex,
      );

      return PaginatedResponse<OrderEntity>(
        data: paginatedItems,
        currentPage: params.page,
        totalPages: totalPages,
        totalItems: totalItems,
        perPage: params.limit,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch orders from local database',
      );
    }
  }
}
