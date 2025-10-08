import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../orders/domain/entities/order_entity.dart';

/// Mock orders data source that loads from JSON files
class MockOrdersData {
  static Future<List<OrderEntity>> getMockOrders() async {
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/orders_data/orders_data.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);
      final now = DateTime.now();

      return jsonData.map((order) {
        return OrderEntity(
          id: order['id'],
          queueNumber: order['queueNumber'],
          channel: OrderChannel.values.firstWhere(
            (e) => e.toString().split('.').last == order['channel'],
          ),
          orderType: OrderType.values.firstWhere(
            (e) => e.toString().split('.').last == order['orderType'],
          ),
          paymentStatus: PaymentStatus.values.firstWhere(
            (e) => e.toString().split('.').last == order['paymentStatus'],
          ),
          status: OrderStatus.values.firstWhere(
            (e) => e.toString().split('.').last == order['status'],
          ),
          customerName: order['customerName'],
          customerPhone: order['customerPhone'],
          items: (order['items'] as List<dynamic>).map((item) {
            return OrderItemEntity(
              name: item['name'],
              quantity: item['quantity'],
              price: item['price'].toDouble(),
            );
          }).toList(),
          subtotal: order['subtotal'].toDouble(),
          tax: order['tax'].toDouble(),
          total: order['total'].toDouble(),
          createdAt: now.subtract(
            Duration(minutes: order['createdAtMinutes'] ?? 0),
          ),
          estimatedTime: now.add(
            Duration(minutes: order['estimatedTimeMinutes'] ?? 0),
          ),
          specialInstructions: order['specialInstructions'],
        );
      }).toList();
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
}
