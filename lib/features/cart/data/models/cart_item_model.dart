import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/cart_item_entity.dart';

part 'cart_item_model.freezed.dart';
part 'cart_item_model.g.dart';

/// Cart item model
@freezed
class CartItemModel with _$CartItemModel {
  const factory CartItemModel({
    required String lineItemId,
    required String itemId,
    required String itemName,
    String? itemImage,
    required double unitPrice,
    required int quantity,
    required double totalPrice,
    String? specialInstructions,
    @Default([]) List<String> modifiers,
    required DateTime addedAt,
  }) = _CartItemModel;

  const CartItemModel._();

  /// Create entity from model
  CartItemEntity toEntity() {
    return CartItemEntity(
      lineItemId: lineItemId,
      itemId: itemId,
      itemName: itemName,
      itemImage: itemImage,
      unitPrice: unitPrice,
      quantity: quantity,
      totalPrice: totalPrice,
      specialInstructions: specialInstructions,
      modifiers: modifiers,
      addedAt: addedAt,
    );
  }

  /// Create model from entity
  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      lineItemId: entity.lineItemId,
      itemId: entity.itemId,
      itemName: entity.itemName,
      itemImage: entity.itemImage,
      unitPrice: entity.unitPrice,
      quantity: entity.quantity,
      totalPrice: entity.totalPrice,
      specialInstructions: entity.specialInstructions,
      modifiers: entity.modifiers,
      addedAt: entity.addedAt,
    );
  }

  /// Create model from JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$$CartItemModelImplFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$$CartItemModelImplToJson(this as _$CartItemModelImpl);
}
