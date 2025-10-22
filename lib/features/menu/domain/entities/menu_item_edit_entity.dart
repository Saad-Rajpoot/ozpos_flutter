// Domain entities for menu item editing wizard
import 'dart:io';

class MenuItemEditEntity {
  final String? id;
  final String name;
  final String description;
  final String categoryId; // Changed from 'category' to 'categoryId'
  final String? imageUrl; // Changed from 'image' to 'imageUrl'
  final File? imageFile; // For local file uploads
  final List<BadgeEntity> badges; // Changed from badgeIds to full badges
  final bool hasSizes;
  final List<SizeEditEntity> sizes;
  final double basePrice;
  final double? discountedPrice;

  // Channel availability
  final bool dineInAvailable;
  final bool takeawayAvailable;
  final bool deliveryAvailable;

  // Kitchen settings
  final String? kitchenStation;
  final int? prepTimeMinutes;
  final String? specialInstructions;

  // Tax and pricing
  final String taxCategory;
  final String sku;
  final bool stockTracking;

  // Dietary preferences
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final bool isDairyFree;
  final bool isNutFree;
  final bool isHalal;

  // Upsells and related items
  final List<String> upsellItemIds; // Changed from upsellIds
  final List<String> relatedItemIds; // Changed from relatedIds

  const MenuItemEditEntity({
    this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    this.imageUrl,
    this.imageFile,
    required this.badges,
    required this.hasSizes,
    required this.sizes,
    required this.basePrice,
    this.discountedPrice,
    required this.dineInAvailable,
    required this.takeawayAvailable,
    required this.deliveryAvailable,
    this.kitchenStation,
    this.prepTimeMinutes,
    this.specialInstructions,
    required this.taxCategory,
    required this.sku,
    required this.stockTracking,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.isDairyFree = false,
    this.isNutFree = false,
    this.isHalal = false,
    required this.upsellItemIds,
    required this.relatedItemIds,
  });

  MenuItemEditEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? imageUrl,
    File? imageFile,
    List<BadgeEntity>? badges,
    bool? hasSizes,
    List<SizeEditEntity>? sizes,
    double? basePrice,
    double? discountedPrice,
    bool? dineInAvailable,
    bool? takeawayAvailable,
    bool? deliveryAvailable,
    String? kitchenStation,
    int? prepTimeMinutes,
    String? specialInstructions,
    String? taxCategory,
    String? sku,
    bool? stockTracking,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    bool? isDairyFree,
    bool? isNutFree,
    bool? isHalal,
    List<String>? upsellItemIds,
    List<String>? relatedItemIds,
  }) {
    return MenuItemEditEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      imageFile: imageFile ?? this.imageFile,
      badges: badges ?? this.badges,
      hasSizes: hasSizes ?? this.hasSizes,
      sizes: sizes ?? this.sizes,
      basePrice: basePrice ?? this.basePrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      dineInAvailable: dineInAvailable ?? this.dineInAvailable,
      takeawayAvailable: takeawayAvailable ?? this.takeawayAvailable,
      deliveryAvailable: deliveryAvailable ?? this.deliveryAvailable,
      kitchenStation: kitchenStation ?? this.kitchenStation,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      taxCategory: taxCategory ?? this.taxCategory,
      sku: sku ?? this.sku,
      stockTracking: stockTracking ?? this.stockTracking,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      isDairyFree: isDairyFree ?? this.isDairyFree,
      isNutFree: isNutFree ?? this.isNutFree,
      isHalal: isHalal ?? this.isHalal,
      upsellItemIds: upsellItemIds ?? this.upsellItemIds,
      relatedItemIds: relatedItemIds ?? this.relatedItemIds,
    );
  }

  static MenuItemEditEntity empty() {
    return const MenuItemEditEntity(
      name: '',
      description: '',
      categoryId: '',
      badges: [],
      hasSizes: false,
      sizes: [],
      basePrice: 0.0,
      dineInAvailable: true,
      takeawayAvailable: true,
      deliveryAvailable: true,
      taxCategory: 'standard',
      sku: '',
      stockTracking: false,
      isVegetarian: false,
      isVegan: false,
      isGlutenFree: false,
      isDairyFree: false,
      isNutFree: false,
      isHalal: false,
      upsellItemIds: [],
      relatedItemIds: [],
    );
  }

  // Helper to get display image (file or URL)
  String? get displayImagePath {
    if (imageFile != null) return imageFile!.path;
    return imageUrl;
  }

  bool get hasImage =>
      imageFile != null || (imageUrl != null && imageUrl!.isNotEmpty);
}

class SizeEditEntity {
  final String? id; // Unique ID for addon management
  final String name;
  final double dineInPrice;
  final double? takeawayPrice; // null means inherit from dineIn
  final double? deliveryPrice; // null means inherit from dineIn
  final bool isDefault;
  final List<AddOnItemEditEntity> addOnItems;

  const SizeEditEntity({
    this.id,
    required this.name,
    required this.dineInPrice,
    this.takeawayPrice,
    this.deliveryPrice,
    required this.isDefault,
    required this.addOnItems,
  });

  SizeEditEntity copyWith({
    String? id,
    String? name,
    double? dineInPrice,
    double? takeawayPrice,
    double? deliveryPrice,
    bool? isDefault,
    List<AddOnItemEditEntity>? addOnItems,
  }) {
    return SizeEditEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      dineInPrice: dineInPrice ?? this.dineInPrice,
      takeawayPrice: takeawayPrice ?? this.takeawayPrice,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      isDefault: isDefault ?? this.isDefault,
      addOnItems: addOnItems ?? this.addOnItems,
    );
  }

  double get effectiveTakeawayPrice => takeawayPrice ?? dineInPrice;
  double get effectiveDeliveryPrice => deliveryPrice ?? dineInPrice;
}

class AddOnItemEditEntity {
  final String categoryId;
  final String categoryName;
  final String itemId;
  final String itemName;
  final double basePrice; // Price from category definition
  final double price; // Actual price for this size
  final bool isEnabled;

  const AddOnItemEditEntity({
    required this.categoryId,
    required this.categoryName,
    required this.itemId,
    required this.itemName,
    required this.basePrice,
    required this.price,
    required this.isEnabled,
  });

  AddOnItemEditEntity copyWith({
    String? categoryId,
    String? categoryName,
    String? itemId,
    String? itemName,
    double? basePrice,
    double? price,
    bool? isEnabled,
  }) {
    return AddOnItemEditEntity(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      basePrice: basePrice ?? this.basePrice,
      price: price ?? this.price,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class AddOnCategoryEntity {
  final String id;
  final String name;
  final String description;
  final List<AddOnOptionEntity> items;

  const AddOnCategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.items,
  });
}

class AddOnOptionEntity {
  final String id;
  final String name;
  final double basePrice;

  const AddOnOptionEntity({
    required this.id,
    required this.name,
    required this.basePrice,
  });
}

class BadgeEntity {
  final String id;
  final String label;
  final String color; // Hex color
  final String? icon;
  final bool isSystem;

  const BadgeEntity({
    required this.id,
    required this.label,
    required this.color,
    this.icon,
    required this.isSystem,
  });
}

class ValidationResult {
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.errors,
    required this.warnings,
  });

  bool get isValid => errors.isEmpty;
  int get issueCount => errors.length + warnings.length;
}
