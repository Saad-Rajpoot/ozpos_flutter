import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_bloc.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_menu_items.dart';
import '../../domain/usecases/get_menu_categories.dart';
import 'menu_event.dart';
import 'menu_state.dart';

/// Menu BLoC
class MenuBloc extends BaseBloc<MenuEvent, MenuState> {
  final GetMenuItems getMenuItems;
  final GetMenuCategories getMenuCategories;

  MenuBloc({required this.getMenuItems, required this.getMenuCategories})
      : super(const MenuInitial()) {
    on<GetMenuItemsEvent>(_onGetMenuItems);
    on<GetMenuCategoriesEvent>(_onGetMenuCategories);
    on<LoadMenuData>(_onLoadMenuData);
    on<RefreshMenuData>(_onRefreshMenuData);
    on<SearchMenuItems>(_onSearchMenuItems);
    on<FilterByCategory>(_onFilterByCategory);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onGetMenuItems(
    GetMenuItemsEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());
    final result = await getMenuItems(const NoParams());
    result.fold(
      (failure) => emit(MenuError(message: _mapFailureToMessage(failure))),
      (items) {
        // If categories are already loaded, combine them
        if (state is MenuLoaded) {
          final currentState = state as MenuLoaded;
          emit(currentState.copyWith(items: items));
        } else {
          emit(MenuLoaded(categories: const [], items: items));
        }
      },
    );
  }

  Future<void> _onGetMenuCategories(
    GetMenuCategoriesEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());
    final result = await getMenuCategories(const NoParams());
    result.fold(
      (failure) => emit(MenuError(message: _mapFailureToMessage(failure))),
      (categories) {
        // If items are already loaded, combine them
        if (state is MenuLoaded) {
          final currentState = state as MenuLoaded;
          emit(currentState.copyWith(categories: categories));
        } else {
          emit(MenuLoaded(categories: categories, items: const []));
        }
      },
    );
  }

  Future<void> _onLoadMenuData(
    LoadMenuData event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());

    // Load both categories and items simultaneously
    final categoriesResult = await getMenuCategories(const NoParams());
    final itemsResult = await getMenuItems(const NoParams());

    categoriesResult.fold(
      (failure) => emit(MenuError(message: _mapFailureToMessage(failure))),
      (categories) {
        itemsResult.fold(
          (failure) => emit(MenuError(message: _mapFailureToMessage(failure))),
          (items) => emit(MenuLoaded(categories: categories, items: items)),
        );
      },
    );
  }

  Future<void> _onRefreshMenuData(
    RefreshMenuData event,
    Emitter<MenuState> emit,
  ) async {
    // Don't show loading during refresh, just update data
    final categoriesResult = await getMenuCategories(const NoParams());
    final itemsResult = await getMenuItems(const NoParams());

    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;

      final updatedCategories = categoriesResult.fold(
        (failure) => currentState.categories,
        (categories) => categories,
      );

      final updatedItems = itemsResult.fold(
        (failure) => currentState.items,
        (items) => items,
      );

      emit(currentState.copyWith(
        categories: updatedCategories,
        items: updatedItems,
        filteredItems: null,
        selectedCategory: null,
        searchQuery: null,
      ));
    }
  }

  Future<void> _onSearchMenuItems(
    SearchMenuItems event,
    Emitter<MenuState> emit,
  ) async {
    if (state is! MenuLoaded) return;

    final currentState = state as MenuLoaded;
    final filteredItems = currentState.items.where((item) {
      return item.name.toLowerCase().contains(event.query.toLowerCase()) ||
          item.description.toLowerCase().contains(event.query.toLowerCase());
    }).toList();

    emit(currentState.copyWith(
      filteredItems: filteredItems,
      searchQuery: event.query,
      selectedCategory: null,
    ));
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<MenuState> emit,
  ) async {
    if (state is! MenuLoaded) return;

    final currentState = state as MenuLoaded;
    final filteredItems = currentState.items.where((item) {
      return item.categoryId == event.category.id;
    }).toList();

    emit(currentState.copyWith(
      filteredItems: filteredItems,
      selectedCategory: event.category,
      searchQuery: null,
    ));
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<MenuState> emit,
  ) async {
    if (state is! MenuLoaded) return;

    final currentState = state as MenuLoaded;
    emit(currentState.copyWith(
      filteredItems: null,
      selectedCategory: null,
      searchQuery: null,
    ));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return (failure as ServerFailure).message;
      case CacheFailure _:
        return (failure as CacheFailure).message;
      case NetworkFailure _:
        return (failure as NetworkFailure).message;
      default:
        return 'Unexpected error occurred';
    }
  }
}
