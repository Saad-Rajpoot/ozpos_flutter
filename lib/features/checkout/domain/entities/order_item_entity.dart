import 'package:equatable/equatable.dart';
import 'modifier_entity.dart';

class OrderItemEntity extends Equatable {
  final String id;
  final String menuItemId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final List<ModifierEntity> modifiers;

  const OrderItemEntity({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.modifiers,
  });

  @override
  List<Object?> get props => [
        id,
        menuItemId,
        name,
        quantity,
        unitPrice,
        lineTotal,
        modifiers,
      ];
}
