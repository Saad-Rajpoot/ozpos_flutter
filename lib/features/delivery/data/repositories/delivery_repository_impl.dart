import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/repository_error_handler.dart';
import '../../domain/entities/delivery_entities.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../datasources/delivery_data_source.dart';

/// Delivery repository implementation
class DeliveryRepositoryImpl implements DeliveryRepository {
  final DeliveryDataSource deliveryDataSource;
  final NetworkInfo networkInfo;

  DeliveryRepositoryImpl({
    required this.deliveryDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, DeliveryData>> getDeliveryData() async {
    return RepositoryErrorHandler.handleOperation<DeliveryData>(
      operation: () async => await deliveryDataSource.getDeliveryData(),
      networkInfo: networkInfo,
      operationName: 'loading delivery data',
    );
  }
}
