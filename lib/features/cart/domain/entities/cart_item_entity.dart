import 'package:equatable/equatable.dart';

/// Cart item entity
class CartItemEntity extends Equatable {
  final String lineItemId;
  final String itemId;
  final String itemName;
  final String? itemImage;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final String? specialInstructions;
  final List<String> modifiers;
  final DateTime addedAt;

  const CartItemEntity({
    required this.lineItemId,
    required this.itemId,
    required this.itemName,
    this.itemImage,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.specialInstructions,
    this.modifiers = const [],
    required this.addedAt,
  });

  CartItemEntity copyWith({
    String? lineItemId,
    String? itemId,
    String? itemName,
    String? itemImage,
    double? unitPrice,
    int? quantity,
    double? totalPrice,
    String? specialInstructions,
    List<String>? modifiers,
    DateTime? addedAt,
  }) {
    return CartItemEntity(
      lineItemId: lineItemId ?? this.lineItemId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemImage: itemImage ?? this.itemImage,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      modifiers: modifiers ?? this.modifiers,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [
        lineItemId,
        itemId,
        itemName,
        itemImage,
        unitPrice,
        quantity,
        totalPrice,
        specialInstructions,
        modifiers,
        addedAt,
      ];
}
