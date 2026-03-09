import '../entities/theme_mode_entity.dart';

/// Repository for persisting and retrieving app theme mode.
abstract class ThemeRepository {
  Future<void> setThemeMode(AppThemeMode mode);
  Future<AppThemeMode> getThemeMode();
}
