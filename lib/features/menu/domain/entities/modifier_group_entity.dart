import 'package:equatable/equatable.dart';
import 'modifier_option_entity.dart';

/// Modifier group entity (e.g., "Size Selection", "Sauces", "Cheese Options")
class ModifierGroupEntity extends Equatable {
  final String id;
  final String name;
  final bool isRequired; // Shows "REQUIRED" badge
  final int minSelection; // Minimum options to select
  final int maxSelection; // Maximum options ("Max 2")
  final List<ModifierOptionEntity> options;
  
  const ModifierGroupEntity({
    required this.id,
    required this.name,
    this.isRequired = false,
    this.minSelection = 0,
    this.maxSelection = 999, // Effectively unlimited
    required this.options,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        isRequired,
        minSelection,
        maxSelection,
        options,
      ];
}
