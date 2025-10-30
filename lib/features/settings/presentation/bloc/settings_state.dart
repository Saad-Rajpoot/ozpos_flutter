import '../../domain/entities/settings_entities.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final List<SettingsCategoryEntity> categories;
  SettingsLoaded(this.categories);
}

class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
}
