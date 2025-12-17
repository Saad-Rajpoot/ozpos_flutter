import 'package:equatable/equatable.dart';
import 'modifier_group_entity.dart';
import '../../../combos/domain/entities/combo_option_entity.dart';

/// Menu item entity
class MenuItemEntity extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final String? image;
  final double basePrice;
  final List<String> tags;
  final List<ModifierGroupEntity> modifierGroups;
  final List<ComboOptionEntity> comboOptions;
  final List<String> recommendedAddOnIds;

  const MenuItemEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    this.image,
    required this.basePrice,
    this.tags = const [],
    this.modifierGroups = const [],
    this.comboOptions = const [],
    this.recommendedAddOnIds = const [],
  });

  @override
  List<Object?> get props => [
        id,
        categoryId,
        name,
        description,
        image,
        basePrice,
        tags,
        modifierGroups,
        comboOptions,
        recommendedAddOnIds,
      ];
}
