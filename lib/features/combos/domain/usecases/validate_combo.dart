import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/combo_entity.dart';
import '../repositories/combo_repository.dart';

/// Validate combo use case
class ValidateCombo implements UseCase<List<String>, ValidateComboParams> {
  final ComboRepository repository;

  ValidateCombo({required this.repository});

  @override
  Future<Either<Failure, List<String>>> call(ValidateComboParams params) async {
    return repository.validateCombo(params.combo);
  }
}

class ValidateComboParams {
  final ComboEntity combo;

  const ValidateComboParams({required this.combo});
}
