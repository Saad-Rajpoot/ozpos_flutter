import 'package:equatable/equatable.dart';

/// Represents a reusable add-on category (e.g., "Cheese Options", "Sauces")
class AddonCategory extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<AddonItem> items;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AddonCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.items,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  AddonCategory copyWith({
    String? id,
    String? name,
    String? description,
    List<AddonItem>? items,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddonCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, description, items, sortOrder, isActive, createdAt, updatedAt];
}

/// Represents an individual add-on item within a category
class AddonItem extends Equatable {
  final String id;
  final String name;
  final double basePriceDelta; // Price to add to base price
  final int sortOrder;
  final bool isActive;
  final String? icon;
  final Map<String, dynamic>? metadata; // For future extensibility

  const AddonItem({
    required this.id,
    required this.name,
    required this.basePriceDelta,
    this.sortOrder = 0,
    this.isActive = true,
    this.icon,
    this.metadata,
  });

  AddonItem copyWith({
    String? id,
    String? name,
    double? basePriceDelta,
    int? sortOrder,
    bool? isActive,
    String? icon,
    Map<String, dynamic>? metadata,
  }) {
    return AddonItem(
      id: id ?? this.id,
      name: name ?? this.name,
      basePriceDelta: basePriceDelta ?? this.basePriceDelta,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      icon: icon ?? this.icon,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, name, basePriceDelta, sortOrder, isActive, icon, metadata];
}

/// Defines rules for how add-ons are applied to a menu item or size
class AddonRule extends Equatable {
  final String id;
  final String categoryId;
  final int minSelection;
  final int maxSelection;
  final bool isRequired;
  final List<String> defaultItemIds; // Pre-selected items
  final Map<String, double> priceOverrides; // itemId -> overridden price delta
  final bool isPriceLocked; // If true, customers can't change selection

  const AddonRule({
    required this.id,
    required this.categoryId,
    this.minSelection = 0,
    this.maxSelection = 999,
    this.isRequired = false,
    this.defaultItemIds = const [],
    this.priceOverrides = const {},
    this.isPriceLocked = false,
  });

  AddonRule copyWith({
    String? id,
    String? categoryId,
    int? minSelection,
    int? maxSelection,
    bool? isRequired,
    List<String>? defaultItemIds,
    Map<String, double>? priceOverrides,
    bool? isPriceLocked,
  }) {
    return AddonRule(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      minSelection: minSelection ?? this.minSelection,
      maxSelection: maxSelection ?? this.maxSelection,
      isRequired: isRequired ?? this.isRequired,
      defaultItemIds: defaultItemIds ?? this.defaultItemIds,
      priceOverrides: priceOverrides ?? this.priceOverrides,
      isPriceLocked: isPriceLocked ?? this.isPriceLocked,
    );
  }

  /// Validates the rule configuration
  AddonRuleValidation validate(AddonCategory category) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check min <= max
    if (minSelection > maxSelection) {
      errors.add('Minimum selection ($minSelection) cannot exceed maximum ($maxSelection)');
    }

    // Check required flag consistency
    if (isRequired && minSelection == 0) {
      warnings.add('Item marked as required but minimum selection is 0');
    }

    // Check default items count
    if (defaultItemIds.length > maxSelection) {
      errors.add('Default items (${defaultItemIds.length}) exceeds maximum selection ($maxSelection)');
    }

    if (defaultItemIds.length < minSelection) {
      errors.add('Default items (${defaultItemIds.length}) is less than minimum selection ($minSelection)');
    }

    // Check for duplicate defaults
    if (defaultItemIds.length != defaultItemIds.toSet().length) {
      errors.add('Duplicate items in default selection');
    }

    // Check default items exist in category
    final categoryItemIds = category.items.map((item) => item.id).toSet();
    for (final defaultId in defaultItemIds) {
      if (!categoryItemIds.contains(defaultId)) {
        errors.add('Default item $defaultId not found in category ${category.name}');
      }
    }

    // Check price overrides
    for (final itemId in priceOverrides.keys) {
      if (!categoryItemIds.contains(itemId)) {
        warnings.add('Price override for unknown item $itemId');
      }
      if (priceOverrides[itemId]! < 0) {
        errors.add('Negative price override for item $itemId');
      }
    }

    return AddonRuleValidation(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        minSelection,
        maxSelection,
        isRequired,
        defaultItemIds,
        priceOverrides,
        isPriceLocked,
      ];
}

/// Validation result for addon rules
class AddonRuleValidation {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const AddonRuleValidation({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  int get issueCount => errors.length + warnings.length;
}

/// Represents how add-on rules are attached to a menu item
/// Can be attached at item level (applies to all sizes or items without sizes)
/// or at size level (overrides item-level rules for specific size)
class ItemAddonAttachment extends Equatable {
  final String itemId;
  final String? sizeId; // null means item-level (all sizes), otherwise size-specific
  final List<AddonRule> rules;
  final bool appliesToAllSizes; // Only relevant when sizeId is null

  const ItemAddonAttachment({
    required this.itemId,
    this.sizeId,
    required this.rules,
    this.appliesToAllSizes = true,
  });

  bool get isItemLevel => sizeId == null;
  bool get isSizeLevel => sizeId != null;

  ItemAddonAttachment copyWith({
    String? itemId,
    String? sizeId,
    List<AddonRule>? rules,
    bool? appliesToAllSizes,
  }) {
    return ItemAddonAttachment(
      itemId: itemId ?? this.itemId,
      sizeId: sizeId ?? this.sizeId,
      rules: rules ?? this.rules,
      appliesToAllSizes: appliesToAllSizes ?? this.appliesToAllSizes,
    );
  }

  @override
  List<Object?> get props => [itemId, sizeId, rules, appliesToAllSizes];
}

/// Utility to resolve effective rules for a specific size
/// Handles inheritance: size-specific rules override item-level rules
class AddonRuleResolver {
  /// Get effective rules for a specific size
  /// Priority: size-specific > item-level (all sizes)
  static List<AddonRule> getEffectiveRules({
    required String itemId,
    required String? sizeId,
    required List<ItemAddonAttachment> attachments,
  }) {
    // First check for size-specific rules
    if (sizeId != null) {
      final sizeAttachment = attachments.firstWhere(
        (a) => a.itemId == itemId && a.sizeId == sizeId,
        orElse: () => const ItemAddonAttachment(itemId: '', rules: []),
      );

      if (sizeAttachment.itemId.isNotEmpty) {
        return sizeAttachment.rules;
      }
    }

    // Fall back to item-level rules
    final itemAttachment = attachments.firstWhere(
      (a) => a.itemId == itemId && a.isItemLevel && a.appliesToAllSizes,
      orElse: () => const ItemAddonAttachment(itemId: '', rules: []),
    );

    return itemAttachment.rules;
  }

  /// Check if a size has specific overrides
  static bool hasSpecificRules({
    required String itemId,
    required String sizeId,
    required List<ItemAddonAttachment> attachments,
  }) {
    return attachments.any((a) => a.itemId == itemId && a.sizeId == sizeId);
  }

  /// Calculate total price including add-ons
  static double calculateTotalPrice({
    required double basePrice,
    required List<AddonRule> rules,
    required Map<String, AddonCategory> categoryMap,
    required List<String> selectedItemIds,
  }) {
    double total = basePrice;

    for (final rule in rules) {
      final category = categoryMap[rule.categoryId];
      if (category == null) continue;

      for (final itemId in selectedItemIds) {
        final item = category.items.firstWhere(
          (i) => i.id == itemId,
          orElse: () => const AddonItem(id: '', name: '', basePriceDelta: 0),
        );

        if (item.id.isEmpty) continue;

        // Use price override if available, otherwise use base price delta
        final priceDelta = rule.priceOverrides[itemId] ?? item.basePriceDelta;
        total += priceDelta;
      }
    }

    return total;
  }
}

/// Summary info for displaying addon category in picker
class AddonCategorySummary {
  final String id;
  final String name;
  final int itemCount;
  final bool isAttached;

  const AddonCategorySummary({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.isAttached,
  });
}

/// Configuration for add-on selector UI
class AddonSelectorConfig {
  final bool allowPriceOverrides;
  final bool showPriceTotal;
  final bool enableSearch;
  final bool enableDragSort;
  final String? customEmptyMessage;

  const AddonSelectorConfig({
    this.allowPriceOverrides = true,
    this.showPriceTotal = true,
    this.enableSearch = true,
    this.enableDragSort = true,
    this.customEmptyMessage,
  });
}
