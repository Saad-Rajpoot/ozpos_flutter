import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/repository_error_handler.dart';
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
    return RepositoryErrorHandler.handleOperation<List<OrderEntity>>(
      operation: () async => await ordersDataSource.getOrders(),
      networkInfo: networkInfo,
      operationName: 'loading orders',
    );
  }
}
