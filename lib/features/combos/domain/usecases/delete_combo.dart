import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/combo_repository.dart';

/// Delete combo use case
class DeleteCombo implements UseCase<void, DeleteComboParams> {
  final ComboRepository repository;

  DeleteCombo({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeleteComboParams params) async {
    return repository.deleteCombo(params.comboId);
  }
}

class DeleteComboParams {
  final String comboId;

  const DeleteComboParams({required this.comboId});
}
