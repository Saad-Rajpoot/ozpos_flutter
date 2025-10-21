import '../../domain/entities/checkout_entity.dart';
import '../models/checkout_data.dart';
import '../models/order_model.dart';
import 'checkout_datasource.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CheckoutMockDataSource implements CheckoutDataSource {
  @override
  Future<CheckoutEntity> saveOrder(OrderModel orderModel) async {
    // Save to mock database
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/checkout_data/orders_data.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final CheckoutEntity checkoutEntity =
          CheckoutData.fromJson(jsonData).toEntity();
      checkoutEntity.orders.add(orderModel.toEntity());
      return checkoutEntity;
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(
          'assets/checkout_data/orders_data_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(
          errorData['message'] ?? 'Failed to load orders data',
        );
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load orders data: $e');
      }
    }
  }
}
