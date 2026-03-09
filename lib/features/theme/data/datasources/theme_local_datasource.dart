import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/theme_mode_entity.dart';

const String _keyThemeMode = 'app_theme_mode';
const String _valueLight = 'light';
const String _valueDark = 'dark';

/// Local data source for persisting theme mode using SharedPreferences.
class ThemeLocalDataSource {
  final SharedPreferences _prefs;

  ThemeLocalDataSource({required SharedPreferences sharedPreferences})
      : _prefs = sharedPreferences;

  Future<void> saveThemeMode(AppThemeMode mode) async {
    await _prefs.setString(_keyThemeMode, mode == AppThemeMode.dark ? _valueDark : _valueLight);
  }

  Future<AppThemeMode> getThemeMode() async {
    final value = _prefs.getString(_keyThemeMode);
    if (value == _valueDark) return AppThemeMode.dark;
    return AppThemeMode.light;
  }
}
