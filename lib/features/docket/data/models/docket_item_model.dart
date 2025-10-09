import 'package:equatable/equatable.dart';
import '../../domain/entities/docket_management_entities.dart';

/// Model class for DocketItem JSON serialization/deserialization
class DocketItemModel extends Equatable {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const DocketItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  /// Convert JSON to DocketItemModel
  factory DocketItemModel.fromJson(Map<String, dynamic> json) {
    return DocketItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert DocketItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  /// Convert DocketItemModel to DocketItem entity
  DocketItemEntity toEntity() {
    return DocketItemEntity(
      id: id,
      name: name,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
    );
  }

  /// Create DocketItemModel from DocketItem entity
  factory DocketItemModel.fromEntity(DocketItemEntity entity) {
    return DocketItemModel(
      id: entity.id,
      name: entity.name,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      totalPrice: entity.totalPrice,
    );
  }

  @override
  List<Object?> get props => [id, name, quantity, unitPrice, totalPrice];
}
