import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Centralized light and dark themes for the app.
/// Use with MaterialApp.theme, MaterialApp.darkTheme, and MaterialApp.themeMode.
class AppThemes {
  AppThemes._();

  static ThemeData get lightTheme => AppTheme.lightTheme;
  static ThemeData get darkTheme => AppTheme.darkTheme;
}
