import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
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

  /// Get all combos with pagination
  Future<PaginatedResponse<ComboEntity>> getCombosPaginated({
    PaginationParams? pagination,
  });

  /// Get combo slots
  Future<List<ComboSlotEntity>> getComboSlots();

  /// Get combo slots with pagination
  Future<PaginatedResponse<ComboSlotEntity>> getComboSlotsPaginated({
    PaginationParams? pagination,
  });

  /// Get combo availability data
  Future<List<ComboAvailabilityEntity>> getComboAvailability();

  /// Get combo availability data with pagination
  Future<PaginatedResponse<ComboAvailabilityEntity>> getComboAvailabilityPaginated({
    PaginationParams? pagination,
  });

  /// Get combo limits data
  Future<List<ComboLimitsEntity>> getComboLimits();

  /// Get combo limits data with pagination
  Future<PaginatedResponse<ComboLimitsEntity>> getComboLimitsPaginated({
    PaginationParams? pagination,
  });

  /// Get combo options data
  Future<List<ComboOptionEntity>> getComboOptions();

  /// Get combo options data with pagination
  Future<PaginatedResponse<ComboOptionEntity>> getComboOptionsPaginated({
    PaginationParams? pagination,
  });

  /// Get combo pricing data
  Future<List<ComboPricingEntity>> getComboPricing();

  /// Get combo pricing data with pagination
  Future<PaginatedResponse<ComboPricingEntity>> getComboPricingPaginated({
    PaginationParams? pagination,
  });

  /// Create a new combo
  Future<ComboEntity> createCombo(ComboEntity combo);

  /// Update an existing combo
  Future<ComboEntity> updateCombo(ComboEntity combo);

  /// Delete a combo
  Future<void> deleteCombo(String comboId);

  /// Duplicate a combo
  Future<ComboEntity> duplicateCombo(String comboId, {String? newName});
}
