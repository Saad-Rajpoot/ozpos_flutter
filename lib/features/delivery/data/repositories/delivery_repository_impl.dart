import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
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
    if (await networkInfo.isConnected) {
      try {
        final deliveryData = await deliveryDataSource.getDeliveryData();
        return Right(deliveryData);
      } on ServerException {
        return Left(ServerFailure(message: 'Server error'));
      }
    } else {
      return Left(NetworkFailure(message: 'Network error'));
    }
  }
}
