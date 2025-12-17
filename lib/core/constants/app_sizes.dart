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
