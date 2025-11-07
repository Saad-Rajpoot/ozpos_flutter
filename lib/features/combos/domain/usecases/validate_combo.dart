import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/combo_entity.dart';
import '../entities/combo_validator.dart';

/// Validate combo use case
class ValidateCombo implements UseCase<List<String>, ValidateComboParams> {
  const ValidateCombo();

  @override
  Future<Either<Failure, List<String>>> call(ValidateComboParams params) async {
    try {
      final errors = ComboValidator.validateCombo(params.combo);
      return Right(errors);
    } catch (error) {
      return Left(
        ValidationFailure(message: 'Failed to validate combo: $error'),
      );
    }
  }
}

class ValidateComboParams {
  final ComboEntity combo;

  const ValidateComboParams({required this.combo});
}
