import 'package:equatable/equatable.dart';
import '../../domain/entities/addon_management_entities.dart';
import 'addon_item_model.dart';

/// Model class for AddonCategory JSON serialization/deserialization
class AddonCategoryModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<AddonItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AddonCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert JSON to AddonCategoryModel
  factory AddonCategoryModel.fromJson(Map<String, dynamic> json) {
    return AddonCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) => AddonItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          <AddonItemModel>[],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert AddonCategoryModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert AddonCategoryModel to AddonCategory entity
  AddonCategory toEntity() {
    return AddonCategory(
      id: id,
      name: name,
      description: description,
      items: items.map((item) => item.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create AddonCategoryModel from AddonCategory entity
  factory AddonCategoryModel.fromEntity(AddonCategory entity) {
    return AddonCategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      items: entity.items
          .map((item) => AddonItemModel.fromEntity(item))
          .toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    items,
    createdAt,
    updatedAt,
  ];
}
