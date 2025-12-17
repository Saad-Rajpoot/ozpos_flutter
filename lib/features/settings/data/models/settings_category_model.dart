import 'package:equatable/equatable.dart';
import '../../domain/entities/settings_entities.dart';

class SettingsCategoryModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<SettingsItemEntity> items;

  const SettingsCategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.items,
  });

  factory SettingsCategoryModel.fromJson(Map<String, dynamic> json) {
    return SettingsCategoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      items: (json['items'] as List<dynamic>)
          .map((it) => SettingsItemEntity(
                name: it['name'] as String,
                description: it['description'] as String,
                action: it['action'] as String,
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'items': items
          .map((e) => {
                'name': e.name,
                'description': e.description,
                'action': e.action,
              })
          .toList(),
    };
  }

  SettingsCategoryEntity toEntity() => SettingsCategoryEntity(
        id: id,
        title: title,
        description: description,
        items: items,
      );

  @override
  List<Object?> get props => [id, title, description, items];
}
