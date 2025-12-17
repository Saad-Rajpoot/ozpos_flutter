import '../../domain/entities/settings_entities.dart';

/// Data source interface for Settings
abstract class SettingsDataSource {
  Future<List<SettingsCategoryEntity>> getCategories();
}
