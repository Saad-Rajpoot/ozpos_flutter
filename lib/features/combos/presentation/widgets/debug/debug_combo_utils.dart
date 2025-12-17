import 'dart:convert';
import '../../../domain/entities/combo_entity.dart';
import '../../../domain/entities/combo_availability_entity.dart';
import '../../../domain/entities/combo_limits_entity.dart';
import '../../../domain/entities/combo_pricing_entity.dart';
import 'debug_combo_data.dart';

/// Utility functions for debug combo builder

class DebugComboUtils {
  /// Format order type for display
  static String formatOrderType(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return 'Dine In';
      case OrderType.takeaway:
        return 'Takeaway';
      case OrderType.delivery:
        return 'Delivery';
      case OrderType.online:
        return 'Online Order';
    }
  }

  /// Capitalize first letter of string
  static String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  /// Build item metadata string
  static String buildItemMeta(DebugMenuItem item) {
    final parts = <String>[
      capitalize(item.category),
      '\$${item.price.toStringAsFixed(2)}',
      item.sizes.isEmpty
          ? 'No sizes'
          : '${item.sizes.length} size${item.sizes.length == 1 ? '' : 's'}',
      item.modifiers.isEmpty
          ? 'No modifiers'
          : '${item.modifiers.length} modifier${item.modifiers.length == 1 ? '' : 's'}',
    ];

    return parts.join(' \u2022 ');
  }

  /// Convert combo entity to debug map for console logging
  static Map<String, dynamic> comboToDebugMap(ComboEntity combo) {
    return {
      'id': combo.id,
      'name': combo.name,
      'description': combo.description,
      'status': combo.status.name,
      'categoryTag': combo.categoryTag,
      'pointsReward': combo.pointsReward,
      'createdAt': combo.createdAt.toIso8601String(),
      'updatedAt': combo.updatedAt.toIso8601String(),
      'items': combo.slots
          .map(
            (slot) => {
              'id': slot.id,
              'name': slot.name,
              'sourceType': slot.sourceType.name,
              'specificItemIds': slot.specificItemIds,
              'specificItemNames': slot.specificItemNames,
              'categoryId': slot.categoryId,
              'categoryName': slot.categoryName,
              'required': slot.required,
              'defaultIncluded': slot.defaultIncluded,
              'allowQuantityChange': slot.allowQuantityChange,
              'maxQuantity': slot.maxQuantity,
              'defaultPrice': slot.defaultPrice,
              'allowedSizeIds': slot.allowedSizeIds,
              'defaultSizeId': slot.defaultSizeId,
              'modifierGroupAllowed': slot.modifierGroupAllowed,
              'modifierExclusions': slot.modifierExclusions,
              'sortOrder': slot.sortOrder,
            },
          )
          .toList(),
      'pricing': _pricingToMap(combo.pricing),
      'availability': _availabilityToMap(combo.availability),
      'limits': _limitsToMap(combo.limits),
    };
  }

  /// Convert combo to formatted JSON string for console
  static String comboToJsonString(ComboEntity combo) {
    final map = comboToDebugMap(combo);
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  static Map<String, dynamic> _pricingToMap(ComboPricingEntity pricing) {
    return {
      'mode': pricing.mode.name,
      'fixedPrice': pricing.fixedPrice,
      'percentOff': pricing.percentOff,
      'amountOff': pricing.amountOff,
      'mixCategoryId': pricing.mixCategoryId,
      'mixCategoryName': pricing.mixCategoryName,
      'mixQuantity': pricing.mixQuantity,
      'mixPrice': pricing.mixPrice,
      'mixPercentOff': pricing.mixPercentOff,
      'totalIndividualPrice': pricing.totalIfSeparate,
      'finalPrice': pricing.finalPrice,
      'savings': pricing.savings,
      'calculatedAt': pricing.calculatedAt?.toIso8601String(),
    };
  }

  static Map<String, dynamic> _availabilityToMap(
      ComboAvailabilityEntity availability) {
    return {
      'displayLocations': {
        'pos': availability.posSystem,
        'online': availability.onlineMenu,
      },
      'orderTypes': availability.orderTypes.map((e) => e.name).toList(),
      'timeRestrictions': availability.timeWindows
          .map(
            (window) => {
              'id': window.id,
              'name': window.name,
              'start': window.startTime.formatted,
              'end': window.endTime.formatted,
            },
          )
          .toList(),
      'dayRestrictions':
          availability.daysOfWeek.map((day) => day.name).toList(),
      'dateRange': {
        'start': availability.startDate?.toIso8601String(),
        'end': availability.endDate?.toIso8601String(),
      },
    };
  }

  static Map<String, dynamic> _limitsToMap(ComboLimitsEntity limits) {
    return {
      'maxPerOrder': limits.maxPerOrder,
      'maxPerDay': limits.maxPerDay,
      'maxPerCustomer': limits.maxPerCustomer,
      'customerLimitMinutes': limits.customerLimitPeriod?.inMinutes,
      'maxPerDevice': limits.maxPerDevice,
      'deviceLimitMinutes': limits.deviceLimitPeriod?.inMinutes,
      'allowStackingWithOtherPromos': limits.allowStackingWithOtherPromos,
      'allowStackingWithItemDiscounts': limits.allowStackingWithItemDiscounts,
      'excludeComboIds': limits.excludeComboIds,
      'autoApplyOnEligibility': limits.autoApplyOnEligibility,
      'showAsSuggestion': limits.showAsSuggestion,
      'allowedBranchIds': limits.allowedBranchIds,
      'excludedBranchIds': limits.excludedBranchIds,
    };
  }
}

