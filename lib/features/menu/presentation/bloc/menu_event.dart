import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/menu_category_entity.dart';

/// Menu Events
abstract class MenuEvent extends BaseEvent {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

class GetMenuCategoriesEvent extends MenuEvent {
  const GetMenuCategoriesEvent();

  @override
  List<Object?> get props => [];
}

class GetMenuItemsEvent extends MenuEvent {
  const GetMenuItemsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenuData extends MenuEvent {
  const LoadMenuData();

  @override
  List<Object?> get props => [];
}

class RefreshMenuData extends MenuEvent {
  const RefreshMenuData();

  @override
  List<Object?> get props => [];
}

class SearchMenuItems extends MenuEvent {
  final String query;

  const SearchMenuItems({required this.query});

  @override
  List<Object?> get props => [query];
}

class FilterByCategory extends MenuEvent {
  final MenuCategoryEntity category;

  const FilterByCategory({required this.category});

  @override
  List<Object?> get props => [category];
}

class ClearFilters extends MenuEvent {
  const ClearFilters();

  @override
  List<Object?> get props => [];
}
