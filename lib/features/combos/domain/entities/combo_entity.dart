import 'package:equatable/equatable.dart';
import 'combo_slot_entity.dart';
import 'combo_pricing_entity.dart';
import 'combo_availability_entity.dart';
import 'combo_limits_entity.dart';

enum ComboStatus { active, hidden, draft }

class ComboEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? image;
  final String? categoryTag;
  final int? pointsReward;
  final ComboStatus status;
  final List<ComboSlotEntity> slots;
  final ComboPricingEntity pricing;
  final ComboAvailabilityEntity availability;
  final ComboLimitsEntity limits;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool hasUnsavedChanges;

  const ComboEntity({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    this.categoryTag,
    this.pointsReward,
    required this.status,
    required this.slots,
    required this.pricing,
    required this.availability,
    required this.limits,
    required this.createdAt,
    required this.updatedAt,
    this.hasUnsavedChanges = false,
  });

  /// Computed properties for UI display
  
  bool get isActive => status == ComboStatus.active;
  
  bool get isVisible => isActive && availability.isCurrentlyAvailable;
  
  List<String> get ribbons {
    final List<String> ribbons = [];
    
    // Add time-based ribbons
    if (availability.isLimitedTime) ribbons.add('Limited Time');
    if (availability.isWeekendSpecial) ribbons.add('Weekend Special');
    
    // Add popularity ribbon (would be computed from sales data)
    if (_isPopular) ribbons.add('Popular');
    
    // Add best value ribbon
    if (_isBestValue) ribbons.add('Best Value');
    
    return ribbons;
  }
  
  String? get savingsText {
    final savings = computedSavings;
    if (savings > 0) {
      return 'SAVE \$${savings.toStringAsFixed(2)}';
    }
    return null;
  }
  
  double get computedSavings {
    // Calculate savings based on pricing mode
    switch (pricing.mode) {
      case PricingMode.fixed:
        final totalSeparate = _calculateTotalIfSeparate();
        return totalSeparate > pricing.fixedPrice! ? totalSeparate - pricing.fixedPrice! : 0.0;
      
      case PricingMode.percentage:
        final totalSeparate = _calculateTotalIfSeparate();
        return totalSeparate * (pricing.percentOff! / 100);
      
      case PricingMode.amount:
        final totalSeparate = _calculateTotalIfSeparate();
        return totalSeparate > pricing.amountOff! ? pricing.amountOff! : totalSeparate;
      
      case PricingMode.mixAndMatch:
        return _calculateMixAndMatchSavings();
    }
  }
  
  double get finalPrice {
    final totalSeparate = _calculateTotalIfSeparate();
    final savings = computedSavings;
    return (totalSeparate - savings).clamp(0.0, double.infinity);
  }
  
  List<String> get componentSummary {
    return slots.where((slot) => slot.defaultIncluded).map((slot) {
      if (slot.sourceType == SlotSourceType.specific) {
        return slot.specificItemNames.join(' or ');
      } else {
        return 'Any ${slot.categoryName}';
      }
    }).toList();
  }
  
  String? get eligibilityText {
    final timeWindows = availability.timeWindows;
    if (timeWindows.isNotEmpty) {
      return timeWindows.first.name; // e.g., "Lunch"
    }
    return null;
  }
  
  bool get hasValidationErrors => validationErrors.isNotEmpty;
  
  List<String> get validationErrors {
    final List<String> errors = [];
    
    // Name validation
    if (name.trim().isEmpty) {
      errors.add('Combo name is required');
    }
    
    // Slots validation
    if (slots.isEmpty) {
      errors.add('At least one item slot is required');
    }
    
    final requiredSlots = slots.where((s) => s.required).length;
    if (requiredSlots == 0) {
      errors.add('At least one slot must be required');
    }
    
    // Pricing validation
    switch (pricing.mode) {
      case PricingMode.fixed:
        if (pricing.fixedPrice == null || pricing.fixedPrice! <= 0) {
          errors.add('Fixed price must be greater than 0');
        }
        break;
      case PricingMode.percentage:
        if (pricing.percentOff == null || pricing.percentOff! <= 0 || pricing.percentOff! >= 100) {
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
    
    // Availability validation
    if (!availability.posSystem && !availability.onlineMenu) {
      errors.add('Combo must be visible on POS or Online');
    }
    
    return errors;
  }

  // Private helper methods
  bool get _isPopular {
    // TODO: Implement based on sales data
    return false;
  }
  
  bool get _isBestValue {
    // TODO: Implement based on savings percentage
    return computedSavings > 5.0; // Example threshold
  }
  
  double _calculateTotalIfSeparate() {
    double total = 0.0;
    for (final slot in slots) {
      if (slot.defaultIncluded) {
        total += slot.defaultPrice;
      }
    }
    return total;
  }
  
  double _calculateMixAndMatchSavings() {
    // TODO: Implement mix-and-match savings calculation
    return 0.0;
  }

  ComboEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? categoryTag,
    int? pointsReward,
    ComboStatus? status,
    List<ComboSlotEntity>? slots,
    ComboPricingEntity? pricing,
    ComboAvailabilityEntity? availability,
    ComboLimitsEntity? limits,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasUnsavedChanges,
  }) {
    return ComboEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      categoryTag: categoryTag ?? this.categoryTag,
      pointsReward: pointsReward ?? this.pointsReward,
      status: status ?? this.status,
      slots: slots ?? this.slots,
      pricing: pricing ?? this.pricing,
      availability: availability ?? this.availability,
      limits: limits ?? this.limits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        image,
        categoryTag,
        pointsReward,
        status,
        slots,
        pricing,
        availability,
        limits,
        createdAt,
        updatedAt,
        hasUnsavedChanges,
      ];
}