// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CartItemModelImpl _$$CartItemModelImplFromJson(Map<String, dynamic> json) =>
    _$CartItemModelImpl(
      lineItemId: json['lineItemId'] as String,
      itemId: json['itemId'] as String,
      itemName: json['itemName'] as String,
      itemImage: json['itemImage'] as String?,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      specialInstructions: json['specialInstructions'] as String?,
      modifiers:
          (json['modifiers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      addedAt: DateTime.parse(json['addedAt'] as String),
    );

Map<String, dynamic> _$$CartItemModelImplToJson(_$CartItemModelImpl instance) =>
    <String, dynamic>{
      'lineItemId': instance.lineItemId,
      'itemId': instance.itemId,
      'itemName': instance.itemName,
      'itemImage': instance.itemImage,
      'unitPrice': instance.unitPrice,
      'quantity': instance.quantity,
      'totalPrice': instance.totalPrice,
      'specialInstructions': instance.specialInstructions,
      'modifiers': instance.modifiers,
      'addedAt': instance.addedAt.toIso8601String(),
    };
