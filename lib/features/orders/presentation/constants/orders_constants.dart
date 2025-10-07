import 'package:flutter/material.dart';

/// Design tokens for Orders screen - exact match to React prototype
class OrdersConstants {
  // Breakpoints (dp)
  static const double breakpointMobile = 900.0;
  static const double breakpointTablet = 1279.0;
  static const double breakpointDesktop = 1599.0;
  static const double maxContentWidth = 1440.0;

  // Border Radius
  static const double cardRadius = 16.0;
  static const double chipRadius = 20.0;
  static const double buttonRadiusSm = 10.0;
  static const double buttonRadiusMd = 12.0;

  // Spacing
  static const double gapBetweenCards = 12.0;
  static const double gapInsideCard = 8.0;
  static const double gapSmall = 10.0;
  static const double paddingCard = 16.0;
  static const double paddingHeader = 24.0;

  // Shadows
  static List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadowCardHover = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Platform/Channel Colors (matching React)
  static const Color colorUberEatsStart = Color(0xFF10B981);
  static const Color colorUberEatsEnd = Color(0xFF059669);
  static const Color colorUberEatsText = Color(0xFF065F46);
  static const Color colorUberEatsBg = Color(0xFFD1FAE5);
  static const Color colorUberEatsBorder = Color(0xFF6EE7B7);

  static const Color colorDoorDashStart = Color(0xFFEF4444);
  static const Color colorDoorDashEnd = Color(0xFFDC2626);
  static const Color colorDoorDashText = Color(0xFF991B1B);
  static const Color colorDoorDashBg = Color(0xFFFEE2E2);
  static const Color colorDoorDashBorder = Color(0xFFFCA5A5);

  static const Color colorMenulogStart = Color(0xFFF97316);
  static const Color colorMenulogEnd = Color(0xFFEA580C);
  static const Color colorMenulogText = Color(0xFF9A3412);
  static const Color colorMenulogBg = Color(0xFFFFEDD5);
  static const Color colorMenulogBorder = Color(0xFFFBBF24);

  static const Color colorWebsiteStart = Color(0xFF3B82F6);
  static const Color colorWebsiteEnd = Color(0xFF2563EB);
  static const Color colorWebsiteText = Color(0xFF1E40AF);
  static const Color colorWebsiteBg = Color(0xFFDBEAFE);
  static const Color colorWebsiteBorder = Color(0xFF93C5FD);

  static const Color colorAppStart = Color(0xFFA855F7);
  static const Color colorAppEnd = Color(0xFF9333EA);
  static const Color colorAppText = Color(0xFF6B21A8);
  static const Color colorAppBg = Color(0xFFF3E8FF);
  static const Color colorAppBorder = Color(0xFFD8B4FE);

  static const Color colorQrStart = Color(0xFF6B7280);
  static const Color colorQrEnd = Color(0xFF4B5563);
  static const Color colorQrText = Color(0xFF374151);
  static const Color colorQrBg = Color(0xFFF3F4F6);
  static const Color colorQrBorder = Color(0xFFD1D5DB);

  static const Color colorDineInStart = Color(0xFF6366F1);
  static const Color colorDineInEnd = Color(0xFF4F46E5);
  static const Color colorDineInText = Color(0xFF3730A3);
  static const Color colorDineInBg = Color(0xFFE0E7FF);
  static const Color colorDineInBorder = Color(0xFFA5B4FC);

  static const Color colorTakeawayStart = Color(0xFFEAB308);
  static const Color colorTakeawayEnd = Color(0xFFCA8A04);
  static const Color colorTakeawayText = Color(0xFF854D0E);
  static const Color colorTakeawayBg = Color(0xFFFEF3C7);
  static const Color colorTakeawayBorder = Color(0xFFFDE047);

  // Status Badge Colors (matching React)
  static const Color colorStatusActiveStart = Color(0xFF3B82F6);
  static const Color colorStatusActiveEnd = Color(0xFF06B6D4);
  static const Color colorStatusActiveText = Color(0xFF1E40AF);
  static const Color colorStatusActiveBg = Color(0xFFDBEAFE);
  static const Color colorStatusActiveBorder = Color(0xFF93C5FD);

  static const Color colorStatusCompletedStart = Color(0xFF10B981);
  static const Color colorStatusCompletedEnd = Color(0xFF059669);
  static const Color colorStatusCompletedText = Color(0xFF065F46);
  static const Color colorStatusCompletedBg = Color(0xFFD1FAE5);
  static const Color colorStatusCompletedBorder = Color(0xFF6EE7B7);

  static const Color colorStatusCancelledStart = Color(0xFFEF4444);
  static const Color colorStatusCancelledEnd = Color(0xFFDC2626);
  static const Color colorStatusCancelledText = Color(0xFF991B1B);
  static const Color colorStatusCancelledBg = Color(0xFFFEE2E2);
  static const Color colorStatusCancelledBorder = Color(0xFFFCA5A5);

  static const Color colorStatusUnpaidStart = Color(0xFFF97316);
  static const Color colorStatusUnpaidEnd = Color(0xFFEA580C);
  static const Color colorStatusUnpaidText = Color(0xFF9A3412);
  static const Color colorStatusUnpaidBg = Color(0xFFFFEDD5);
  static const Color colorStatusUnpaidBorder = Color(0xFFFBBF24);

  // KPI Card Colors (matching React)
  static const Color colorKpiActiveStart = Color(0xFF3B82F6);
  static const Color colorKpiActiveEnd = Color(0xFF06B6D4);

  static const Color colorKpiCompletedStart = Color(0xFF10B981);
  static const Color colorKpiCompletedEnd = Color(0xFF059669);

  static const Color colorKpiCancelledStart = Color(0xFFEF4444);
  static const Color colorKpiCancelledEnd = Color(0xFFF43F5E);

  static const Color colorKpiRevenueStart = Color(0xFFA855F7);
  static const Color colorKpiRevenueEnd = Color(0xFFD946EF);

  // Action Button Colors
  static const Color colorActionCooking = Color(0xFFF97316);
  static const Color colorActionReady = Color(0xFF10B981);
  static const Color colorActionDispatch = Color(0xFFA855F7);
  static const Color colorActionPay = Color(0xFF3B82F6);
  static const Color colorActionCancel = Color(0xFFEF4444);

  // Neutral Colors
  static const Color colorTotalBarBg = Color(0xFF1E293B);
  static const Color colorTotalBarText = Color(0xFFFFFFFF);
  static const Color colorBorder = Color(0xFFE5E7EB);
  static const Color colorDivider = Color(0xFFF3F4F6);
  static const Color colorBgLight = Color(0xFFF9FAFB);
  static const Color colorBgSecondary = Color(0xFFF3F4F6);
  static const Color colorTextPrimary = Color(0xFF111827);
  static const Color colorTextSecondary = Color(0xFF6B7280);
  static const Color colorTextMuted = Color(0xFF9CA3AF);

  // Typography
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.5,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: 0.5,
  );
}
