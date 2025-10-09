import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/delivery_entities.dart';

/// Delivery repository interface
abstract class DeliveryRepository {
  /// Get all delivery data
  Future<Either<Failure, DeliveryData>> getDeliveryData();
}
