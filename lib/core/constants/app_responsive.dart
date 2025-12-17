import 'package:flutter/material.dart';
import 'app_sizes.dart';
import 'app_spacing.dart';

/// Breakpoint categories matching spec:
/// compact: ≤900dp (tablet portrait 8-10")
/// medium: 901-1279dp (tablet landscape / small desktop)
/// large: ≥1280dp (desktop 15-20")
/// wide: ≥1600dp (ultra-wide, same columns but more padding)
enum ResponsiveSize { compact, medium, large, wide }

extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  ResponsiveSize get responsiveSize {
    final width = screenWidth;
    if (width >= AppSizes.breakpointWide) return ResponsiveSize.wide;
    if (width >= AppSizes.breakpointLarge) return ResponsiveSize.large;
    if (width > AppSizes.breakpointCompact) return ResponsiveSize.medium;
    return ResponsiveSize.compact;
  }

  // Exact breakpoint checks
  bool get isCompact => screenWidth <= AppSizes.breakpointCompact;
  bool get isMedium =>
      screenWidth > AppSizes.breakpointCompact &&
      screenWidth < AppSizes.breakpointLarge;
  bool get isLarge =>
      screenWidth >= AppSizes.breakpointLarge &&
      screenWidth < AppSizes.breakpointWide;
  bool get isWide => screenWidth >= AppSizes.breakpointWide;

  // Convenience getters
  bool get isTabletOrLarger => screenWidth > AppSizes.breakpointCompact;
  bool get isDesktopOrLarger => screenWidth >= AppSizes.breakpointLarge;
  bool get isLargeDesktop => screenWidth >= AppSizes.breakpointLarge;

  // Grid columns by breakpoint
  int get gridColumns {
    if (isCompact) return 2;
    if (isMedium) return 3;
    return 4; // large and wide both use 4 columns
  }

  // Padding by breakpoint
  double get pageHorizontalPadding {
    if (isWide) return AppSpacing.pageHorizontalPaddingLarge;
    if (isLarge) return AppSpacing.pageHorizontalPaddingLarge;
    return AppSpacing.pageHorizontalPaddingCompact;
  }

  // Right panel width
  double get rightPanelWidth {
    if (isLarge || isWide) return AppSizes.rightPanelWidth;
    if (isMedium) return AppSizes.rightPanelWidthMedium;
    return 0; // Hidden on compact
  }

  // Should show right panel as fixed (vs drawer)
  bool get showRightPanelFixed => isDesktopOrLarger;

  // Should show right panel toggle button
  bool get showRightPanelToggle => isTabletOrLarger;
}

/// Clamp text scaling to prevent layout breakage
/// Spec: clamp between 1.0 and 1.1 for deterministic sizing
class ClampedTextScaling extends StatelessWidget {
  final Widget child;
  final double minScale;
  final double maxScale;

  const ClampedTextScaling({
    super.key,
    required this.child,
    this.minScale = 1.0, // Spec: minimum 1.0
    this.maxScale = 1.1, // Spec: maximum 1.1
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final clampedScale = textScaler.scale(1.0).clamp(minScale, maxScale);

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: TextScaler.linear(clampedScale)),
      child: child,
    );
  }
}
