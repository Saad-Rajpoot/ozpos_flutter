import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';

/// Orders repository interface
abstract class OrdersRepository {
  /// Get all orders
  Future<Either<Failure, List<OrderEntity>>> getOrders();
}
