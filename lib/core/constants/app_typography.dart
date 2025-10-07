import 'package:flutter/material.dart';

class AppTypography {
  // Font sizes - Material 3 scale
  static const double displayLarge = 32.0; // Not used in dashboard
  static const double displayMedium = 28.0; // Dashboard header
  static const double displaySmall = 24.0; // Not used in dashboard
  static const double headlineLarge = 24.0; // Not used
  static const double headlineMedium = 20.0; // Section headers
  static const double headlineSmall = 18.0; // Tile titles
  static const double titleLarge = 18.0; // Card titles
  static const double titleMedium = 16.0; // Subtitles
  static const double titleSmall = 14.0; // Labels
  static const double labelLarge = 14.0; // Button text
  static const double labelMedium = 13.0; // Tile descriptions
  static const double labelSmall = 12.0; // Small labels
  static const double bodyLarge = 16.0; // Body text
  static const double bodyMedium = 14.0; // Regular text
  static const double bodySmall = 12.0; // Captions

  // Font weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Text styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle heading5 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle heading6 = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
}
