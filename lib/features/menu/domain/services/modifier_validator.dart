import '../entities/modifier_group_entity.dart';

/// Domain service for validating modifier selections
/// This encapsulates business logic for validating modifier requirements
class ModifierValidator {
  /// Check if all required modifier groups have been satisfied
  ///
  /// [groups] - List of modifier groups from the menu item
  /// [selectedModifiers] - Map of modifier group ID to list of selected option IDs
  ///
  /// Returns true if all required groups meet their minimum selection requirements
  static bool validateRequiredGroups({
    required List<ModifierGroupEntity> groups,
    required Map<String, List<String>> selectedModifiers,
  }) {
    for (final group in groups) {
      if (group.isRequired) {
        final selections = selectedModifiers[group.id] ?? [];
        if (selections.length < group.minSelection) {
          return false;
        }
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
