import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

/// Use case to get orders from repository
class GetOrders implements UseCase<List<OrderEntity>, NoParams> {
  final OrdersRepository repository;

  GetOrders(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(NoParams params) async {
    return repository.getOrders();
  }
}
