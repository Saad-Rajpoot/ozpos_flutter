import '../entities/menu_item_entity.dart';

/// Domain service for calculating menu item prices
/// This encapsulates business logic for price calculations including modifiers and combos
class MenuItemPriceCalculator {
  /// Calculate the total price for a menu item with selected modifiers, combo, and quantity
  ///
  /// [item] - The menu item entity
  /// [selectedModifiers] - Map of modifier group ID to list of selected option IDs
  /// [selectedComboId] - Optional combo option ID
  /// [quantity] - Quantity of the item
  ///
  /// Returns the total price (base price + modifiers + combo) * quantity
  static double calculatePrice({
    required MenuItemEntity item,
    required Map<String, List<String>> selectedModifiers,
    String? selectedComboId,
    required int quantity,
  }) {
    if (quantity <= 0) {
      return 0.0;
    }

    double basePrice = item.basePrice;

    // Add modifier prices
    for (final groupEntry in selectedModifiers.entries) {
      final groupId = groupEntry.key;
      final selectedOptionIds = groupEntry.value;

      // Find the modifier group
      final group = item.modifierGroups.firstWhere(
        (g) => g.id == groupId,
        orElse: () => throw ArgumentError('Modifier group $groupId not found'),
      );

      // Add price for each selected option
      for (final optionId in selectedOptionIds) {
        final option = group.options.firstWhere(
          (o) => o.id == optionId,
          orElse: () => throw ArgumentError(
            'Modifier option $optionId not found in group $groupId',
          ),
        );
        basePrice += option.priceDelta;
      }
    }

    // Add combo price
    if (selectedComboId != null && item.comboOptions.isNotEmpty) {
      final combo = item.comboOptions.firstWhere(
        (c) => c.id == selectedComboId,
        orElse: () => throw ArgumentError(
          'Combo option $selectedComboId not found',
        ),
      );
      basePrice += combo.priceDelta;
    }

    return basePrice * quantity;
  }

  /// Calculate unit price (price per item) without quantity
  ///
  /// [item] - The menu item entity
  /// [selectedModifiers] - Map of modifier group ID to list of selected option IDs
  /// [selectedComboId] - Optional combo option ID
  ///
  /// Returns the unit price (base price + modifiers + combo)
  static double calculateUnitPrice({
    required MenuItemEntity item,
    required Map<String, List<String>> selectedModifiers,
    String? selectedComboId,
  }) {
    return calculatePrice(
      item: item,
      selectedModifiers: selectedModifiers,
      selectedComboId: selectedComboId,
      quantity: 1,
    );
  }

  /// Get default modifiers for a menu item
  /// Returns a map of modifier group ID to list of default option IDs
  static Map<String, List<String>> getDefaultModifiers(
    MenuItemEntity item,
  ) {
    final defaultModifiers = <String, List<String>>{};

    for (final group in item.modifierGroups) {
      final defaultOptions = group.options
          .where((opt) => opt.isDefault)
          .map((opt) => opt.id)
          .toList();
      if (defaultOptions.isNotEmpty) {
        defaultModifiers[group.id] = defaultOptions;
      }
    }

    return defaultModifiers;
  }
}
