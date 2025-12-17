import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/modifier_group_entity.dart';
import '../services/modifier_validator.dart';

/// Use case for validating modifier selections
/// Encapsulates the business logic for validating modifier requirements
class ValidateModifierSelectionUseCase
    implements UseCase<bool, ValidateModifierSelectionParams> {
  const ValidateModifierSelectionUseCase();

  @override
  Future<Either<Failure, bool>> call(
    ValidateModifierSelectionParams params,
  ) async {
    try {
      final isValid = ModifierValidator.validateRequiredGroups(
        groups: params.groups,
        selectedModifiers: params.selectedModifiers,
      );

      if (!isValid) {
        return Left(ValidationFailure(
          message: 'Required modifier groups are not satisfied',
        ));
      }

      final respectsMaxSelections = ModifierValidator.validateMaxSelections(
        groups: params.groups,
        selectedModifiers: params.selectedModifiers,
      );

      if (!respectsMaxSelections) {
        return Left(ValidationFailure(
          message: 'Maximum selection limits exceeded',
        ));
      }

      return Right(true);
    } catch (e) {
      return Left(ValidationFailure(
        message: 'Modifier validation failed: ${e.toString()}',
      ));
    }
  }
}

/// Parameters for validating modifier selections
class ValidateModifierSelectionParams {
  final List<ModifierGroupEntity> groups;
  final Map<String, List<String>> selectedModifiers;

  const ValidateModifierSelectionParams({
    required this.groups,
    required this.selectedModifiers,
  });
}
