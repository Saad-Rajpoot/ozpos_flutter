import 'package:equatable/equatable.dart';

enum SlotSourceType { specific, category }

class ComboSlotEntity extends Equatable {
  final String id;
  final String name; // Internal name for this slot (e.g., "Main Item", "Side", "Drink")
  final SlotSourceType sourceType;
  
  // For specific items
  final List<String> specificItemIds;
  final List<String> specificItemNames; // Cached for display
  
  // For category-based slots
  final String? categoryId;
  final String? categoryName; // Cached for display
  
  final bool required;
  final bool allowQuantityChange;
  final int maxQuantity;
  final bool defaultIncluded;
  
  // Size controls
  final List<String> allowedSizeIds;
  final String? defaultSizeId;
  final String? defaultSizeName; // Cached for display
  
  // Modifier controls - per modifier group
  final Map<String, bool> modifierGroupAllowed; // groupId -> allowed
  final Map<String, List<String>> modifierExclusions; // groupId -> [excludedOptionIds]
  
  // Cached pricing info
  final double defaultPrice; // Base price with default size/modifiers
  final double minPrice;
  final double maxPrice;
  
  // Display order
  final int sortOrder;

  const ComboSlotEntity({
    required this.id,
    required this.name,
    required this.sourceType,
    this.specificItemIds = const [],
    this.specificItemNames = const [],
    this.categoryId,
    this.categoryName,
    this.required = false,
    this.allowQuantityChange = false,
    this.maxQuantity = 1,
    this.defaultIncluded = false,
    this.allowedSizeIds = const [],
    this.defaultSizeId,
    this.defaultSizeName,
    this.modifierGroupAllowed = const {},
    this.modifierExclusions = const {},
    this.defaultPrice = 0.0,
    this.minPrice = 0.0,
    this.maxPrice = 0.0,
    this.sortOrder = 0,
  });

  // Computed properties
  
  bool get isSpecific => sourceType == SlotSourceType.specific;
  bool get isCategory => sourceType == SlotSourceType.category;
  
  bool get hasMultipleOptions => 
    (isSpecific && specificItemIds.length > 1) || 
    (isCategory && categoryId != null);
  
  String get displayName {
    if (isSpecific && specificItemNames.length == 1) {
      return specificItemNames.first;
    } else if (isCategory && categoryName != null) {
      return 'Any $categoryName';
    } else {
      return name;
    }
  }
  
  String get summaryText {
    final parts = <String>[];
    
    // Size info
    if (allowedSizeIds.isNotEmpty) {
      if (allowedSizeIds.length == 1) {
        parts.add('Size: ${defaultSizeName ?? 'Fixed'}');
      } else {
        parts.add('Sizes: ${allowedSizeIds.length} options');
      }
    }
    
    // Modifier info
    final excludedGroups = modifierExclusions.keys.where((key) => 
      modifierExclusions[key]?.isNotEmpty ?? false).length;
    if (excludedGroups > 0) {
      parts.add('$excludedGroups modifier(s) excluded');
    }
    
    // Quantity info
    if (allowQuantityChange && maxQuantity > 1) {
      parts.add('Max qty: $maxQuantity');
    }
    
    return parts.join(' · ');
  }
  
  bool get hasRestrictions => 
    allowedSizeIds.isNotEmpty || 
    modifierExclusions.isNotEmpty ||
    !allowQuantityChange ||
    maxQuantity > 1;

  List<String> get validationErrors {
    final List<String> errors = [];
    
    // Name validation
    if (name.trim().isEmpty) {
      errors.add('Slot name is required');
    }
    
    // Source validation
    if (isSpecific && specificItemIds.isEmpty) {
      errors.add('At least one specific item must be selected');
    }
    
    if (isCategory && (categoryId == null || categoryId!.isEmpty)) {
      errors.add('Category must be selected');
    }
    
    // Quantity validation
    if (maxQuantity < 1) {
      errors.add('Max quantity must be at least 1');
    }
    
    // Size validation - ensure default size is in allowed sizes
    if (defaultSizeId != null && !allowedSizeIds.contains(defaultSizeId)) {
      errors.add('Default size must be in allowed sizes');
    }
    
    return errors;
  }

  ComboSlotEntity copyWith({
    String? id,
    String? name,
    SlotSourceType? sourceType,
    List<String>? specificItemIds,
    List<String>? specificItemNames,
    String? categoryId,
    String? categoryName,
    bool? required,
    bool? allowQuantityChange,
    int? maxQuantity,
    bool? defaultIncluded,
    List<String>? allowedSizeIds,
    String? defaultSizeId,
    String? defaultSizeName,
    Map<String, bool>? modifierGroupAllowed,
    Map<String, List<String>>? modifierExclusions,
    double? defaultPrice,
    double? minPrice,
    double? maxPrice,
    int? sortOrder,
  }) {
    return ComboSlotEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      sourceType: sourceType ?? this.sourceType,
      specificItemIds: specificItemIds ?? this.specificItemIds,
      specificItemNames: specificItemNames ?? this.specificItemNames,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      required: required ?? this.required,
      allowQuantityChange: allowQuantityChange ?? this.allowQuantityChange,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      defaultIncluded: defaultIncluded ?? this.defaultIncluded,
      allowedSizeIds: allowedSizeIds ?? this.allowedSizeIds,
      defaultSizeId: defaultSizeId ?? this.defaultSizeId,
      defaultSizeName: defaultSizeName ?? this.defaultSizeName,
      modifierGroupAllowed: modifierGroupAllowed ?? this.modifierGroupAllowed,
      modifierExclusions: modifierExclusions ?? this.modifierExclusions,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        sourceType,
        specificItemIds,
        specificItemNames,
        categoryId,
        categoryName,
        required,
        allowQuantityChange,
        maxQuantity,
        defaultIncluded,
        allowedSizeIds,
        defaultSizeId,
        defaultSizeName,
        modifierGroupAllowed,
        modifierExclusions,
        defaultPrice,
        minPrice,
        maxPrice,
        sortOrder,
      ];
}