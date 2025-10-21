import 'package:equatable/equatable.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';

class CartLineItemEntity extends Equatable {
  final String id;
  final MenuItemEntity menuItem;
  final int quantity;
  final double lineTotal;
  final List<String> modifiers;
  final String? specialInstructions;

  const CartLineItemEntity({
    required this.id,
    required this.menuItem,
    required this.quantity,
    required this.lineTotal,
    required this.modifiers,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [
        id,
        menuItem,
        quantity,
        lineTotal,
        modifiers,
        specialInstructions,
      ];
}
