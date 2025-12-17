import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/menu_item_entity.dart';

/// Item Configuration Events
abstract class ItemConfigEvent extends BaseEvent {
  const ItemConfigEvent();

  @override
  List<Object?> get props => [];
}

class InitializeItemConfig extends ItemConfigEvent {
  final MenuItemEntity item;

  const InitializeItemConfig({required this.item});

  @override
  List<Object?> get props => [item];
}

class SelectModifierOption extends ItemConfigEvent {
  final String groupId;
  final String optionId;
  final bool selected;

  const SelectModifierOption({
    required this.groupId,
    required this.optionId,
    required this.selected,
  });

  @override
  List<Object?> get props => [groupId, optionId, selected];
}

class SelectComboOption extends ItemConfigEvent {
  final String? comboId;

  const SelectComboOption({this.comboId});

  @override
  List<Object?> get props => [comboId];
}

class UpdateQuantity extends ItemConfigEvent {
  final int quantity;

  const UpdateQuantity({required this.quantity});

  @override
  List<Object?> get props => [quantity];
}

class ResetConfiguration extends ItemConfigEvent {
  const ResetConfiguration();

  @override
  List<Object?> get props => [];
}

class AddToCart extends ItemConfigEvent {
  const AddToCart();

  @override
  List<Object?> get props => [];
}

class UpdateSpecialInstructions extends ItemConfigEvent {
  final String instructions;

  const UpdateSpecialInstructions({required this.instructions});

  @override
  List<Object?> get props => [instructions];
}
