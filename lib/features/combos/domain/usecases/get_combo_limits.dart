import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/combo_limits_entity.dart';
import '../repositories/combo_repository.dart';

/// Use case to get combo limits from repository
class GetComboLimits implements UseCase<List<ComboLimitsEntity>, NoParams> {
  final ComboRepository repository;

  GetComboLimits(this.repository);

  @override
  Future<Either<Failure, List<ComboLimitsEntity>>> call(NoParams params) async {
    return repository.getComboLimits();
  }
}
