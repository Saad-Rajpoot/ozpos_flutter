import '../../domain/entities/modifier_option_entity.dart';

/// Modifier option model (e.g., "Large" size, "BBQ Sauce", "Extra Cheese")
class ModifierOptionModel {
  final String id;
  final String name;
  final double priceDelta;
  final bool isDefault;

  const ModifierOptionModel({
    required this.id,
    required this.name,
    required this.priceDelta,
    this.isDefault = false,
  });

  /// Create entity from model
  ModifierOptionEntity toEntity() {
    return ModifierOptionEntity(
      id: id,
      name: name,
      priceDelta: priceDelta,
      isDefault: isDefault,
    );
  }

  /// Create model from entity
  factory ModifierOptionModel.fromEntity(ModifierOptionEntity entity) {
    return ModifierOptionModel(
      id: entity.id,
      name: entity.name,
      priceDelta: entity.priceDelta,
      isDefault: entity.isDefault,
    );
  }

  /// Create model from JSON
  factory ModifierOptionModel.fromJson(Map<String, dynamic> json) {
    return ModifierOptionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      priceDelta: (json['price_delta'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price_delta': priceDelta,
      'is_default': isDefault,
    };
  }

  /// Create a copy of this model with some fields replaced
  ModifierOptionModel copyWith({
    String? id,
    String? name,
    double? priceDelta,
    bool? isDefault,
  }) {
    return ModifierOptionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      priceDelta: priceDelta ?? this.priceDelta,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  String toString() {
    return 'ModifierOptionModel(id: $id, name: $name, priceDelta: $priceDelta)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModifierOptionModel &&
        other.id == id &&
        other.name == name &&
        other.priceDelta == priceDelta &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode => Object.hash(id, name, priceDelta, isDefault);
}
