import 'combo_entity.dart';
import 'combo_pricing_entity.dart';
import 'combo_availability_entity.dart';
import 'combo_limits_entity.dart';
import 'combo_slot_entity.dart';

/// Business logic class for combo calculations and display logic
class ComboCalculator {
  /// Calculates if a combo is currently active
  static bool isActive(ComboEntity combo) {
    return combo.status == ComboStatus.active;
  }

  /// Calculates if a combo is currently visible
  static bool isVisible(ComboEntity combo) {
    return isActive(combo) && isCurrentlyAvailable(combo.availability);
  }

  /// Gets ribbon text for display (Popular, Limited Time, etc.)
  static List<String> getRibbons(ComboEntity combo) {
    final List<String> ribbons = [];

    // Add time-based ribbons
    if (isLimitedTime(combo.availability)) ribbons.add('Limited Time');
    if (isWeekendSpecial(combo.availability)) ribbons.add('Weekend Special');

    // Add popularity ribbon (would be computed from sales data)
    if (_isPopular(combo)) ribbons.add('Popular');

    // Add best value ribbon
    if (_isBestValue(combo)) ribbons.add('Best Value');

    return ribbons;
  }

  /// Gets savings text for display
  static String? getSavingsText(ComboEntity combo) {
    final savings = calculateSavings(combo);
    if (savings > 0) {
      return 'SAVE \$${savings.toStringAsFixed(2)}';
    }
    return null;
  }

  /// Calculates savings amount for a combo
  static double calculateSavings(ComboEntity combo) {
    switch (combo.pricing.mode) {
      case PricingMode.fixed:
        final totalSeparate = _calculateTotalIfSeparate(combo.slots);
        return totalSeparate > combo.pricing.fixedPrice!
            ? totalSeparate - combo.pricing.fixedPrice!
            : 0.0;

      case PricingMode.percentage:
        final totalSeparate = _calculateTotalIfSeparate(combo.slots);
        return totalSeparate * (combo.pricing.percentOff! / 100);

      case PricingMode.amount:
        final totalSeparate = _calculateTotalIfSeparate(combo.slots);
        return totalSeparate > combo.pricing.amountOff!
            ? combo.pricing.amountOff!
            : totalSeparate;

      case PricingMode.mixAndMatch:
        return _calculateMixAndMatchSavings(combo);
    }
  }

  /// Calculates final price for a combo
  static double calculateFinalPrice(ComboEntity combo) {
    final totalSeparate = _calculateTotalIfSeparate(combo.slots);
    final savings = calculateSavings(combo);
    return (totalSeparate - savings).clamp(0.0, double.infinity);
  }

  /// Gets component summary for display
  static List<String> getComponentSummary(ComboEntity combo) {
    return combo.slots.where((slot) => slot.defaultIncluded).map((slot) {
      if (slot.sourceType == SlotSourceType.specific) {
        return slot.specificItemNames.join(' or ');
      } else {
        return 'Any ${slot.categoryName}';
      }
    }).toList();
  }

  /// Gets eligibility text for display
  static String? getEligibilityText(ComboEntity combo) {
    final timeWindows = combo.availability.timeWindows;
    if (timeWindows.isNotEmpty) {
      return timeWindows.first.name; // e.g., "Lunch"
    }
    return null;
  }

  // Computed properties for availability
  static bool isLimitedTime(ComboAvailabilityEntity availability) {
    return availability.startDate != null || availability.endDate != null;
  }

  static bool isWeekendSpecial(ComboAvailabilityEntity availability) {
    return availability.daysOfWeek.length == 2 &&
        availability.daysOfWeek.contains(DayOfWeek.saturday) &&
        availability.daysOfWeek.contains(DayOfWeek.sunday);
  }

  static bool isWeekdaysOnly(ComboAvailabilityEntity availability) {
    return availability.daysOfWeek.length == 5 &&
        !availability.daysOfWeek.contains(DayOfWeek.saturday) &&
        !availability.daysOfWeek.contains(DayOfWeek.sunday);
  }

  static bool hasDayRestrictions(ComboAvailabilityEntity availability) {
    return availability.daysOfWeek.length < 7;
  }

  static bool hasDateRestrictions(ComboAvailabilityEntity availability) {
    return availability.startDate != null || availability.endDate != null;
  }

  // Computed properties for limits
  static bool hasOrderLimit(ComboLimitsEntity limits) {
    return limits.maxPerOrder != null;
  }

  static bool hasDailyLimit(ComboLimitsEntity limits) {
    return limits.maxPerDay != null;
  }

  static bool hasCustomerLimit(ComboLimitsEntity limits) {
    return limits.maxPerCustomer != null;
  }

  static bool hasDeviceLimit(ComboLimitsEntity limits) {
    return limits.maxPerDevice != null;
  }

  // Factory methods for creating pricing entities
  static ComboPricingEntity createFixedPricing({
    required double fixedPrice,
    required double totalIfSeparate,
  }) {
    final savings = (totalIfSeparate - fixedPrice).clamp(0.0, double.infinity);
    return ComboPricingEntity(
      mode: PricingMode.fixed,
      fixedPrice: fixedPrice,
      totalIfSeparate: totalIfSeparate,
      finalPrice: fixedPrice,
      savings: savings,
    );
  }

  static ComboPricingEntity createPercentagePricing({
    required double percentOff,
    required double totalIfSeparate,
  }) {
    final discount = totalIfSeparate * (percentOff / 100);
    final finalPrice = (totalIfSeparate - discount).clamp(0.0, double.infinity);
    return ComboPricingEntity(
      mode: PricingMode.percentage,
      percentOff: percentOff,
      totalIfSeparate: totalIfSeparate,
      finalPrice: finalPrice,
      savings: discount,
    );
  }

  static ComboPricingEntity createAmountPricing({
    required double amountOff,
    required double totalIfSeparate,
  }) {
    final discount = amountOff.clamp(0.0, totalIfSeparate);
    final finalPrice = totalIfSeparate - discount;
    return ComboPricingEntity(
      mode: PricingMode.amount,
      amountOff: amountOff,
      totalIfSeparate: totalIfSeparate,
      finalPrice: finalPrice,
      savings: discount,
    );
  }

  static ComboPricingEntity createMixAndMatchPricing({
    String? categoryId,
    String? categoryName,
    required int quantity,
    double? fixedPrice,
    double? percentOff,
    required double totalIfSeparate,
  }) {
    double finalPrice;
    double savings;

    if (fixedPrice != null) {
      // "2 for $10" style
      finalPrice = fixedPrice;
      savings = (totalIfSeparate - fixedPrice).clamp(0.0, double.infinity);
    } else if (percentOff != null) {
      // "Save 15% on any 2" style
      final discount = totalIfSeparate * (percentOff / 100);
      finalPrice = (totalIfSeparate - discount).clamp(0.0, double.infinity);
      savings = discount;
    } else {
      // Default to no discount
      finalPrice = totalIfSeparate;
      savings = 0.0;
    }

    return ComboPricingEntity(
      mode: PricingMode.mixAndMatch,
      mixCategoryId: categoryId,
      mixCategoryName: categoryName,
      mixQuantity: quantity,
      mixPrice: fixedPrice,
      mixPercentOff: percentOff,
      totalIfSeparate: totalIfSeparate,
      finalPrice: finalPrice,
      savings: savings,
    );
  }

  // Factory methods for creating limits entities
  static ComboLimitsEntity createNoLimits() {
    return const ComboLimitsEntity();
  }

  static ComboLimitsEntity createOnePerOrder() {
    return const ComboLimitsEntity(maxPerOrder: 1);
  }

  static ComboLimitsEntity createLimitedDaily({
    required int maxPerDay,
    int? maxPerOrder,
  }) {
    return ComboLimitsEntity(maxPerDay: maxPerDay, maxPerOrder: maxPerOrder);
  }

  static ComboLimitsEntity createCustomerLimit({
    required int maxPerCustomer,
    required Duration period,
    int? maxPerOrder,
  }) {
    return ComboLimitsEntity(
      maxPerCustomer: maxPerCustomer,
      customerLimitPeriod: period,
      maxPerOrder: maxPerOrder,
    );
  }

  static ComboLimitsEntity createNoStacking() {
    return const ComboLimitsEntity(
      allowStackingWithOtherPromos: false,
      allowStackingWithItemDiscounts: false,
    );
  }

  static ComboLimitsEntity createAutoApply({
    int? maxPerOrder,
    bool allowStacking = false,
  }) {
    return ComboLimitsEntity(
      maxPerOrder: maxPerOrder,
      autoApplyOnEligibility: true,
      allowStackingWithOtherPromos: allowStacking,
      allowStackingWithItemDiscounts: allowStacking,
    );
  }

  /// Calculates if a combo is currently available based on availability rules
  static bool isCurrentlyAvailable(ComboAvailabilityEntity availability) {
    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final currentDay = _dayOfWeekFromDateTime(now);

    // Check date restrictions
    if (availability.startDate != null &&
        now.isBefore(availability.startDate!)) {
      return false;
    }
    if (availability.endDate != null && now.isAfter(availability.endDate!)) {
      return false;
    }

    // Check day restrictions
    if (!availability.daysOfWeek.contains(currentDay)) return false;

    // Check time restrictions
    if (availability.timeWindows.isNotEmpty) {
      return availability.timeWindows.any(
        (window) => window.isActiveAt(currentTime),
      );
    }

    return true;
  }

  /// Gets preview text for availability display
  static String getPreviewText(ComboAvailabilityEntity availability) {
    final parts = <String>[];

    // Visibility
    if (availability.posSystem && availability.onlineMenu) {
      parts.add('POS & Online');
    } else if (availability.posSystem) {
      parts.add('POS Only');
    } else if (availability.onlineMenu) {
      parts.add('Online Only');
    }

    // Time windows
    if (availability.timeWindows.isNotEmpty) {
      parts.add(availability.timeWindows.map((w) => w.name).join(', '));
    }

    // Days
    if (availability.isWeekendSpecial) {
      parts.add('Weekends');
    } else if (availability.isWeekdaysOnly) {
      parts.add('Weekdays');
    } else if (availability.hasDayRestrictions) {
      parts.add('${availability.daysOfWeek.length} days');
    }

    // Date range
    if (availability.hasDateRestrictions) {
      if (availability.startDate != null && availability.endDate != null) {
        parts.add(
          '${_formatDate(availability.startDate!)}-${_formatDate(availability.endDate!)}',
        );
      } else if (availability.startDate != null) {
        parts.add('From ${_formatDate(availability.startDate!)}');
      } else if (availability.endDate != null) {
        parts.add('Until ${_formatDate(availability.endDate!)}');
      }
    }

    return parts.join(' · ');
  }

  /// Gets limits summary for display
  static String getLimitsSummary(ComboLimitsEntity limits) {
    final parts = <String>[];

    if (limits.hasOrderLimit) {
      parts.add('Max ${limits.maxPerOrder} per order');
    }

    if (limits.hasDailyLimit) {
      parts.add('Max ${limits.maxPerDay} per day');
    }

    if (limits.hasCustomerLimit && limits.customerLimitPeriod != null) {
      final periodName = _formatDuration(limits.customerLimitPeriod!);
      parts.add('Max ${limits.maxPerCustomer} per customer per $periodName');
    }

    if (limits.hasDeviceLimit && limits.deviceLimitPeriod != null) {
      final periodName = _formatDuration(limits.deviceLimitPeriod!);
      parts.add('Max ${limits.maxPerDevice} per device per $periodName');
    }

    if (!limits.allowStackingWithOtherPromos) {
      parts.add('Cannot combine with other promos');
    }

    if (limits.excludeComboIds.isNotEmpty) {
      parts.add('Excludes ${limits.excludeComboIds.length} other combo(s)');
    }

    if (limits.autoApplyOnEligibility) {
      parts.add('Auto-applies when eligible');
    }

    return parts.join(', ');
  }

  /// Gets behavior description for display
  static String getBehaviorDescription(ComboLimitsEntity limits) {
    if (limits.autoApplyOnEligibility) {
      return 'Automatically applied when customer is eligible';
    } else if (limits.showAsSuggestion) {
      return 'Shown as suggestion to customer';
    } else {
      return 'Must be manually selected';
    }
  }

  // Private helper methods

  static bool _isPopular(ComboEntity combo) {
    // This would typically check sales data or analytics
    return false;
  }

  static bool _isBestValue(ComboEntity combo) {
    return calculateSavings(combo) > 5.0; // Example threshold
  }

  static double _calculateTotalIfSeparate(List<ComboSlotEntity> slots) {
    double total = 0.0;
    for (final slot in slots) {
      if (slot.defaultIncluded) {
        total += slot.defaultPrice;
      }
    }
    return total;
  }

  static double _calculateMixAndMatchSavings(ComboEntity combo) {
    // Mix and match savings calculation logic would go here
    return 0.0;
  }

  static DayOfWeek _dayOfWeekFromDateTime(DateTime date) {
    // DateTime.weekday: Monday = 1, Sunday = 7
    switch (date.weekday) {
      case 1:
        return DayOfWeek.monday;
      case 2:
        return DayOfWeek.tuesday;
      case 3:
        return DayOfWeek.wednesday;
      case 4:
        return DayOfWeek.thursday;
      case 5:
        return DayOfWeek.friday;
      case 6:
        return DayOfWeek.saturday;
      case 7:
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.monday;
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  static String _formatDuration(Duration duration) {
    if (duration.inDays >= 7 && duration.inDays % 7 == 0) {
      final weeks = duration.inDays ~/ 7;
      return weeks == 1 ? 'week' : '$weeks weeks';
    } else if (duration.inDays >= 1) {
      return duration.inDays == 1 ? 'day' : '${duration.inDays} days';
    } else if (duration.inHours >= 1) {
      return duration.inHours == 1 ? 'hour' : '${duration.inHours} hours';
    } else {
      return '${duration.inMinutes} minutes';
    }
  }
}

/// Extensions on entities to provide calculated properties
extension ComboCalculations on ComboEntity {
  bool get isActive => ComboCalculator.isActive(this);
  bool get isVisible => ComboCalculator.isVisible(this);
  List<String> get ribbons => ComboCalculator.getRibbons(this);
  String? get savingsText => ComboCalculator.getSavingsText(this);
  double get computedSavings => ComboCalculator.calculateSavings(this);
  double get finalPrice => ComboCalculator.calculateFinalPrice(this);
  List<String> get componentSummary =>
      ComboCalculator.getComponentSummary(this);
  String? get eligibilityText => ComboCalculator.getEligibilityText(this);
}

extension AvailabilityCalculations on ComboAvailabilityEntity {
  bool get isCurrentlyAvailable => ComboCalculator.isCurrentlyAvailable(this);
  String get previewText => ComboCalculator.getPreviewText(this);
  bool get isLimitedTime => ComboCalculator.isLimitedTime(this);
  bool get isWeekendSpecial => ComboCalculator.isWeekendSpecial(this);
  bool get isWeekdaysOnly => ComboCalculator.isWeekdaysOnly(this);
  bool get hasDayRestrictions => ComboCalculator.hasDayRestrictions(this);
  bool get hasDateRestrictions => ComboCalculator.hasDateRestrictions(this);
}

extension LimitsCalculations on ComboLimitsEntity {
  String get limitsSummary => ComboCalculator.getLimitsSummary(this);
  String get behaviorDescription =>
      ComboCalculator.getBehaviorDescription(this);
  bool get hasOrderLimit => ComboCalculator.hasOrderLimit(this);
  bool get hasDailyLimit => ComboCalculator.hasDailyLimit(this);
  bool get hasCustomerLimit => ComboCalculator.hasCustomerLimit(this);
  bool get hasDeviceLimit => ComboCalculator.hasDeviceLimit(this);
}
