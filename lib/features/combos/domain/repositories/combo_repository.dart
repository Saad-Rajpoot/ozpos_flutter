import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/combo_entity.dart';
import '../entities/combo_slot_entity.dart';
import '../entities/combo_availability_entity.dart';
import '../entities/combo_limits_entity.dart';
import '../entities/combo_option_entity.dart';
import '../entities/combo_pricing_entity.dart';

/// Combo repository interface
abstract class ComboRepository {
  /// Get all combos
  Future<Either<Failure, List<ComboEntity>>> getCombos();

  /// Get combo slots
  Future<Either<Failure, List<ComboSlotEntity>>> getComboSlots();

  /// Get combo availability data
  Future<Either<Failure, List<ComboAvailabilityEntity>>> getComboAvailability();

  /// Get combo limits data
  Future<Either<Failure, List<ComboLimitsEntity>>> getComboLimits();

  /// Get combo options data
  Future<Either<Failure, List<ComboOptionEntity>>> getComboOptions();

  /// Get combo pricing data
  Future<Either<Failure, List<ComboPricingEntity>>> getComboPricing();

  /// Create a new combo
  Future<Either<Failure, ComboEntity>> createCombo(ComboEntity combo);

  /// Update an existing combo
  Future<Either<Failure, ComboEntity>> updateCombo(ComboEntity combo);

  /// Delete a combo
  Future<Either<Failure, void>> deleteCombo(String comboId);

  /// Duplicate a combo
  Future<Either<Failure, ComboEntity>> duplicateCombo(String comboId,
      {String? newName});

  /// Validate a combo
  Future<Either<Failure, List<String>>> validateCombo(ComboEntity combo);

  /// Calculate pricing for a combo
  Future<Either<Failure, ComboPricingEntity>> calculatePricing(
      ComboEntity combo);
}
