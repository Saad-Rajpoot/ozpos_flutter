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
