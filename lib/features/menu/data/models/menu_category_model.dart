import '../../domain/entities/menu_category_entity.dart';

/// Menu category model
class MenuCategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenuCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create entity from model
  MenuCategoryEntity toEntity() {
    return MenuCategoryEntity(
      id: id,
      name: name,
      description: description,
      image: image,
      sortOrder: sortOrder,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create model from entity
  factory MenuCategoryModel.fromEntity(MenuCategoryEntity entity) {
    return MenuCategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      image: entity.image,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Create a copy of this model with some fields replaced
  MenuCategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create model from JSON
  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MenuCategoryModel(id: $id, name: $name, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuCategoryModel &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.image == image &&
        other.sortOrder == sortOrder &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      image,
      sortOrder,
      isActive,
      createdAt,
      updatedAt,
    );
  }
}
