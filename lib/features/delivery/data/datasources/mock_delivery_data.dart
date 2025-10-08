import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../delivery/domain/entities/delivery_entities.dart';

class MockDeliveryData {
  static Future<DeliveryKpiData> getKpis() async {
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/delivery_data/delivery_data.json',
      );
      final Map<String, dynamic> deliveryData = json.decode(jsonString);
      final kpiData = deliveryData['kpiData'] as Map<String, dynamic>;

      return DeliveryKpiData(
        activeDrivers: kpiData['activeDrivers'],
        inProgress: kpiData['inProgress'],
        delayedOrders: kpiData['delayedOrders'],
        avgEtaMinutes: kpiData['avgEtaMinutes'],
      );
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJson = await rootBundle.loadString(
          'assets/delivery_data/delivery_data_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJson);
        throw Exception(
          errorData['message'] ?? 'Failed to load delivery KPI data',
        );
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load delivery KPI data: $e');
      }
    }
  }

  static Future<List<DriverEntity>> getDrivers() async {
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/delivery_data/delivery_data.json',
      );
      final Map<String, dynamic> deliveryData = json.decode(jsonString);
      final driversData = deliveryData['drivers'] as List<dynamic>;

      return driversData.map((driver) {
        return DriverEntity(
          id: driver['id'],
          name: driver['name'],
          status: DriverStatus.values.firstWhere(
            (e) => e.toString().split('.').last == driver['status'],
          ),
          role: driver['role'],
          zone: driver['zone'],
          currentOrders: driver['currentOrders'],
          maxCapacity: driver['maxCapacity'],
          avgTimeMinutes: driver['avgTimeMinutes'],
          todayEarnings: driver['todayEarnings'].toDouble(),
          latitude: driver['latitude'].toDouble(),
          longitude: driver['longitude'].toDouble(),
        );
      }).toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJson = await rootBundle.loadString(
          'assets/delivery_data/delivery_data_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJson);
        throw Exception(
          errorData['message'] ?? 'Failed to load delivery drivers',
        );
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load delivery drivers: $e');
      }
    }
  }

  static Future<List<DeliveryOrderEntity>> getOrders() async {
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/delivery_data/delivery_data.json',
      );
      final Map<String, dynamic> deliveryData = json.decode(jsonString);
      final ordersData = deliveryData['orders'] as List<dynamic>;
      final now = DateTime.now();

      return ordersData.map((order) {
        return DeliveryOrderEntity(
          id: order['id'],
          orderNumber: order['orderNumber'],
          channel: OrderChannel.values.firstWhere(
            (e) => e.toString().split('.').last == order['channel'],
          ),
          status: DeliveryOrderStatus.values.firstWhere(
            (e) => e.toString().split('.').last == order['status'],
          ),
          customerName: order['customerName'],
          address: order['address'],
          items: List<String>.from(order['items']),
          pickupEtaMinutes: order['pickupEtaMinutes'],
          deliveryEtaMinutes: order['deliveryEtaMinutes'],
          assignedDriverId: order['assignedDriverId'],
          pickupLatitude: order['pickupLatitude'].toDouble(),
          pickupLongitude: order['pickupLongitude'].toDouble(),
          deliveryLatitude: order['deliveryLatitude'].toDouble(),
          deliveryLongitude: order['deliveryLongitude'].toDouble(),
          createdAt: now.subtract(
            Duration(minutes: order['createdAtMinutes'] ?? 0),
          ),
        );
      }).toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJson = await rootBundle.loadString(
          'assets/delivery_data/delivery_data_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJson);
        throw Exception(
          errorData['message'] ?? 'Failed to load delivery orders',
        );
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load delivery orders: $e');
      }
    }
  }
}
