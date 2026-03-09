import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/menu_schedule_entry.dart';
import '../../domain/entities/single_vendor_menu_entity.dart';

/// Menu States
abstract class MenuState extends BaseState {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {
  const MenuInitial();

  @override
  List<Object?> get props => [];
}

class MenuLoading extends MenuState {
  const MenuLoading();

  @override
  List<Object?> get props => [];
}

class MenuLoaded extends MenuState {
  final String? menuName;
  final List<MenuCategoryEntity> categories;
  final List<MenuItemEntity> items;
  final List<MenuItemEntity>? filteredItems;
  final MenuCategoryEntity? selectedCategory;
  final String? searchQuery;
  /// Unique id for the active menu (for cart invalidation when menu changes).
  final String? activeMenuId;
  /// Human-readable time range, e.g. "4:00 PM - 11:59 PM".
  final String? scheduleTimeRange;
  /// Branch timezone from API, e.g. "Australia/Sydney".
  final String? timezone;
  final String? menuSubtitle;
  final int? menuVersion;
  final String? menuType;
  final List<MenuScheduleEntry> openingHours;
  final List<MenuVariantHeader> variants;
  final int? secondsUntilNextScheduleChange;

  const MenuLoaded({
    this.menuName,
    required this.categories,
    required this.items,
    this.filteredItems,
    this.selectedCategory,
    this.searchQuery,
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

  @override
  List<Object?> get props => [
        menuName,
        categories,
        items,
        filteredItems,
        selectedCategory,
        searchQuery,
        activeMenuId,
        scheduleTimeRange,
        timezone,
        menuSubtitle,
        menuVersion,
        menuType,
        openingHours,
        variants,
        secondsUntilNextScheduleChange,
      ];

  MenuLoaded copyWith({
    String? menuName,
    List<MenuCategoryEntity>? categories,
    List<MenuItemEntity>? items,
    List<MenuItemEntity>? filteredItems,
    MenuCategoryEntity? selectedCategory,
    String? searchQuery,
    String? activeMenuId,
    String? scheduleTimeRange,
    String? timezone,
    String? menuSubtitle,
    int? menuVersion,
    String? menuType,
    List<MenuScheduleEntry>? openingHours,
    List<MenuVariantHeader>? variants,
    int? secondsUntilNextScheduleChange,
  }) {
    return MenuLoaded(
      menuName: menuName ?? this.menuName,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      filteredItems: filteredItems,
      selectedCategory: selectedCategory,
      searchQuery: searchQuery,
      activeMenuId: activeMenuId ?? this.activeMenuId,
      scheduleTimeRange: scheduleTimeRange ?? this.scheduleTimeRange,
      timezone: timezone ?? this.timezone,
      menuSubtitle: menuSubtitle ?? this.menuSubtitle,
      menuVersion: menuVersion ?? this.menuVersion,
      menuType: menuType ?? this.menuType,
      openingHours: openingHours ?? this.openingHours,
      variants: variants ?? this.variants,
      secondsUntilNextScheduleChange:
          secondsUntilNextScheduleChange ?? this.secondsUntilNextScheduleChange,
    );
  }
}

class MenuError extends MenuState {
  final String message;

  const MenuError({required this.message});

  @override
  List<Object?> get props => [message];
}

class MenuEmpty extends MenuState {
  const MenuEmpty();

  @override
  List<Object?> get props => [];
}
