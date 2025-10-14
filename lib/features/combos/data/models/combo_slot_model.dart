import 'package:equatable/equatable.dart';
import '../../domain/entities/combo_slot_entity.dart';

/// Model class for ComboSlot JSON serialization/deserialization
class ComboSlotModel extends Equatable {
  final String id;
  final String name;
  final SlotSourceType sourceType;
  final List<String> specificItemIds;
  final List<String> specificItemNames;
  final String? categoryId;
  final String? categoryName;
  final bool required;
  final bool allowQuantityChange;
  final int maxQuantity;
  final bool defaultIncluded;
  final List<String> allowedSizeIds;
  final String? defaultSizeId;
  final String? defaultSizeName;
  final Map<String, bool> modifierGroupAllowed;
  final Map<String, List<String>> modifierExclusions;
  final double defaultPrice;
  final double minPrice;
  final double maxPrice;
  final int sortOrder;

  const ComboSlotModel({
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

  /// Convert JSON to ComboSlotModel
  factory ComboSlotModel.fromJson(Map<String, dynamic> json) {
    return ComboSlotModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sourceType: SlotSourceType.values.firstWhere(
        (e) => e.toString().split('.').last == json['sourceType'],
      ),
      specificItemIds:
          (json['specificItemIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      specificItemNames:
          (json['specificItemNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      required: json['required'] as bool? ?? false,
      allowQuantityChange: json['allowQuantityChange'] as bool? ?? false,
      maxQuantity: json['maxQuantity'] as int? ?? 1,
      defaultIncluded: json['defaultIncluded'] as bool? ?? false,
      allowedSizeIds:
          (json['allowedSizeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      defaultSizeId: json['defaultSizeId'] as String?,
      defaultSizeName: json['defaultSizeName'] as String?,
      modifierGroupAllowed:
          (json['modifierGroupAllowed'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as bool),
          ) ??
          {},
      modifierExclusions:
          (json['modifierExclusions'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              (value as List<dynamic>).map((e) => e as String).toList(),
            ),
          ) ??
          {},
      defaultPrice: (json['defaultPrice'] as num?)?.toDouble() ?? 0.0,
      minPrice: (json['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (json['maxPrice'] as num?)?.toDouble() ?? 0.0,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  /// Convert ComboSlotModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sourceType': sourceType.toString().split('.').last,
      'specificItemIds': specificItemIds,
      'specificItemNames': specificItemNames,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'required': required,
      'allowQuantityChange': allowQuantityChange,
      'maxQuantity': maxQuantity,
      'defaultIncluded': defaultIncluded,
      'allowedSizeIds': allowedSizeIds,
      'defaultSizeId': defaultSizeId,
      'defaultSizeName': defaultSizeName,
      'modifierGroupAllowed': modifierGroupAllowed,
      'modifierExclusions': modifierExclusions,
      'defaultPrice': defaultPrice,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'sortOrder': sortOrder,
    };
  }

  /// Convert ComboSlotModel to ComboSlotEntity
  ComboSlotEntity toEntity() {
    return ComboSlotEntity(
      id: id,
      name: name,
      sourceType: sourceType,
      specificItemIds: specificItemIds,
      specificItemNames: specificItemNames,
      categoryId: categoryId,
      categoryName: categoryName,
      required: required,
      allowQuantityChange: allowQuantityChange,
      maxQuantity: maxQuantity,
      defaultIncluded: defaultIncluded,
      allowedSizeIds: allowedSizeIds,
      defaultSizeId: defaultSizeId,
      defaultSizeName: defaultSizeName,
      modifierGroupAllowed: modifierGroupAllowed,
      modifierExclusions: modifierExclusions,
      defaultPrice: defaultPrice,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortOrder: sortOrder,
    );
  }

  /// Create ComboSlotModel from ComboSlotEntity
  factory ComboSlotModel.fromEntity(ComboSlotEntity entity) {
    return ComboSlotModel(
      id: entity.id,
      name: entity.name,
      sourceType: entity.sourceType,
      specificItemIds: entity.specificItemIds,
      specificItemNames: entity.specificItemNames,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      required: entity.required,
      allowQuantityChange: entity.allowQuantityChange,
      maxQuantity: entity.maxQuantity,
      defaultIncluded: entity.defaultIncluded,
      allowedSizeIds: entity.allowedSizeIds,
      defaultSizeId: entity.defaultSizeId,
      defaultSizeName: entity.defaultSizeName,
      modifierGroupAllowed: entity.modifierGroupAllowed,
      modifierExclusions: entity.modifierExclusions,
      defaultPrice: entity.defaultPrice,
      minPrice: entity.minPrice,
      maxPrice: entity.maxPrice,
      sortOrder: entity.sortOrder,
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
