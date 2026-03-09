import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/repository_error_handler.dart';
import '../../../../core/db/orders_dao.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_data_source.dart';

/// Orders repository implementation
class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersDataSource ordersDataSource;
  final NetworkInfo networkInfo;
  final OrdersDao ordersDao;

  OrdersRepositoryImpl({
    required this.ordersDataSource,
    required this.networkInfo,
    required this.ordersDao,
  });

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders() async {
    return RepositoryErrorHandler.handleOperation<List<OrderEntity>>(
      operation: () async {
        final isConnected = await networkInfo.isConnected;

        if (isConnected) {
          // Online path: prefer live API result. Cache failures should not
          // prevent orders from being shown.
          final remoteOrders = await ordersDataSource.getOrders();
          try {
            await ordersDao.replaceAllForHistory(remoteOrders);
          } catch (e) {
            // Log and continue with remote data.
          }
          return remoteOrders;
        }

        final localOrders = await ordersDao.getOrdersWithItems();
        if (localOrders.isEmpty) {
          throw const CacheException(
            message: 'No cached orders available offline',
          );
        }
        return localOrders;
      },
      networkInfo: networkInfo,
      operationName: 'loading orders',
      skipNetworkCheck: true,
    );
  }
}
