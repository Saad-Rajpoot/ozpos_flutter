import 'package:flutter/material.dart';

/// Design system tokens matching the React app exactly
class AppColors {
  // Primary colors
  static const primary = Color(0xFF3B82F6); // blue-500
  static const primaryDark = Color(0xFF1E40AF); // blue-800
  static const primaryLight = Color(0xFF60A5FA); // blue-400

  // Tile gradient colors - exact hex values from reference image
  static const tileTakeaway = Color(0xFFF97316); // orange-500
  static const tileTakeawayEnd = Color(0xFFF59E0B); // amber-500

  static const tileDineIn = Color(0xFF10B981); // emerald-500
  static const tileDineInEnd = Color(0xFF059669); // emerald-600

  static const tileTables = Color(0xFF3B82F6); // blue-500
  static const tileTablesEnd = Color(0xFF2563EB); // blue-600

  static const tileDelivery = Color(0xFFA855F7); // purple-500
  static const tileDeliveryEnd = Color(0xFFC026D3); // fuchsia-600

  static const tileReservations = Color(0xFF22C55E); // green-500
  static const tileReservationsEnd = Color(0xFF10B981); // emerald-500

  static const tileEditMenu = Color(0xFF6366F1); // indigo-500
  static const tileEditMenuEnd = Color(0xFF8B5CF6); // violet-500

  static const tileReports = Color(0xFFEC4899); // pink-500
  static const tileReportsEnd = Color(0xFFF43F5E); // rose-500

  static const tileSettings = Color(0xFF64748B); // slate-500
  static const tileSettingsEnd = Color(0xFF475569); // slate-600

  // Background colors - exact from reference
  static const bgPrimary = Color(0xFFF9FAFB); // gray-50
  static const bgSecondary = Colors.white;
  static const bgGradientStart = Color(0xFFF9FAFB);
  static const bgGradientMid = Color(0xFFF3F4F6);
  static const bgGradientEnd = Color(0xFFF9FAFB);

  // Sidebar - dark slate from reference
  static const sidebarBg = Color(0xFF1E293B); // slate-800
  static const sidebarText = Color(0xFFF1F5F9); // slate-100
  static const sidebarTextMuted = Color(0xFF94A3B8); // slate-400
  static const sidebarItemHover = Color(0xFF334155); // slate-700
  static const sidebarItemActive = Color(0xFF3B82F6); // blue-500

  // Text colors
  static const textPrimary = Color(0xFF111827); // gray-900
  static const textSecondary = Color(0xFF6B7280); // gray-500
  static const textTertiary = Color(0xFF9CA3AF); // gray-400
  static const textWhite = Colors.white;
  static const textMuted = Color(0xFFE5E5E5);
  static const textOnPrimary = Colors.white;

  // Border colors
  static const borderLight = Color(0xFFE5E7EB); // gray-200
  static const borderMedium = Color(0xFFD1D5DB); // gray-300

  // Status colors for orders
  static const statusPending = Color(0xFFF59E0B); // amber-500
  static const statusPendingBg = Color(0xFFFEF3C7); // yellow-100
  static const statusPendingText = Color(0xFF854D0E); // yellow-800

  static const statusReady = Color(0xFF10B981); // green-500
  static const statusReadyBg = Color(0xFFDCFCE7); // green-100
  static const statusReadyText = Color(0xFF166534); // green-800

  static const statusUnpaid = Color(0xFFEF4444); // red-500
  static const statusUnpaidBg = Color(0xFFFEE2E2); // red-100
  static const statusUnpaidText = Color(0xFF991B1B); // red-800

  // Order type colors for cards
  static const orderTakeawayBorder = Color(0xFFFDBA74); // orange-300
  static const orderTakeawayBgStart = Color(
    0xFFFED7AA,
  ); // orange-50 with 50% opacity
  static const orderTakeawayBgEnd = Color(
    0xFFFEF3C7,
  ); // amber-50 with 30% opacity

  static const orderDineInBorder = Color(0xFF86EFAC); // green-300
  static const orderDineInBgStart = Color(
    0xFFDCFCE7,
  ); // green-50 with 50% opacity
  static const orderDineInBgEnd = Color(
    0xFFD1FAE5,
  ); // emerald-50 with 30% opacity

  static const orderTableBorder = Color(0xFF93C5FD); // blue-300
  static const orderTableBgStart = Color(
    0xFFDBEAFE,
  ); // blue-50 with 50% opacity
  static const orderTableBgEnd = Color(0xFFE0F2FE); // cyan-50 with 30% opacity

  static const orderDeliveryBorder = Color(0xFFD8B4FE); // purple-300
  static const orderDeliveryBgStart = Color(
    0xFFEDE9FE,
  ); // purple-50 with 50% opacity
  static const orderDeliveryBgEnd = Color(
    0xFFFAF5FF,
  ); // fuchsia-50 with 30% opacity

  // Additional UI colors
  static const error = Color(0xFFEF4444); // red-500
  static const warning = Color(0xFFF59E0B); // amber-500
  static const success = Color(0xFF10B981); // green-500
  static const info = Color(0xFF3B82F6); // blue-500
}

class AppSpacing {
  // Base unit = 8dp
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Specific measurements from React app
  static const double pageHorizontalPaddingCompact = 24.0;
  static const double pageHorizontalPaddingLarge = 32.0;
  static const double gridGap = 24.0;
  static const double sectionHeaderMargin = 8.0;
  static const double sidebarItemPaddingV = 12.0;
  static const double sidebarItemPaddingH = 16.0;
  static const double cardPadding = 16.0;
  static const double tilePadding = 24.0;
  static const double orderCardGap = 12.0;
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;

  // Specific radii from React app
  static const double tile = 16.0;
  static const double orderCard = 12.0;
  static const double chip = 8.0;
  static const double button = 12.0;
  static const double input = 8.0;
  static const double iconContainer = 12.0;
}

class AppSizes {
  // Fixed dimensions - exact from spec
  static const double sidebarWidth = 80.0; // Icon-only sidebar
  static const double sidebarWidthExpanded = 240.0;
  static const double appBarHeight = 64.0;
  static const double rightPanelWidth = 360.0; // Fixed on desktop
  static const double rightPanelWidthMedium = 320.0; // Medium breakpoint
  static const double maxContentWidth = 1440.0;
  static const double searchFieldHeight = 40.0; // From reference

  // Breakpoints - spec requirements
  static const double breakpointCompact = 900.0; // ≤900: tablet portrait
  static const double breakpointMedium = 901.0; // 901-1279: tablet landscape
  static const double breakpointLarge = 1280.0; // ≥1280: desktop
  static const double breakpointWide = 1600.0; // ≥1600: ultra-wide

  // Legacy breakpoints for compatibility
  static const double breakpointMd = 900.0;
  static const double breakpointLg = 1280.0;
  static const double breakpointXl = 1600.0;

  // Grid dimensions - exact from spec
  static const double tileMinWidth = 240.0;
  static const double tileAspectRatio = 1.45; // Wider than tall (spec)

  // Icon sizes - from reference
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconBase = 24.0;
  static const double iconLg = 28.0;
  static const double iconXl = 32.0;
  static const double iconTile = 28.0; // 28dp from spec
  static const double iconContainer = 48.0; // Icon container 48dp
  static const double iconOrderCard = 24.0; // Order card icons

  // Touch targets
  static const double minTouchTarget = 44.0; // iOS minimum
  static const double minTouchTargetAndroid = 48.0;
}

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

class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get tileShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 32,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 40,
      offset: const Offset(0, 12),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> get hoverShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 48,
      offset: const Offset(0, 16),
      spreadRadius: -8,
    ),
  ];

  static List<BoxShadow> get button => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
}

// Breakpoint definitions
class Breakpoints {
  static const double compact = 900; // ≤ 900dp: tablet portrait (8-10")
  static const double medium =
      1280; // 901-1279dp: tablet landscape / small desktop
  static const double large = 1280; // ≥ 1280dp: desktop 15-20"
  static const double wide = 1600; // ≥ 1600dp: ultra-wide monitors
}

// Grid columns by breakpoint
class GridColumns {
  static const int compact = 2; // Mobile/tablet portrait
  static const int medium = 3; // Tablet landscape
  static const int large = 4; // Desktop
  static const int wide = 4; // Ultra-wide (same columns, more padding)
}

// Token aliases for backwards compatibility with modals
class TokenColors {
  // Primary colors
  static const emerald500 = Color(0xFF10B981);
  static const emerald600 = Color(0xFF059669);
  static const emerald50 = Color(0xFFECFDF5);

  static const orange500 = Color(0xFFF97316);
  static const orange600 = Color(0xFFEA580C);
  static const orange700 = Color(0xFFC2410C);
  static const orange50 = Color(0xFFFFF7ED);
  static const orange200 = Color(0xFFFED7AA);
  static const orange300 = Color(0xFFFDBA74);

  static const blue500 = Color(0xFF3B82F6);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue50 = Color(0xFFEFF6FF);

  static const cyan500 = Color(0xFF06B6D4);

  static const purple500 = Color(0xFFA855F7);
  static const purple600 = Color(0xFF9333EA);
  static const purple700 = Color(0xFF7E22CE);
  static const purple50 = Color(0xFFFAF5FF);
  static const purple200 = Color(0xFFE9D5FF);
  static const fuchsia500 = Color(0xFFD946EF);

  static const red500 = Color(0xFFEF4444);
  static const red50 = Color(0xFFFEF2F2);

  static const yellow500 = Color(0xFFEAB308);
  static const yellow50 = Color(0xFFFEFCE8);

  static const amber200 = Color(0xFFFDE68A);
  static const amber300 = Color(0xFFFCD34D);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const amber50 = Color(0xFFFFFBEB);

  // Grays
  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray700 = Color(0xFF374151);
  static const gray800 = Color(0xFF1F2937);
  static const gray900 = Color(0xFF111827);
}

class TokenRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

class TokenSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}
