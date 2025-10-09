import 'package:flutter/material.dart';

/// Design tokens for Checkout screen - matches React prototype exactly
class CheckoutConstants {
  // ============================================================================
  // BREAKPOINTS
  // ============================================================================
  static const double breakpointCompact = 900;
  static const double breakpointMedium = 901;
  static const double breakpointLarge = 1280;

  // ============================================================================
  // COLUMN WIDTHS
  // ============================================================================
  // Left column (Order Items)
  static const double leftWidthMedium = 320;
  static const double leftWidthLarge = 360;

  // Right column (Payment Options & Actions)
  static const double rightWidth = 320;

  // Middle column is flexible (≈ 420-520dp at 1366x768)

  // ============================================================================
  // SPACING
  // ============================================================================
  static const double pageHorizontal = 16;
  static const double pageVertical = 16;

  static const double cardPadding = 12;
  static const double cardInnerPadding = 8;

  static const double gapCompact = 8;
  static const double gapMedium = 12;

  static const double gapTiny = 4;
  static const double gapSmall = 8;
  static const double gapNormal = 12;
  static const double gapLarge = 16;

  // ============================================================================
  // HEIGHTS
  // ============================================================================
  static const double tabHeight = 48;
  static const double methodTileHeight = 76;
  static const double quickAmountHeight = 38;
  static const double inputHeight = 56;
  static const double keySize = 64;
  static const double keypadGap = 8;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================
  static const double radiusCard = 12;
  static const double radiusButton = 10;
  static const double radiusChip = 20;
  static const double radiusInput = 10;

  // ============================================================================
  // COLORS
  // ============================================================================
  // Primary (Blue)
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFFE3F2FD);

  // Success (Green)
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);

  // Error (Red)
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);

  // Warning (Orange)
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);

  // Neutral
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color border = Color(0xFFE5E7EB);
  static const Color borderHover = Color(0xFFD1D5DB);
  static const Color borderSelected = Color(0xFF2196F3);

  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceHover = Color(0xFFF3F4F6);

  // ============================================================================
  // TYPOGRAPHY
  // ============================================================================
  static const double fontSizeTitle = 16;
  static const double fontSizeLabel = 13;
  static const double fontSizeValue = 18;
  static const double fontSizeBody = 14;
  static const double fontSizeSmall = 12;
  static const double fontSizeLarge = 20;

  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;

  // ============================================================================
  // SHADOWS
  // ============================================================================
  static List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowSelected = [
    BoxShadow(
      color: primary.withValues(alpha: 0.12),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // ============================================================================
  // TEXT STYLES
  // ============================================================================
  static const TextStyle textTitle = TextStyle(
    fontSize: fontSizeTitle,
    fontWeight: weightSemiBold,
    color: textPrimary,
  );

  static const TextStyle textLabel = TextStyle(
    fontSize: fontSizeLabel,
    fontWeight: weightMedium,
    color: textSecondary,
  );

  static const TextStyle textValue = TextStyle(
    fontSize: fontSizeValue,
    fontWeight: weightSemiBold,
    color: textPrimary,
  );

  static const TextStyle textBody = TextStyle(
    fontSize: fontSizeBody,
    fontWeight: weightRegular,
    color: textPrimary,
  );

  static const TextStyle textMutedSmall = TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: weightRegular,
    color: textMuted,
  );

  // ============================================================================
  // HELPERS
  // ============================================================================
  static double getLeftWidth(double screenWidth) {
    if (screenWidth < breakpointMedium) return 0; // Drawer mode
    if (screenWidth < breakpointLarge) return leftWidthMedium;
    return leftWidthLarge;
  }

  static double getGap(double screenWidth) {
    return screenWidth < breakpointMedium ? gapCompact : gapMedium;
  }

  static bool isCompact(double screenWidth) => screenWidth < breakpointMedium;
  static bool isMedium(double screenWidth) =>
      screenWidth >= breakpointMedium && screenWidth < breakpointLarge;
  static bool isLarge(double screenWidth) => screenWidth >= breakpointLarge;
}
