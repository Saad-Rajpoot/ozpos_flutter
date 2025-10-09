import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/delivery_entities.dart';
import '../repositories/delivery_repository.dart';

/// Use case to get delivery data from repository
class GetDeliveryData implements UseCase<DeliveryData, NoParams> {
  final DeliveryRepository repository;

  GetDeliveryData(this.repository);

  @override
  Future<Either<Failure, DeliveryData>> call(NoParams params) async {
    return repository.getDeliveryData();
  }
}
