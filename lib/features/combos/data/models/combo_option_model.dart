import 'package:equatable/equatable.dart';
import '../../domain/entities/combo_option_entity.dart';

/// Model class for ComboOption JSON serialization/deserialization
class ComboOptionModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double priceDelta;

  const ComboOptionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priceDelta,
  });

  /// Convert JSON to ComboOptionModel
  factory ComboOptionModel.fromJson(Map<String, dynamic> json) {
    return ComboOptionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      priceDelta: (json['priceDelta'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert ComboOptionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'priceDelta': priceDelta,
    };
  }

  /// Convert ComboOptionModel to ComboOptionEntity
  ComboOptionEntity toEntity() {
    return ComboOptionEntity(
      id: id,
      name: name,
      description: description,
      priceDelta: priceDelta,
    );
  }

  /// Create ComboOptionModel from ComboOptionEntity
  factory ComboOptionModel.fromEntity(ComboOptionEntity entity) {
    return ComboOptionModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      priceDelta: entity.priceDelta,
    );
  }

  @override
  List<Object?> get props => [id, name, description, priceDelta];
}
