import '../../domain/entities/combo_entity.dart';
import '../../domain/entities/combo_slot_entity.dart';
import '../../domain/entities/combo_availability_entity.dart';
import '../../domain/entities/combo_limits_entity.dart';
import '../../domain/entities/combo_option_entity.dart';
import '../../domain/entities/combo_pricing_entity.dart';

/// Data source interface for combos
abstract class ComboDataSource {
  /// Get all combos
  Future<List<ComboEntity>> getCombos();

  /// Get combo slots
  Future<List<ComboSlotEntity>> getComboSlots();

  /// Get combo availability data
  Future<List<ComboAvailabilityEntity>> getComboAvailability();

  /// Get combo limits data
  Future<List<ComboLimitsEntity>> getComboLimits();

  /// Get combo options data
  Future<List<ComboOptionEntity>> getComboOptions();

  /// Get combo pricing data
  Future<List<ComboPricingEntity>> getComboPricing();

  /// Create a new combo
  Future<ComboEntity> createCombo(ComboEntity combo);

  /// Update an existing combo
  Future<ComboEntity> updateCombo(ComboEntity combo);

  /// Delete a combo
  Future<void> deleteCombo(String comboId);

  /// Duplicate a combo
  Future<ComboEntity> duplicateCombo(String comboId, {String? newName});
}
