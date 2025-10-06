import 'package:equatable/equatable.dart';

/// Modifier option entity (e.g., "Large" size, "BBQ Sauce", "Extra Cheese")
class ModifierOptionEntity extends Equatable {
  final String id;
  final String name;
  final double priceDelta; // +$5.00, or 0.00 for "Free"
  final bool isDefault; // Pre-selected option in the group
  
  const ModifierOptionEntity({
    required this.id,
    required this.name,
    required this.priceDelta,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [id, name, priceDelta, isDefault];
}
