import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/combo_entity.dart';
import '../../domain/entities/combo_slot_entity.dart';
import '../../domain/entities/combo_availability_entity.dart';
import '../../domain/entities/combo_limits_entity.dart';
import '../../domain/entities/combo_option_entity.dart';
import '../../domain/entities/combo_pricing_entity.dart';
import '../models/combo_model.dart';
import '../models/combo_slot_model.dart';
import '../models/combo_availability_model.dart';
import '../models/combo_limits_model.dart';
import '../models/combo_option_model.dart';
import '../models/combo_pricing_model.dart';
import 'combo_data_source.dart';

/// Mock combos data source that loads from JSON files
class ComboMockDataSourceImpl implements ComboDataSource {
  /// Load combos from JSON file
  /// Simulates API behavior: tries to load success data, falls back to error data on failure
  @override
  Future<List<ComboEntity>> getCombos() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/combo_data/combo_entity.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((comboData) {
        final comboModel = ComboModel.fromJson(
          comboData as Map<String, dynamic>,
        );
        return comboModel.toEntity();
      }).toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(
          'assets/combo_data/combo_entity_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(errorData['message'] ?? 'Failed to load combos');
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load combos: $e');
      }
    }
  }

  /// Load combo slots from JSON file
  /// Simulates API behavior: tries to load success data, falls back to error data on failure
  @override
  Future<List<ComboSlotEntity>> getComboSlots() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/combo_data/combo_slot_entity.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((slotData) {
        final slotModel = ComboSlotModel.fromJson(
          slotData as Map<String, dynamic>,
        );
        return slotModel.toEntity();
      }).toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(
          'assets/combo_data/combo_slot_entity_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(errorData['message'] ?? 'Failed to load combo slots');
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load combo slots: $e');
      }
    }
  }

  /// Load combo availability from JSON file
  /// Simulates API behavior: tries to load success data, falls back to error data on failure
  @override
  Future<List<ComboAvailabilityEntity>> getComboAvailability() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/combo_data/combo_availability_entity.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((availabilityData) {
        final availabilityModel = ComboAvailabilityModel.fromJson(
          availabilityData as Map<String, dynamic>,
        );
        return availabilityModel.toEntity();
      }).toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(
          'assets/combo_data/combo_availability_entity_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(
          errorData['message'] ?? 'Failed to load combo availability',
        );
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load combo availability: $e');
      }
    }
  }

  /// Load combo limits from JSON file
  /// Simulates API behavior: tries to load success data, falls back to error data on failure
  @override
  Future<List<ComboLimitsEntity>> getComboLimits() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/combo_data/combo_limits_entity.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((limitsData) {
        final limitsModel = ComboLimitsModel.fromJson(
          limitsData as Map<String, dynamic>,
        );
        return limitsModel.toEntity();
      }).toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(
          'assets/combo_data/combo_limits_entity_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(errorData['message'] ?? 'Failed to load combo limits');
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load combo limits: $e');
      }
    }
  }

  /// Load combo options from JSON file
  /// Simulates API behavior: tries to load success data, falls back to error data on failure
  @override
  Future<List<ComboOptionEntity>> getComboOptions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/combo_data/combo_option_entity.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((optionData) {
        final optionModel = ComboOptionModel.fromJson(
          optionData as Map<String, dynamic>,
        );
        return optionModel.toEntity();
      }).toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(
          'assets/combo_data/combo_option_entity_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(errorData['message'] ?? 'Failed to load combo options');
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load combo options: $e');
      }
    }
  }

  /// Load combo pricing from JSON file
  /// Simulates API behavior: tries to load success data, falls back to error data on failure
  @override
  Future<List<ComboPricingEntity>> getComboPricing() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/combo_data/combo_pricing_entity.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((pricingData) {
        final pricingModel = ComboPricingModel.fromJson(
          pricingData as Map<String, dynamic>,
        );
        return pricingModel.toEntity();
      }).toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(
          'assets/combo_data/combo_pricing_entity_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(errorData['message'] ?? 'Failed to load combo pricing');
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load combo pricing: $e');
      }
    }
  }

  @override
  Future<ComboEntity> createCombo(ComboEntity combo) {
    return Future.value(combo);
  }

  @override
  Future<ComboEntity> updateCombo(ComboEntity combo) {
    return Future.value(combo);
  }

  @override
  Future<void> deleteCombo(String comboId) {
    return Future.value();
  }

  @override
  Future<ComboEntity> duplicateCombo(String comboId, {String? newName}) {
    return Future.value(ComboEntity(
        id: comboId,
        name: newName ?? '',
        description: '',
        status: ComboStatus.active,
        slots: [],
        pricing: ComboPricingEntity(
            mode: PricingMode.fixed,
            fixedPrice: 0,
            percentOff: 0,
            amountOff: 0,
            mixCategoryId: '',
            mixCategoryName: '',
            mixQuantity: 0,
            mixPrice: 0,
            mixPercentOff: 0,
            totalIfSeparate: 0,
            finalPrice: 0,
            savings: 0,
            calculatedAt: DateTime.now()),
        availability: ComboAvailabilityEntity(
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            daysOfWeek: [],
            posSystem: false,
            onlineMenu: false),
        limits: ComboLimitsEntity(
            maxPerCustomer: 0,
            customerLimitPeriod: Duration.zero,
            maxPerOrder: 0,
            allowStackingWithOtherPromos: false,
            allowStackingWithItemDiscounts: false),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        hasUnsavedChanges: false));
  }

  @override
  Future<PaginatedResponse<ComboEntity>> getCombosPaginated({
    PaginationParams? pagination,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final params = pagination ?? const PaginationParams();
    final allCombos = await getCombos();
    
    final totalItems = allCombos.length;
    final totalPages = (totalItems / params.limit).ceil();
    final startIndex = (params.page - 1) * params.limit;
    final endIndex = (startIndex + params.limit).clamp(0, totalItems);
    final paginatedCombos = allCombos.sublist(
      startIndex.clamp(0, totalItems),
      endIndex,
    );

    return PaginatedResponse<ComboEntity>(
      data: paginatedCombos,
      currentPage: params.page,
      totalPages: totalPages,
      totalItems: totalItems,
      perPage: params.limit,
    );
  }

  @override
  Future<PaginatedResponse<ComboSlotEntity>> getComboSlotsPaginated({
    PaginationParams? pagination,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final params = pagination ?? const PaginationParams();
    final allSlots = await getComboSlots();
    
    final totalItems = allSlots.length;
    final totalPages = (totalItems / params.limit).ceil();
    final startIndex = (params.page - 1) * params.limit;
    final endIndex = (startIndex + params.limit).clamp(0, totalItems);
    final paginatedSlots = allSlots.sublist(
      startIndex.clamp(0, totalItems),
      endIndex,
    );

    return PaginatedResponse<ComboSlotEntity>(
      data: paginatedSlots,
      currentPage: params.page,
      totalPages: totalPages,
      totalItems: totalItems,
      perPage: params.limit,
    );
  }

  @override
  Future<PaginatedResponse<ComboAvailabilityEntity>> getComboAvailabilityPaginated({
    PaginationParams? pagination,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final params = pagination ?? const PaginationParams();
    final allAvailability = await getComboAvailability();
    
    final totalItems = allAvailability.length;
    final totalPages = (totalItems / params.limit).ceil();
    final startIndex = (params.page - 1) * params.limit;
    final endIndex = (startIndex + params.limit).clamp(0, totalItems);
    final paginatedAvailability = allAvailability.sublist(
      startIndex.clamp(0, totalItems),
      endIndex,
    );

    return PaginatedResponse<ComboAvailabilityEntity>(
      data: paginatedAvailability,
      currentPage: params.page,
      totalPages: totalPages,
      totalItems: totalItems,
      perPage: params.limit,
    );
  }

  @override
  Future<PaginatedResponse<ComboLimitsEntity>> getComboLimitsPaginated({
    PaginationParams? pagination,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final params = pagination ?? const PaginationParams();
    final allLimits = await getComboLimits();
    
    final totalItems = allLimits.length;
    final totalPages = (totalItems / params.limit).ceil();
    final startIndex = (params.page - 1) * params.limit;
    final endIndex = (startIndex + params.limit).clamp(0, totalItems);
    final paginatedLimits = allLimits.sublist(
      startIndex.clamp(0, totalItems),
      endIndex,
    );

    return PaginatedResponse<ComboLimitsEntity>(
      data: paginatedLimits,
      currentPage: params.page,
      totalPages: totalPages,
      totalItems: totalItems,
      perPage: params.limit,
    );
  }

  @override
  Future<PaginatedResponse<ComboOptionEntity>> getComboOptionsPaginated({
    PaginationParams? pagination,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final params = pagination ?? const PaginationParams();
    final allOptions = await getComboOptions();
    
    final totalItems = allOptions.length;
    final totalPages = (totalItems / params.limit).ceil();
    final startIndex = (params.page - 1) * params.limit;
    final endIndex = (startIndex + params.limit).clamp(0, totalItems);
    final paginatedOptions = allOptions.sublist(
      startIndex.clamp(0, totalItems),
      endIndex,
    );

    return PaginatedResponse<ComboOptionEntity>(
      data: paginatedOptions,
      currentPage: params.page,
      totalPages: totalPages,
      totalItems: totalItems,
      perPage: params.limit,
    );
  }

  @override
  Future<PaginatedResponse<ComboPricingEntity>> getComboPricingPaginated({
    PaginationParams? pagination,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final params = pagination ?? const PaginationParams();
    final allPricing = await getComboPricing();
    
    final totalItems = allPricing.length;
    final totalPages = (totalItems / params.limit).ceil();
    final startIndex = (params.page - 1) * params.limit;
    final endIndex = (startIndex + params.limit).clamp(0, totalItems);
    final paginatedPricing = allPricing.sublist(
      startIndex.clamp(0, totalItems),
      endIndex,
    );

    return PaginatedResponse<ComboPricingEntity>(
      data: paginatedPricing,
      currentPage: params.page,
      totalPages: totalPages,
      totalItems: totalItems,
      perPage: params.limit,
    );
  }
}
