import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/menu_category_entity.dart';

part 'menu_category_model.freezed.dart';
part 'menu_category_model.g.dart';

/// Menu category model
@freezed
class MenuCategoryModel with _$MenuCategoryModel {
  const factory MenuCategoryModel({
    required String id,
    required String name,
    String? description,
    String? image,
    @Default(0) @JsonKey(name: 'sort_order') int sortOrder,
    @Default(true) @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _MenuCategoryModel;

  const MenuCategoryModel._();

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

  /// Create model from JSON
  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$$MenuCategoryModelImplFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() =>
      _$$MenuCategoryModelImplToJson(this as _$MenuCategoryModelImpl);
}
