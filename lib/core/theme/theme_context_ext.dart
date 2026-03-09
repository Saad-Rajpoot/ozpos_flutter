import 'package:flutter/material.dart';

/// Small helpers so UI can read theme colors consistently.
extension ThemeContextX on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Primary screen background (follows current theme mode).
  Color get bgPrimary => Theme.of(this).scaffoldBackgroundColor;

  /// Surface color for cards/panels.
  Color get bgSurface => colorScheme.surface;

  /// Border/divider color.
  Color get borderLight => Theme.of(this).dividerColor;

  Color get textPrimary => colorScheme.onSurface;
  Color get textSecondary => colorScheme.onSurfaceVariant;
}

