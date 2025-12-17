import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/combo_option_entity.dart';
import '../repositories/combo_repository.dart';

/// Use case to get combo options from repository
class GetComboOptions implements UseCase<List<ComboOptionEntity>, NoParams> {
  final ComboRepository repository;

  GetComboOptions(this.repository);

  @override
  Future<Either<Failure, List<ComboOptionEntity>>> call(NoParams params) async {
    return repository.getComboOptions();
  }
}
