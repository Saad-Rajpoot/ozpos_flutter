import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';

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
  final List<MenuCategoryEntity> categories;
  final List<MenuItemEntity> items;
  final List<MenuItemEntity>? filteredItems;
  final MenuCategoryEntity? selectedCategory;
  final String? searchQuery;

  const MenuLoaded({
    required this.categories,
    required this.items,
    this.filteredItems,
    this.selectedCategory,
    this.searchQuery,
  });

  @override
  List<Object?> get props =>
      [categories, items, filteredItems, selectedCategory, searchQuery];

  MenuLoaded copyWith({
    List<MenuCategoryEntity>? categories,
    List<MenuItemEntity>? items,
    List<MenuItemEntity>? filteredItems,
    MenuCategoryEntity? selectedCategory,
    String? searchQuery,
  }) {
    return MenuLoaded(
      categories: categories ?? this.categories,
      items: items ?? this.items,
      filteredItems: filteredItems,
      selectedCategory: selectedCategory,
      searchQuery: searchQuery,
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
