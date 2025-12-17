import 'package:flutter/material.dart';

class DeliveryConstants {
  // Colors
  static const background = Color(0xFFF5F5F7);
  static const cardBackground = Colors.white;

  // KPI gradients
  static const kpiActiveDriversStart = Color(0xFF10B981);
  static const kpiActiveDriversEnd = Color(0xFF059669);

  static const kpiInProgressStart = Color(0xFF3B82F6);
  static const kpiInProgressEnd = Color(0xFF2563EB);

  static const kpiDelayedStart = Color(0xFFEF4444);
  static const kpiDelayedEnd = Color(0xFFDC2626);

  static const kpiAvgEtaStart = Color(0xFFA855F7);
  static const kpiAvgEtaEnd = Color(0xFF9333EA);

  // Status colors
  static const statusOnline = Color(0xFF10B981);
  static const statusBusy = Color(0xFFF59E0B);
  static const statusOffline = Color(0xFF9CA3AF);

  static const statusReady = Color(0xFFF97316);
  static const statusDelayed = Color(0xFFEF4444);
  static const statusInProgress = Color(0xFF3B82F6);

  // Channel colors
  static const channelWebsite = Color(0xFF3B82F6);
  static const channelUberEats = Color(0xFF10B981);
  static const channelDoorDash = Color(0xFFEF4444);
  static const channelApp = Color(0xFF8B5CF6);
  static const channelQr = Color(0xFFF59E0B);
  static const channelPhone = Color(0xFF6366F1);

  // Text colors
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);

  // Border & dividers
  static const borderColor = Color(0xFFE5E7EB);
  static const dividerColor = Color(0xFFF3F4F6);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;
  static const double spacing2xl = 32.0;

  // Border radius
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusFull = 999.0;

  // Card dimensions
  static const double cardPadding = 14.0;
  static const double kpiHeight = 100.0;
  static const double driverCardHeight = 180.0;

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardShadowHover = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Typography
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.2,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    height: 1.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    height: 1.2,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textTertiary,
    height: 1.3,
  );

  // KPI value style
  static const TextStyle kpiValue = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.0,
  );

  static const TextStyle kpiLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );
}
