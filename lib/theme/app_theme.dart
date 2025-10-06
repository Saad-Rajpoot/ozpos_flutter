import 'package:flutter/material.dart';
import 'tokens.dart';

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
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
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
        displayLarge: AppTypography.heading1.copyWith(color: AppColors.textPrimary),
        displayMedium: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
        displaySmall: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
        headlineLarge: AppTypography.heading1.copyWith(color: AppColors.textPrimary),
        headlineMedium: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
        headlineSmall: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
        titleLarge: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
        titleMedium: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
        titleSmall: AppTypography.body1.copyWith(color: AppColors.textPrimary),
        bodyLarge: AppTypography.body1.copyWith(color: AppColors.textPrimary),
        bodyMedium: AppTypography.body2.copyWith(color: AppColors.textPrimary),
        bodySmall: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        labelLarge: AppTypography.button.copyWith(color: AppColors.textOnPrimary),
        labelMedium: AppTypography.overline.copyWith(color: AppColors.textSecondary),
        labelSmall: AppTypography.caption.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}