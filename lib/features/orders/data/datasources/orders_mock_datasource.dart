import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../models/order_model.dart';
import 'orders_data_source.dart';

/// Mock orders data source that loads from JSON files
class OrdersMockDataSourceImpl implements OrdersDataSource {
  @override
  Future<List<OrderEntity>> getOrders() async {
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/orders_data/orders_data.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData
          .map((order) => OrderModel.fromJson(order).toEntity())
          .toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(
          'assets/orders_data/orders_data_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(errorData['message'] ?? 'Failed to load orders data');
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load orders data: $e');
      }
    }
  }

  @override
  Future<PaginatedResponse<OrderEntity>> getOrdersPaginated({
    PaginationParams? pagination,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
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
  }
}
