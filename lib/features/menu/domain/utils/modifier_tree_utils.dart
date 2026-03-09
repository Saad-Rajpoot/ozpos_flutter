import '../entities/menu_item_entity.dart';
import '../entities/modifier_group_entity.dart';
import '../entities/modifier_option_entity.dart';

/// Utilities for walking modifier trees (including nested modifiers)
class ModifierTreeUtils {
  /// Pairs of (group name, option name) for display as "Group: Option" lines.
  static List<({String groupName, String optionName})> getModifierDisplayLines(
    MenuItemEntity item,
    Map<String, List<String>> selectedModifiers,
  ) {
    final out = <({String groupName, String optionName})>[];
    _collectDisplayLines(item.modifierGroups, selectedModifiers, out);
    return out;
  }

  /// Pairs of (group name, option name, priceDelta) for display where
  /// modifier price information is needed (e.g. cart line items).
  static List<({String groupName, String optionName, double priceDelta})>
      getModifierDisplayLinesWithPrice(
    MenuItemEntity item,
    Map<String, List<String>> selectedModifiers,
  ) {
    final out =
        <({String groupName, String optionName, double priceDelta})>[];
    _collectDisplayLinesWithPrice(item.modifierGroups, selectedModifiers, out);
    return out;
  }

  static void _collectDisplayLines(
    List<ModifierGroupEntity> groups,
    Map<String, List<String>> selectedModifiers,
    List<({String groupName, String optionName})> out,
  ) {
    for (final group in groups) {
      final optionIds = selectedModifiers[group.id] ?? [];
      for (final optionId in optionIds) {
        ModifierOptionEntity? option;
        for (final o in group.options) {
          if (o.id == optionId) {
            option = o;
            break;
          }
        }
        if (option == null) continue;
        out.add((groupName: group.name, optionName: option.name));
        if (option.nestedModifierGroups.isNotEmpty) {
          _collectDisplayLines(option.nestedModifierGroups, selectedModifiers, out);
        }
      }
    }
  }

  static void _collectDisplayLinesWithPrice(
    List<ModifierGroupEntity> groups,
    Map<String, List<String>> selectedModifiers,
    List<({String groupName, String optionName, double priceDelta})> out,
  ) {
    for (final group in groups) {
      final optionIds = selectedModifiers[group.id] ?? [];
      for (final optionId in optionIds) {
        ModifierOptionEntity? option;
        for (final o in group.options) {
          if (o.id == optionId) {
            option = o;
            break;
          }
        }
        if (option == null) continue;
        out.add((
          groupName: group.name,
          optionName: option.name,
          priceDelta: option.priceDelta,
        ));
        if (option.nestedModifierGroups.isNotEmpty) {
          _collectDisplayLinesWithPrice(
            option.nestedModifierGroups,
            selectedModifiers,
            out,
          );
        }
      }
    }
  }
  /// Separator for composite group IDs (parentGroupId|parentOptionId|nestedGroupId)
  static const String modifierPathSeparator = '|';
  /// Collect all modifier groups that are currently "active" for validation.
  /// Active = top-level groups + nested groups whose parent option is selected.
  static List<ModifierGroupEntity> getActiveGroups(
    MenuItemEntity item,
    Map<String, List<String>> selectedModifiers,
  ) {
    final out = <ModifierGroupEntity>[];
    _collectActiveGroups(item.modifierGroups, selectedModifiers, out);
    return out;
  }

  static void _collectActiveGroups(
    List<ModifierGroupEntity> groups,
    Map<String, List<String>> selectedModifiers,
    List<ModifierGroupEntity> out,
  ) {
    for (final g in groups) {
      out.add(g);
      final sel = selectedModifiers[g.id] ?? [];
      for (final opt in g.options) {
        if (sel.contains(opt.id) && opt.nestedModifierGroups.isNotEmpty) {
          _collectActiveGroups(opt.nestedModifierGroups, selectedModifiers, out);
        }
      }
    }
  }

  /// Find a modifier group by ID (supports composite IDs for nested groups)
  static ModifierGroupEntity? findGroupById(
    MenuItemEntity item,
    String groupId,
  ) {
    return _findInGroups(item.modifierGroups, groupId);
  }

  static ModifierGroupEntity? _findInGroups(
    List<ModifierGroupEntity> groups,
    String groupId,
  ) {
    for (final g in groups) {
      if (g.id == groupId) return g;
      for (final opt in g.options) {
        final found = _findInGroups(opt.nestedModifierGroups, groupId);
        if (found != null) return found;
      }
    }
    return null;
  }
}
