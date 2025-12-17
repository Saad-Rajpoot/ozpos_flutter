import 'package:equatable/equatable.dart';
import '../../domain/entities/modifier_entity.dart';

// Modifier model
class ModifierModel extends Equatable {
  final String name;
  final double price;

  const ModifierModel({
    required this.name,
    required this.price,
  });

  factory ModifierModel.fromJson(Map<String, dynamic> json) {
    return ModifierModel(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [name, price];

  // Convert to domain entity
  ModifierEntity toEntity() {
    return ModifierEntity(
      name: name,
      price: price,
    );
  }

  // Create from domain entity
  factory ModifierModel.fromEntity(ModifierEntity entity) {
    return ModifierModel(
      name: entity.name,
      price: entity.price,
    );
  }
}
