import '../../domain/entities/delivery_entities.dart';

/// Abstract data source for delivery data
abstract class DeliveryDataSource {
  /// Get all delivery data
  Future<DeliveryData> getDeliveryData();
}
