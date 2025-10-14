import 'package:equatable/equatable.dart';
import '../../domain/entities/combo_limits_entity.dart';

/// Model class for ComboLimits JSON serialization/deserialization
class ComboLimitsModel extends Equatable {
  final int? maxPerOrder;
  final int? maxPerDay;
  final int? maxPerCustomer;
  final int? customerLimitPeriodMs; // Duration in milliseconds
  final int? maxPerDevice;
  final int? deviceLimitPeriodMs; // Duration in milliseconds
  final bool allowStackingWithOtherPromos;
  final bool allowStackingWithItemDiscounts;
  final List<String> excludeComboIds;
  final bool autoApplyOnEligibility;
  final bool showAsSuggestion;
  final List<String> allowedBranchIds;
  final List<String> excludedBranchIds;

  const ComboLimitsModel({
    this.maxPerOrder,
    this.maxPerDay,
    this.maxPerCustomer,
    this.customerLimitPeriodMs,
    this.maxPerDevice,
    this.deviceLimitPeriodMs,
    this.allowStackingWithOtherPromos = false,
    this.allowStackingWithItemDiscounts = false,
    this.excludeComboIds = const [],
    this.autoApplyOnEligibility = false,
    this.showAsSuggestion = true,
    this.allowedBranchIds = const [],
    this.excludedBranchIds = const [],
  });

  /// Convert JSON to ComboLimitsModel
  factory ComboLimitsModel.fromJson(Map<String, dynamic> json) {
    return ComboLimitsModel(
      maxPerOrder: json['maxPerOrder'] as int?,
      maxPerDay: json['maxPerDay'] as int?,
      maxPerCustomer: json['maxPerCustomer'] as int?,
      customerLimitPeriodMs: json['customerLimitPeriodMs'] as int?,
      maxPerDevice: json['maxPerDevice'] as int?,
      deviceLimitPeriodMs: json['deviceLimitPeriodMs'] as int?,
      allowStackingWithOtherPromos:
          json['allowStackingWithOtherPromos'] as bool? ?? false,
      allowStackingWithItemDiscounts:
          json['allowStackingWithItemDiscounts'] as bool? ?? false,
      excludeComboIds:
          (json['excludeComboIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      autoApplyOnEligibility: json['autoApplyOnEligibility'] as bool? ?? false,
      showAsSuggestion: json['showAsSuggestion'] as bool? ?? true,
      allowedBranchIds:
          (json['allowedBranchIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      excludedBranchIds:
          (json['excludedBranchIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Convert ComboLimitsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'maxPerOrder': maxPerOrder,
      'maxPerDay': maxPerDay,
      'maxPerCustomer': maxPerCustomer,
      'customerLimitPeriodMs': customerLimitPeriodMs,
      'maxPerDevice': maxPerDevice,
      'deviceLimitPeriodMs': deviceLimitPeriodMs,
      'allowStackingWithOtherPromos': allowStackingWithOtherPromos,
      'allowStackingWithItemDiscounts': allowStackingWithItemDiscounts,
      'excludeComboIds': excludeComboIds,
      'autoApplyOnEligibility': autoApplyOnEligibility,
      'showAsSuggestion': showAsSuggestion,
      'allowedBranchIds': allowedBranchIds,
      'excludedBranchIds': excludedBranchIds,
    };
  }

  /// Convert ComboLimitsModel to ComboLimitsEntity
  ComboLimitsEntity toEntity() {
    return ComboLimitsEntity(
      maxPerOrder: maxPerOrder,
      maxPerDay: maxPerDay,
      maxPerCustomer: maxPerCustomer,
      customerLimitPeriod: customerLimitPeriodMs != null
          ? Duration(milliseconds: customerLimitPeriodMs!)
          : null,
      maxPerDevice: maxPerDevice,
      deviceLimitPeriod: deviceLimitPeriodMs != null
          ? Duration(milliseconds: deviceLimitPeriodMs!)
          : null,
      allowStackingWithOtherPromos: allowStackingWithOtherPromos,
      allowStackingWithItemDiscounts: allowStackingWithItemDiscounts,
      excludeComboIds: excludeComboIds,
      autoApplyOnEligibility: autoApplyOnEligibility,
      showAsSuggestion: showAsSuggestion,
      allowedBranchIds: allowedBranchIds,
      excludedBranchIds: excludedBranchIds,
    );
  }

  /// Create ComboLimitsModel from ComboLimitsEntity
  factory ComboLimitsModel.fromEntity(ComboLimitsEntity entity) {
    return ComboLimitsModel(
      maxPerOrder: entity.maxPerOrder,
      maxPerDay: entity.maxPerDay,
      maxPerCustomer: entity.maxPerCustomer,
      customerLimitPeriodMs: entity.customerLimitPeriod?.inMilliseconds,
      maxPerDevice: entity.maxPerDevice,
      deviceLimitPeriodMs: entity.deviceLimitPeriod?.inMilliseconds,
      allowStackingWithOtherPromos: entity.allowStackingWithOtherPromos,
      allowStackingWithItemDiscounts: entity.allowStackingWithItemDiscounts,
      excludeComboIds: entity.excludeComboIds,
      autoApplyOnEligibility: entity.autoApplyOnEligibility,
      showAsSuggestion: entity.showAsSuggestion,
      allowedBranchIds: entity.allowedBranchIds,
      excludedBranchIds: entity.excludedBranchIds,
    );
  }

  @override
  List<Object?> get props => [
    maxPerOrder,
    maxPerDay,
    maxPerCustomer,
    customerLimitPeriodMs,
    maxPerDevice,
    deviceLimitPeriodMs,
    allowStackingWithOtherPromos,
    allowStackingWithItemDiscounts,
    excludeComboIds,
    autoApplyOnEligibility,
    showAsSuggestion,
    allowedBranchIds,
    excludedBranchIds,
  ];
}
