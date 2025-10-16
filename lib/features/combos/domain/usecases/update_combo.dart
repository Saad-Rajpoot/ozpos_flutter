import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/combo_entity.dart';
import '../repositories/combo_repository.dart';

/// Update combo use case
class UpdateCombo implements UseCase<ComboEntity, UpdateComboParams> {
  final ComboRepository repository;

  UpdateCombo({required this.repository});

  @override
  Future<Either<Failure, ComboEntity>> call(UpdateComboParams params) async {
    return repository.updateCombo(params.combo);
  }
}

class UpdateComboParams {
  final ComboEntity combo;

  const UpdateComboParams({required this.combo});
}
