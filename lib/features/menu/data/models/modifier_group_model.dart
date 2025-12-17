import '../../domain/entities/modifier_group_entity.dart';
import 'modifier_option_model.dart';

/// Modifier group model (e.g., "Size Selection", "Sauces", "Cheese Options")
class ModifierGroupModel {
  final String id;
  final String name;
  final bool isRequired;
  final int minSelection;
  final int maxSelection;
  final List<ModifierOptionModel> options;

  const ModifierGroupModel({
    required this.id,
    required this.name,
    this.isRequired = false,
    this.minSelection = 0,
    this.maxSelection = 999,
    required this.options,
  });

  /// Create entity from model
  ModifierGroupEntity toEntity() {
    return ModifierGroupEntity(
      id: id,
      name: name,
      isRequired: isRequired,
      minSelection: minSelection,
      maxSelection: maxSelection,
      options: options.map((model) => model.toEntity()).toList(),
    );
  }

  /// Create model from entity
  factory ModifierGroupModel.fromEntity(ModifierGroupEntity entity) {
    return ModifierGroupModel(
      id: entity.id,
      name: entity.name,
      isRequired: entity.isRequired,
      minSelection: entity.minSelection,
      maxSelection: entity.maxSelection,
      options: entity.options
          .map((option) => ModifierOptionModel.fromEntity(option))
          .toList(),
    );
  }

  /// Create model from JSON
  factory ModifierGroupModel.fromJson(Map<String, dynamic> json) {
    return ModifierGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      isRequired: json['is_required'] as bool? ?? false,
      minSelection: json['min_selection'] as int? ?? 0,
      maxSelection: json['max_selection'] as int? ?? 999,
      options: (json['options'] as List<dynamic>?)
              ?.map((option) => ModifierOptionModel.fromJson(option))
              .toList() ??
          [],
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_required': isRequired,
      'min_selection': minSelection,
      'max_selection': maxSelection,
      'options': options.map((option) => option.toJson()).toList(),
    };
  }

  /// Create a copy of this model with some fields replaced
  ModifierGroupModel copyWith({
    String? id,
    String? name,
    bool? isRequired,
    int? minSelection,
    int? maxSelection,
    List<ModifierOptionModel>? options,
  }) {
    return ModifierGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isRequired: isRequired ?? this.isRequired,
      minSelection: minSelection ?? this.minSelection,
      maxSelection: maxSelection ?? this.maxSelection,
      options: options ?? this.options,
    );
  }

  @override
  String toString() {
    return 'ModifierGroupModel(id: $id, name: $name, options: ${options.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModifierGroupModel &&
        other.id == id &&
        other.name == name &&
        other.isRequired == isRequired &&
        other.minSelection == minSelection &&
        other.maxSelection == maxSelection &&
        other.options == options;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, isRequired, minSelection, maxSelection, options);
}
