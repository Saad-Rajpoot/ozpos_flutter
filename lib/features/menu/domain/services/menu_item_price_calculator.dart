import '../entities/menu_item_entity.dart';
import '../utils/modifier_tree_utils.dart';

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

    // Only add prices for active groups (nested groups only when parent selected)
    final activeGroupIds = ModifierTreeUtils
        .getActiveGroups(item, selectedModifiers)
        .map((g) => g.id)
        .toSet();

    for (final groupEntry in selectedModifiers.entries) {
      final groupId = groupEntry.key;
      if (!activeGroupIds.contains(groupId)) continue;

      final selectedOptionIds = groupEntry.value;
      final group = ModifierTreeUtils.findGroupById(item, groupId);
      if (group == null) continue;

      for (final optionId in selectedOptionIds) {
        try {
          final option = group.options.firstWhere((o) => o.id == optionId);
          basePrice += option.priceDelta;
        } catch (_) {
          // Option not found in group, skip
        }
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

  /// Get default modifiers for a menu item.
  /// Returns empty - required modifiers are not pre-selected; user must select them.
  static Map<String, List<String>> getDefaultModifiers(
    MenuItemEntity item,
  ) {
    return {};
  }

  /// Calculate total calories for a menu item with selected modifiers.
  /// Returns null if item has no calories and no modifier calories.
  static int? calculateTotalCalories({
    required MenuItemEntity item,
    required Map<String, List<String>> selectedModifiers,
  }) {
    int baseCal = item.calories ?? 0;
    int modifierCal = 0;

    final activeGroupIds = ModifierTreeUtils
        .getActiveGroups(item, selectedModifiers)
        .map((g) => g.id)
        .toSet();

    for (final entry in selectedModifiers.entries) {
      if (!activeGroupIds.contains(entry.key)) continue;
      final group = ModifierTreeUtils.findGroupById(item, entry.key);
      if (group == null) continue;
      for (final optionId in entry.value) {
        try {
          final opt =
              group.options.firstWhere((o) => o.id == optionId);
          modifierCal += opt.calories ?? 0;
        } catch (_) {}
      }
    }

    final total = baseCal + modifierCal;
    return total > 0 ? total : null;
  }
}
