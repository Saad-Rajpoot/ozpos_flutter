import 'package:equatable/equatable.dart';
import 'modifier_group_entity.dart';

/// Modifier option entity (e.g., "Large" size, "BBQ Sauce", "Extra Cheese")
/// May have nested modifier groups shown when this option is selected.
class ModifierOptionEntity extends Equatable {
  final String id;
  final String name;
  final double priceDelta; // +$5.00, or 0.00 for "Free"
  final int? calories;
  final bool isDefault; // Pre-selected option in the group
  final List<ModifierGroupEntity> nestedModifierGroups; // Shown when selected

  const ModifierOptionEntity({
    required this.id,
    required this.name,
    required this.priceDelta,
    this.calories,
    this.isDefault = false,
    this.nestedModifierGroups = const [],
  });

  bool get hasNestedModifiers => nestedModifierGroups.isNotEmpty;

  @override
  List<Object?> get props =>
      [id, name, priceDelta, calories, isDefault, nestedModifierGroups];
}
