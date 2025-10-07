import 'package:equatable/equatable.dart';
import '../../domain/entities/addon_management_entities.dart';

abstract class AddonManagementState extends Equatable {
  const AddonManagementState();

  @override
  List<Object?> get props => [];
}

class AddonManagementInitial extends AddonManagementState {
  const AddonManagementInitial();
}

class AddonManagementLoading extends AddonManagementState {
  const AddonManagementLoading();
}

class AddonManagementLoaded extends AddonManagementState {
  final List<AddonCategory> categories;
  final Map<String, List<ItemAddonAttachment>>
  itemAttachments; // itemId -> attachments
  final Map<String, Map<String, AddonRuleValidation>>
  validationResults; // itemId -> categoryId -> validation
  final bool hasUnsavedChanges;

  const AddonManagementLoaded({
    required this.categories,
    required this.itemAttachments,
    this.validationResults = const {},
    this.hasUnsavedChanges = false,
  });

  AddonManagementLoaded copyWith({
    List<AddonCategory>? categories,
    Map<String, List<ItemAddonAttachment>>? itemAttachments,
    Map<String, Map<String, AddonRuleValidation>>? validationResults,
    bool? hasUnsavedChanges,
  }) {
    return AddonManagementLoaded(
      categories: categories ?? this.categories,
      itemAttachments: itemAttachments ?? this.itemAttachments,
      validationResults: validationResults ?? this.validationResults,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  /// Get attachments for a specific item
  List<ItemAddonAttachment> getItemAttachments(String itemId) {
    return itemAttachments[itemId] ?? [];
  }

  /// Get category by ID
  AddonCategory? getCategoryById(String categoryId) {
    try {
      return categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Get effective rules for a specific size
  List<AddonRule> getEffectiveRules(String itemId, String? sizeId) {
    final attachments = getItemAttachments(itemId);
    return AddonRuleResolver.getEffectiveRules(
      itemId: itemId,
      sizeId: sizeId,
      attachments: attachments,
    );
  }

  /// Check if a category is attached to an item or size
  bool isCategoryAttached(String itemId, String? sizeId, String categoryId) {
    final attachments = getItemAttachments(itemId);
    return attachments.any(
      (a) =>
          a.sizeId == sizeId && a.rules.any((r) => r.categoryId == categoryId),
    );
  }

  /// Get summary of all categories for picker
  List<AddonCategorySummary> getCategorySummaries(
    String itemId,
    String? sizeId,
  ) {
    return categories.map((category) {
      return AddonCategorySummary(
        id: category.id,
        name: category.name,
        itemCount: category.items.length,
        isAttached: isCategoryAttached(itemId, sizeId, category.id),
      );
    }).toList();
  }

  /// Get validation for specific item and category
  AddonRuleValidation? getValidation(String itemId, String categoryId) {
    return validationResults[itemId]?[categoryId];
  }

  /// Check if all rules are valid for an item
  bool isItemValid(String itemId) {
    final itemValidations = validationResults[itemId];
    if (itemValidations == null || itemValidations.isEmpty) return true;
    return itemValidations.values.every((v) => v.isValid);
  }

  /// Get count of validation errors for an item
  int getErrorCount(String itemId) {
    final itemValidations = validationResults[itemId];
    if (itemValidations == null) return 0;
    return itemValidations.values.fold(0, (sum, v) => sum + v.errors.length);
  }

  /// Get count of validation warnings for an item
  int getWarningCount(String itemId) {
    final itemValidations = validationResults[itemId];
    if (itemValidations == null) return 0;
    return itemValidations.values.fold(0, (sum, v) => sum + v.warnings.length);
  }

  /// Calculate total count of addon items selected for display
  int getSelectedAddonCount(String itemId, String? sizeId) {
    final rules = getEffectiveRules(itemId, sizeId);
    return rules.fold(0, (sum, rule) => sum + rule.defaultItemIds.length);
  }

  /// Get all selected addon items with their prices
  List<AddonItemWithPrice> getSelectedAddons(String itemId, String? sizeId) {
    final rules = getEffectiveRules(itemId, sizeId);
    final result = <AddonItemWithPrice>[];

    for (final rule in rules) {
      final category = getCategoryById(rule.categoryId);
      if (category == null) continue;

      for (final itemId in rule.defaultItemIds) {
        final item = category.items.firstWhere(
          (i) => i.id == itemId,
          orElse: () => const AddonItem(id: '', name: '', basePriceDelta: 0),
        );

        if (item.id.isEmpty) continue;

        final price = rule.priceOverrides[itemId] ?? item.basePriceDelta;
        result.add(
          AddonItemWithPrice(
            categoryName: category.name,
            itemName: item.name,
            price: price,
          ),
        );
      }
    }

    return result;
  }

  @override
  List<Object?> get props => [
    categories,
    itemAttachments,
    validationResults,
    hasUnsavedChanges,
  ];
}

class AddonManagementError extends AddonManagementState {
  final String message;

  const AddonManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Helper class for displaying selected addons with prices
class AddonItemWithPrice {
  final String categoryName;
  final String itemName;
  final double price;

  const AddonItemWithPrice({
    required this.categoryName,
    required this.itemName,
    required this.price,
  });
}
