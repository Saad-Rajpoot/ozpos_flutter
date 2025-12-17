import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/combo_entity.dart';
import '../repositories/combo_repository.dart';

/// Use case to get combos from repository
class GetCombos implements UseCase<List<ComboEntity>, NoParams> {
  final ComboRepository repository;

  GetCombos(this.repository);

  @override
  Future<Either<Failure, List<ComboEntity>>> call(NoParams params) async {
    return repository.getCombos();
  }
}
