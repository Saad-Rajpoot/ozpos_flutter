import 'package:equatable/equatable.dart';
import 'modifier_model.dart';
import '../../domain/entities/order_item_entity.dart';

// Order item model
class OrderItem extends Equatable {
  final String id;
  final String menuItemId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final List<ModifierModel> modifiers;

  const OrderItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.modifiers,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      menuItemId: json['menuItemId'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
      modifiers: List<ModifierModel>.from(
        json['modifiers'].map((x) => ModifierModel.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuItemId': menuItemId,
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
      'modifiers': List<dynamic>.from(modifiers.map((x) => x.toJson())),
    };
  }

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

  // Convert to domain entity
  OrderItemEntity toEntity() {
    return OrderItemEntity(
      id: id,
      menuItemId: menuItemId,
      name: name,
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal: lineTotal,
      modifiers: modifiers.map((modifier) => modifier.toEntity()).toList(),
    );
  }

  // Create from domain entity
  factory OrderItem.fromEntity(OrderItemEntity entity) {
    return OrderItem(
      id: entity.id,
      menuItemId: entity.menuItemId,
      name: entity.name,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      lineTotal: entity.lineTotal,
      modifiers: entity.modifiers
          .map((modifier) => ModifierModel.fromEntity(modifier))
          .toList(),
    );
  }
}
