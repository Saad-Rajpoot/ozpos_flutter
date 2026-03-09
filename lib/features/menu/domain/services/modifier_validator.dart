import '../entities/menu_item_entity.dart';
import '../entities/modifier_group_entity.dart';
import '../utils/modifier_tree_utils.dart';

/// Domain service for validating modifier selections
/// This encapsulates business logic for validating modifier requirements
class ModifierValidator {
  /// Check if all modifier groups (including nested when parent is selected) meet
  /// their minimum selection requirements.
  ///
  /// [item] - Menu item entity (used to walk modifier tree)
  /// [selectedModifiers] - Map of modifier group ID to list of selected option IDs
  ///
  /// Returns true if all active groups meet their minimum selection requirements
  static bool validateRequiredGroups({
    required MenuItemEntity item,
    required Map<String, List<String>> selectedModifiers,
  }) {
    final activeGroups = ModifierTreeUtils.getActiveGroups(
      item,
      selectedModifiers,
    );
    for (final group in activeGroups) {
      final selections = selectedModifiers[group.id] ?? [];
      if (selections.length < group.minSelection) {
        return false;
      }
    }
    return true;
  }

  /// Returns names of required modifier groups that are not yet satisfied
  /// (minSelection > 0 and current selections < minSelection).
  static List<String> getMissingRequiredGroupNames({
    required MenuItemEntity item,
    required Map<String, List<String>> selectedModifiers,
  }) {
    final activeGroups = ModifierTreeUtils.getActiveGroups(
      item,
      selectedModifiers,
    );
    final missing = <String>[];
    for (final group in activeGroups) {
      if (group.minSelection <= 0) continue;
      final selections = selectedModifiers[group.id] ?? [];
      if (selections.length < group.minSelection && group.name.isNotEmpty) {
        missing.add(group.name);
      }
    }
    return missing;
  }

  /// Legacy: validate a flat list of groups (used where nested are not applicable)
  static bool validateRequiredGroupsFlat({
    required List<ModifierGroupEntity> groups,
    required Map<String, List<String>> selectedModifiers,
  }) {
    for (final group in groups) {
      final selections = selectedModifiers[group.id] ?? [];
      if (selections.length < group.minSelection) {
        return false;
      }
    }
    return true;
  }

  /// Check if modifier selections respect maximum limits
  ///
  /// [groups] - List of modifier groups from the menu item
  /// [selectedModifiers] - Map of modifier group ID to list of selected option IDs
  ///
  /// Returns true if all groups respect their maximum selection limits
  static bool validateMaxSelections({
    required List<ModifierGroupEntity> groups,
    required Map<String, List<String>> selectedModifiers,
  }) {
    for (final group in groups) {
      final selections = selectedModifiers[group.id] ?? [];
      if (selections.length > group.maxSelection) {
        return false;
      }
    }
    return true;
  }

  /// Check if a modifier option can be selected
  ///
  /// [group] - The modifier group
  /// [currentSelections] - Current list of selected option IDs for this group
  /// [optionId] - The option ID to check
  ///
  /// Returns true if the option can be added to the selections
  static bool canSelectOption({
    required ModifierGroupEntity group,
    required List<String> currentSelections,
    required String optionId,
  }) {
    // Check if already selected (can be deselected)
    if (currentSelections.contains(optionId)) {
      return true;
    }

    // Check if max selection reached
    if (group.maxSelection == 1) {
      // Radio button - can always select (will replace current)
      return true;
    } else {
      // Checkbox - check max limit
      return currentSelections.length < group.maxSelection;
    }
  }
}
