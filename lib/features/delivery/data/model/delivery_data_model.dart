import 'package:equatable/equatable.dart';
import '../../domain/entities/delivery_entities.dart';
import 'kpi_data_model.dart';
import 'driver_model.dart';
import 'order_model.dart';

/// Model class for DeliveryData JSON serialization/deserialization
class DeliveryDataModel extends Equatable {
  final KPIDataModel kpiData;
  final List<DriverModel> drivers;
  final List<OrderModel> orders;

  const DeliveryDataModel({
    required this.kpiData,
    required this.drivers,
    required this.orders,
  });

  /// Convert JSON to DeliveryDataModel
  factory DeliveryDataModel.fromJson(Map<String, dynamic> json) {
    return DeliveryDataModel(
      kpiData: KPIDataModel.fromJson(json['kpiData'] as Map<String, dynamic>),
      drivers: (json['drivers'] as List<dynamic>)
          .map((driver) => DriverModel.fromJson(driver as Map<String, dynamic>))
          .toList(),
      orders: (json['orders'] as List<dynamic>)
          .map((order) => OrderModel.fromJson(order as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert DeliveryDataModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'kpiData': kpiData.toJson(),
      'drivers': drivers.map((driver) => driver.toJson()).toList(),
      'orders': orders.map((order) => order.toJson()).toList(),
    };
  }

  /// Convert DeliveryDataModel to DeliveryData entity
  DeliveryData toEntity() {
    return DeliveryData(
      kpiData: kpiData.toEntity(),
      drivers: drivers.map((driver) => driver.toEntity()).toList(),
      orders: orders.map((order) => order.toEntity()).toList(),
    );
  }

  /// Create DeliveryDataModel from DeliveryData entity
  factory DeliveryDataModel.fromEntity(DeliveryData entity) {
    return DeliveryDataModel(
      kpiData: KPIDataModel.fromEntity(entity.kpiData),
      drivers: entity.drivers
          .map((driver) => DriverModel.fromEntity(driver))
          .toList(),
      orders: entity.orders
          .map((order) => OrderModel.fromEntity(order))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [kpiData, drivers, orders];
}
