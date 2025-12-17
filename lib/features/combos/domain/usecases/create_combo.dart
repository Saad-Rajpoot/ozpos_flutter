import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/combo_entity.dart';
import '../repositories/combo_repository.dart';

/// Create combo use case
class CreateCombo implements UseCase<ComboEntity, CreateComboParams> {
  final ComboRepository repository;

  CreateCombo({required this.repository});

  @override
  Future<Either<Failure, ComboEntity>> call(CreateComboParams params) async {
    return repository.createCombo(params.combo);
  }
}

class CreateComboParams {
  final ComboEntity combo;

  const CreateComboParams({required this.combo});
}
