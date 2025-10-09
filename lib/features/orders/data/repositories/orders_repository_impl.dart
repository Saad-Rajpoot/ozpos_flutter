import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_data_source.dart';

/// Orders repository implementation
class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersDataSource ordersDataSource;
  final NetworkInfo networkInfo;

  OrdersRepositoryImpl({
    required this.ordersDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders() async {
    if (await networkInfo.isConnected) {
      try {
        final orders = await ordersDataSource.getOrders();
        return Right(orders);
      } on ServerException {
        return Left(ServerFailure(message: 'Server error'));
      }
    } else {
      return Left(NetworkFailure(message: 'Network error'));
    }
  }
}
