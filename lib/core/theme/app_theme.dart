import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.bgPrimary,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgSecondary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgSecondary,
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.heading1,
        displayMedium: AppTypography.heading2,
        displaySmall: AppTypography.heading3,
        headlineLarge: AppTypography.heading1,
        headlineMedium: AppTypography.heading2,
        headlineSmall: AppTypography.heading3,
        titleLarge: AppTypography.heading2,
        titleMedium: AppTypography.heading3,
        titleSmall: AppTypography.body1,
        bodyLarge: AppTypography.body1,
        bodyMedium: AppTypography.body2,
        bodySmall: AppTypography.caption,
        labelLarge: AppTypography.button,
        labelMedium: AppTypography.overline,
        labelSmall: AppTypography.caption,
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.heading1.copyWith(
          color: colorScheme.onSurface,
        ),
        displayMedium: AppTypography.heading2.copyWith(
          color: colorScheme.onSurface,
        ),
        displaySmall: AppTypography.heading3.copyWith(
          color: colorScheme.onSurface,
        ),
        headlineLarge: AppTypography.heading1.copyWith(
          color: colorScheme.onSurface,
        ),
        headlineMedium: AppTypography.heading2.copyWith(
          color: colorScheme.onSurface,
        ),
        headlineSmall: AppTypography.heading3.copyWith(
          color: colorScheme.onSurface,
        ),
        titleLarge: AppTypography.heading2.copyWith(
          color: colorScheme.onSurface,
        ),
        titleMedium: AppTypography.heading3.copyWith(
          color: colorScheme.onSurface,
        ),
        titleSmall: AppTypography.body1.copyWith(
          color: colorScheme.onSurface,
        ),
        bodyLarge: AppTypography.body1.copyWith(
          color: colorScheme.onSurface,
        ),
        bodyMedium: AppTypography.body2.copyWith(
          color: colorScheme.onSurface,
        ),
        bodySmall: AppTypography.caption.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelLarge: AppTypography.button.copyWith(
          color: AppColors.textOnPrimary,
        ),
        labelMedium: AppTypography.overline.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelSmall: AppTypography.caption.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
