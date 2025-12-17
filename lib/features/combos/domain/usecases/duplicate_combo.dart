import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/combo_entity.dart';
import '../repositories/combo_repository.dart';

/// Duplicate combo use case
class DuplicateCombo implements UseCase<ComboEntity, DuplicateComboParams> {
  final ComboRepository repository;

  DuplicateCombo({required this.repository});

  @override
  Future<Either<Failure, ComboEntity>> call(DuplicateComboParams params) async {
    return repository.duplicateCombo(params.comboId, newName: params.newName);
  }
}

class DuplicateComboParams {
  final String comboId;
  final String? newName;

  const DuplicateComboParams({required this.comboId, this.newName});
}
