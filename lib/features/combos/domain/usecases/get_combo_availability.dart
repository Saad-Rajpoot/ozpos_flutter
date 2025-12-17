import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/combo_availability_entity.dart';
import '../repositories/combo_repository.dart';

/// Use case to get combo availability from repository
class GetComboAvailability
    implements UseCase<List<ComboAvailabilityEntity>, NoParams> {
  final ComboRepository repository;

  GetComboAvailability(this.repository);

  @override
  Future<Either<Failure, List<ComboAvailabilityEntity>>> call(
    NoParams params,
  ) async {
    return repository.getComboAvailability();
  }
}
