import 'package:equatable/equatable.dart';

class ComboLimitsEntity extends Equatable {
  // Per-order limits
  final int? maxPerOrder;

  // Daily limits (store-wide)
  final int? maxPerDay;

  // Customer limits (requires identification)
  final int? maxPerCustomer;
  final Duration? customerLimitPeriod; // e.g., per day, per week, per month

  // Device/browser limits (for online orders)
  final int? maxPerDevice;
  final Duration? deviceLimitPeriod;

  // Stacking rules
  final bool allowStackingWithOtherPromos;
  final bool allowStackingWithItemDiscounts;
  final List<String> excludeComboIds; // Cannot be combined with these specific combos

  // Auto-apply behavior
  final bool autoApplyOnEligibility;
  final bool showAsSuggestion;

  // Branch/area scope (for multi-location)
  final List<String> allowedBranchIds;
  final List<String> excludedBranchIds;

  const ComboLimitsEntity({
    this.maxPerOrder,
    this.maxPerDay,
    this.maxPerCustomer,
    this.customerLimitPeriod,
    this.maxPerDevice,
    this.deviceLimitPeriod,
    this.allowStackingWithOtherPromos = false,
    this.allowStackingWithItemDiscounts = false,
    this.excludeComboIds = const [],
    this.autoApplyOnEligibility = false,
    this.showAsSuggestion = true,
    this.allowedBranchIds = const [],
    this.excludedBranchIds = const [],
  });

  // Factory constructors for common limit patterns

  static ComboLimitsEntity noLimits() {
    return const ComboLimitsEntity();
  }

  static ComboLimitsEntity onePerOrder() {
    return const ComboLimitsEntity(
      maxPerOrder: 1,
    );
  }

  static ComboLimitsEntity limitedDaily({
    required int maxPerDay,
    int? maxPerOrder,
  }) {
    return ComboLimitsEntity(
      maxPerDay: maxPerDay,
      maxPerOrder: maxPerOrder,
    );
  }

  static ComboLimitsEntity customerLimit({
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

  static ComboLimitsEntity noStacking() {
    return const ComboLimitsEntity(
      allowStackingWithOtherPromos: false,
      allowStackingWithItemDiscounts: false,
    );
  }

  static ComboLimitsEntity autoApply({
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

  // Computed properties

  bool get hasOrderLimit => maxPerOrder != null;
  bool get hasDailyLimit => maxPerDay != null;
  bool get hasCustomerLimit => maxPerCustomer != null;
  bool get hasDeviceLimit => maxPerDevice != null;

  bool get hasAnyLimit => 
    hasOrderLimit || hasDailyLimit || hasCustomerLimit || hasDeviceLimit;

  bool get hasStackingRestrictions => 
    !allowStackingWithOtherPromos || 
    !allowStackingWithItemDiscounts || 
    excludeComboIds.isNotEmpty;

  bool get hasBranchRestrictions => 
    allowedBranchIds.isNotEmpty || excludedBranchIds.isNotEmpty;

  String get limitsSummary {
    final parts = <String>[];

    if (hasOrderLimit) {
      parts.add('Max $maxPerOrder per order');
    }

    if (hasDailyLimit) {
      parts.add('Max $maxPerDay per day');
    }

    if (hasCustomerLimit && customerLimitPeriod != null) {
      final periodName = _formatDuration(customerLimitPeriod!);
      parts.add('Max $maxPerCustomer per customer per $periodName');
    }

    if (hasDeviceLimit && deviceLimitPeriod != null) {
      final periodName = _formatDuration(deviceLimitPeriod!);
      parts.add('Max $maxPerDevice per device per $periodName');
    }

    if (!allowStackingWithOtherPromos) {
      parts.add('Cannot combine with other promos');
    }

    if (excludeComboIds.isNotEmpty) {
      parts.add('Excludes ${excludeComboIds.length} other combo(s)');
    }

    if (autoApplyOnEligibility) {
      parts.add('Auto-applies when eligible');
    }

    return parts.join(', ');
  }

  String get behaviorDescription {
    if (autoApplyOnEligibility) {
      return 'Automatically applied when customer is eligible';
    } else if (showAsSuggestion) {
      return 'Shown as suggestion to customer';
    } else {
      return 'Must be manually selected';
    }
  }

  List<String> get validationErrors {
    final List<String> errors = [];

    // Validate positive limits
    if (maxPerOrder != null && maxPerOrder! <= 0) {
      errors.add('Max per order must be greater than 0');
    }

    if (maxPerDay != null && maxPerDay! <= 0) {
      errors.add('Max per day must be greater than 0');
    }

    if (maxPerCustomer != null && maxPerCustomer! <= 0) {
      errors.add('Max per customer must be greater than 0');
    }

    if (maxPerDevice != null && maxPerDevice! <= 0) {
      errors.add('Max per device must be greater than 0');
    }

    // Validate periods exist when needed
    if (maxPerCustomer != null && customerLimitPeriod == null) {
      errors.add('Customer limit period is required when max per customer is set');
    }

    if (maxPerDevice != null && deviceLimitPeriod == null) {
      errors.add('Device limit period is required when max per device is set');
    }

    // Logical validations
    if (maxPerOrder != null && maxPerDay != null && maxPerOrder! > maxPerDay!) {
      errors.add('Max per order cannot exceed max per day');
    }

    // Branch restrictions validation
    final commonBranches = allowedBranchIds.toSet().intersection(excludedBranchIds.toSet());
    if (commonBranches.isNotEmpty) {
      errors.add('Branches cannot be both allowed and excluded');
    }

    return errors;
  }

  // Helper methods

  String _formatDuration(Duration duration) {
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

  /// Check if a combo can be applied given current usage
  bool canApply({
    int currentOrderQuantity = 0,
    int dailyUsage = 0,
    int customerUsage = 0,
    int deviceUsage = 0,
    List<String> currentPromoIds = const [],
    String? branchId,
  }) {
    // Check order limit
    if (hasOrderLimit && currentOrderQuantity >= maxPerOrder!) {
      return false;
    }

    // Check daily limit
    if (hasDailyLimit && dailyUsage >= maxPerDay!) {
      return false;
    }

    // Check customer limit
    if (hasCustomerLimit && customerUsage >= maxPerCustomer!) {
      return false;
    }

    // Check device limit
    if (hasDeviceLimit && deviceUsage >= maxPerDevice!) {
      return false;
    }

    // Check stacking restrictions
    if (!allowStackingWithOtherPromos && currentPromoIds.isNotEmpty) {
      return false;
    }

    // Check excluded combos
    for (final excludedId in excludeComboIds) {
      if (currentPromoIds.contains(excludedId)) {
        return false;
      }
    }

    // Check branch restrictions
    if (branchId != null) {
      if (allowedBranchIds.isNotEmpty && !allowedBranchIds.contains(branchId)) {
        return false;
      }

      if (excludedBranchIds.contains(branchId)) {
        return false;
      }
    }

    return true;
  }

  ComboLimitsEntity copyWith({
    int? maxPerOrder,
    int? maxPerDay,
    int? maxPerCustomer,
    Duration? customerLimitPeriod,
    int? maxPerDevice,
    Duration? deviceLimitPeriod,
    bool? allowStackingWithOtherPromos,
    bool? allowStackingWithItemDiscounts,
    List<String>? excludeComboIds,
    bool? autoApplyOnEligibility,
    bool? showAsSuggestion,
    List<String>? allowedBranchIds,
    List<String>? excludedBranchIds,
  }) {
    return ComboLimitsEntity(
      maxPerOrder: maxPerOrder ?? this.maxPerOrder,
      maxPerDay: maxPerDay ?? this.maxPerDay,
      maxPerCustomer: maxPerCustomer ?? this.maxPerCustomer,
      customerLimitPeriod: customerLimitPeriod ?? this.customerLimitPeriod,
      maxPerDevice: maxPerDevice ?? this.maxPerDevice,
      deviceLimitPeriod: deviceLimitPeriod ?? this.deviceLimitPeriod,
      allowStackingWithOtherPromos: allowStackingWithOtherPromos ?? this.allowStackingWithOtherPromos,
      allowStackingWithItemDiscounts: allowStackingWithItemDiscounts ?? this.allowStackingWithItemDiscounts,
      excludeComboIds: excludeComboIds ?? this.excludeComboIds,
      autoApplyOnEligibility: autoApplyOnEligibility ?? this.autoApplyOnEligibility,
      showAsSuggestion: showAsSuggestion ?? this.showAsSuggestion,
      allowedBranchIds: allowedBranchIds ?? this.allowedBranchIds,
      excludedBranchIds: excludedBranchIds ?? this.excludedBranchIds,
    );
  }

  @override
  List<Object?> get props => [
        maxPerOrder,
        maxPerDay,
        maxPerCustomer,
        customerLimitPeriod,
        maxPerDevice,
        deviceLimitPeriod,
        allowStackingWithOtherPromos,
        allowStackingWithItemDiscounts,
        excludeComboIds,
        autoApplyOnEligibility,
        showAsSuggestion,
        allowedBranchIds,
        excludedBranchIds,
      ];
}