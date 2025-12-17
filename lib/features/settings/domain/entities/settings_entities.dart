import 'package:equatable/equatable.dart';

class SettingsCategoryEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<SettingsItemEntity> items;

  const SettingsCategoryEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.items,
  });

  @override
  List<Object?> get props => [id, title, description, items];
}

class SettingsItemEntity extends Equatable {
  final String name;
  final String description;
  final String
      action; // e.g., 'printer-setup', 'docket-designer', 'menu-editor'

  const SettingsItemEntity({
    required this.name,
    required this.description,
    required this.action,
  });

  @override
  List<Object?> get props => [name, description, action];
}
