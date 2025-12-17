import 'combo_entity.dart';
import 'combo_pricing_entity.dart';
import 'combo_availability_entity.dart';
import 'combo_limits_entity.dart';
import 'combo_slot_entity.dart';

/// Business logic class for validating combo entities
class ComboValidator {
  /// Validates a combo entity and returns a list of validation errors
  static List<String> validateCombo(ComboEntity combo) {
    final List<String> errors = [];

    // Name validation
    if (combo.name.trim().isEmpty) {
      errors.add('Combo name is required');
    }

    if (combo.description.trim().isEmpty) {
      errors.add('Combo description is required');
    }

    // Slots validation
    if (combo.slots.isEmpty) {
      errors.add('At least one item slot is required');
    }

    for (final slot in combo.slots) {
      errors.addAll(validateSlot(slot));
    }

    final requiredSlots = combo.slots.where((s) => s.required).length;
    if (requiredSlots == 0) {
      errors.add('At least one slot must be required');
    }

    // Pricing validation
    errors.addAll(_validatePricing(combo.pricing));

    // Availability validation
    errors.addAll(_validateAvailability(combo.availability));

    return errors;
  }

  /// Validates a combo pricing entity and returns a list of validation errors
  static List<String> _validatePricing(ComboPricingEntity pricing) {
    final List<String> errors = [];

    if (pricing.totalIfSeparate <= 0) {
      errors.add('Combo must have a valid base price');
    }

    switch (pricing.mode) {
      case PricingMode.fixed:
        if (pricing.fixedPrice == null || pricing.fixedPrice! <= 0) {
          errors.add('Fixed price must be greater than 0');
        }
        break;
      case PricingMode.percentage:
        if (pricing.percentOff == null ||
            pricing.percentOff! <= 0 ||
            pricing.percentOff! >= 100) {
          errors.add('Percentage off must be between 1-99%');
        }
        break;
      case PricingMode.amount:
        if (pricing.amountOff == null || pricing.amountOff! <= 0) {
          errors.add('Amount off must be greater than 0');
        }
        break;
      case PricingMode.mixAndMatch:
        if (pricing.mixQuantity == null || pricing.mixQuantity! < 2) {
          errors.add('Mix quantity must be at least 2');
        }
        if (pricing.mixPrice == null || pricing.mixPrice! <= 0) {
          errors.add('Mix price must be greater than 0');
        }
        break;
    }

    return errors;
  }

  /// Validates a combo availability entity and returns a list of validation errors
  static List<String> _validateAvailability(
    ComboAvailabilityEntity availability,
  ) {
    final List<String> errors = [];

    if (!availability.posSystem && !availability.onlineMenu) {
      errors.add('Combo must be visible on POS or Online');
    }

    if (availability.orderTypes.isEmpty) {
      errors.add('At least one order type must be selected');
    }

    if (availability.daysOfWeek.isEmpty) {
      errors.add('At least one day must be selected');
    }

    if (availability.startDate != null &&
        availability.endDate != null &&
        availability.startDate!.isAfter(availability.endDate!)) {
      errors.add('Start date must be before end date');
    }

    for (final window in availability.timeWindows) {
      if (window.startTime.hour == window.endTime.hour &&
          window.startTime.minute == window.endTime.minute) {
        errors.add('Time window "${window.name}" has no duration');
      }
    }

    return errors;
  }

  /// Validates a combo limits entity and returns a list of validation errors
  static List<String> validateLimits(ComboLimitsEntity limits) {
    final List<String> errors = [];

    // Validate positive limits
    if (limits.maxPerOrder != null && limits.maxPerOrder! <= 0) {
      errors.add('Max per order must be greater than 0');
    }

    if (limits.maxPerDay != null && limits.maxPerDay! <= 0) {
      errors.add('Max per day must be greater than 0');
    }

    if (limits.maxPerCustomer != null && limits.maxPerCustomer! <= 0) {
      errors.add('Max per customer must be greater than 0');
    }

    if (limits.maxPerDevice != null && limits.maxPerDevice! <= 0) {
      errors.add('Max per device must be greater than 0');
    }

    // Validate periods exist when needed
    if (limits.maxPerCustomer != null && limits.customerLimitPeriod == null) {
      errors.add(
        'Customer limit period is required when max per customer is set',
      );
    }

    if (limits.maxPerDevice != null && limits.deviceLimitPeriod == null) {
      errors.add('Device limit period is required when max per device is set');
    }

    // Logical validations
    if (limits.maxPerOrder != null &&
        limits.maxPerDay != null &&
        limits.maxPerOrder! > limits.maxPerDay!) {
      errors.add('Max per order cannot exceed max per day');
    }

    // Branch restrictions validation
    final commonBranches = limits.allowedBranchIds.toSet().intersection(
          limits.excludedBranchIds.toSet(),
        );
    if (commonBranches.isNotEmpty) {
      errors.add('Branches cannot be both allowed and excluded');
    }

    return errors;
  }

  /// Validates a combo slot entity and returns a list of validation errors
  static List<String> validateSlot(ComboSlotEntity slot) {
    final List<String> errors = [];

    if (slot.name.trim().isEmpty) {
      errors.add('Slot name is required');
    }

    if (slot.sourceType == SlotSourceType.specific &&
        slot.specificItemIds.isEmpty) {
      errors.add('At least one specific item must be selected');
    }

    if (slot.sourceType == SlotSourceType.category && slot.categoryId == null) {
      errors.add('Category must be selected');
    }

    if (slot.defaultPrice < 0) {
      errors.add('Default price cannot be negative');
    }

    return errors;
  }
}

/// Extension on ComboEntity to provide validation errors
extension ComboValidation on ComboEntity {
  /// Gets validation errors for this combo
  List<String> get validationErrors => ComboValidator.validateCombo(this);

  /// Checks if this combo has validation errors
  bool get hasValidationErrors => validationErrors.isNotEmpty;
}
