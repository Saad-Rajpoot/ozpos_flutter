import 'menu_category_entity.dart';
import 'menu_item_entity.dart';
import 'menu_schedule_entry.dart';

/// Lightweight header information for each menu variant (e.g. multiple
/// delivery menus with different schedules).
class MenuVariantHeader {
  final String id;
  final String name;
  final String? subtitle;
  final String? menuType;
  final String? scheduleTimeRange;
  /// Per-day opening hours for this specific menu variant, ordered with
  /// today first (same shape as [SingleVendorMenuEntity.openingHours]).
  final List<MenuScheduleEntry> openingHours;

  const MenuVariantHeader({
    required this.id,
    required this.name,
    this.subtitle,
    this.menuType,
    this.scheduleTimeRange,
    this.openingHours = const [],
  });
}

/// Domain entity representing menu data from single-vendor API
/// Maps from data.branch.menuV2 → categories → items
/// Includes active menu by schedule/timezone and display time range.
class SingleVendorMenuEntity {
  final String menuName;
  final List<MenuCategoryEntity> categories;
  final List<MenuItemEntity> items;
  /// Unique id for the active menu (for cart invalidation when menu changes).
  final String? activeMenuId;
  /// Human-readable time range for the active menu, e.g. "4:00 PM - 11:59 PM".
  final String? scheduleTimeRange;
  /// Branch timezone, e.g. "Australia/Sydney".
  final String? timezone;
  /// Active menu subtitle from API.
  final String? menuSubtitle;
  /// Active menu version from API.
  final int? menuVersion;
  /// Active menu type from API, e.g. "delivery", "pickup".
  final String? menuType;
  /// Opening hours per day (ordered with today first), for menu details dialog.
  final List<MenuScheduleEntry> openingHours;
  /// All menu variants for the currently selected type (e.g. all delivery menus).
  /// Used to show multiple menus (with their timings) in the header UI.
  final List<MenuVariantHeader> variants;
  /// Seconds from "now in branch timezone" until the next menu schedule
  /// boundary (start or end) for this menu type. Used by the UI to schedule
  /// a one-shot refresh without polling.
  final int? secondsUntilNextScheduleChange;

  const SingleVendorMenuEntity({
    required this.menuName,
    required this.categories,
    required this.items,
    this.activeMenuId,
    this.scheduleTimeRange,
    this.timezone,
    this.menuSubtitle,
    this.menuVersion,
    this.menuType,
    this.openingHours = const [],
    this.variants = const [],
    this.secondsUntilNextScheduleChange,
  });
}
