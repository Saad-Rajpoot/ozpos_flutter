import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_bloc.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_menu_items.dart';
import '../../domain/usecases/get_menu_categories.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
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

    // Load both categories and items simultaneously in parallel
    final categoriesResult = await getMenuCategories(const NoParams());
    final itemsResult = await getMenuItems(const NoParams());

    // Preserve existing data if available
    final existingCategories = state is MenuLoaded
        ? (state as MenuLoaded).categories
        : <MenuCategoryEntity>[];
    final existingItems =
        state is MenuLoaded ? (state as MenuLoaded).items : <MenuItemEntity>[];

    // Track errors for reporting
    String? categoriesError;
    String? itemsError;

    // Handle categories result - preserve partial success
    final loadedCategories = categoriesResult.fold(
      (failure) {
        categoriesError = _mapFailureToMessage(failure);
        return existingCategories; // Use existing or empty on failure
      },
      (categories) => categories,
    );

    // Handle items result - preserve partial success
    final loadedItems = itemsResult.fold(
      (failure) {
        itemsError = _mapFailureToMessage(failure);
        return existingItems; // Use existing or empty on failure
      },
      (items) => items,
    );

    // Determine if we have any data to show
    final hasCategories = loadedCategories.isNotEmpty;
    final hasItems = loadedItems.isNotEmpty;

    if (hasCategories || hasItems) {
      // Emit loaded state with whatever data we have (partial success)
      // This provides better UX - user sees partial data rather than error screen
      emit(MenuLoaded(
        categories: loadedCategories,
        items: loadedItems,
      ));
    } else {
      // Both failed and no existing data - emit error
      // Prefer categories error if available, otherwise items error
      final errorMessage = categoriesError ?? itemsError ?? 'Unknown error';
      emit(MenuError(message: errorMessage));
    }
  }

  Future<void> _onRefreshMenuData(
    RefreshMenuData event,
    Emitter<MenuState> emit,
  ) async {
    // Show loading during refresh
    emit(const MenuLoading());

    // Load both categories and items simultaneously in parallel
    final categoriesResult = await getMenuCategories(const NoParams());
    final itemsResult = await getMenuItems(const NoParams());

    // Preserve existing data if available (for offline scenarios)
    final existingCategories = state is MenuLoaded
        ? (state as MenuLoaded).categories
        : <MenuCategoryEntity>[];
    final existingItems =
        state is MenuLoaded ? (state as MenuLoaded).items : <MenuItemEntity>[];

    // Track which calls succeeded/failed
    String? categoriesError;
    String? itemsError;

    // Handle categories result - preserve partial success
    final loadedCategories = categoriesResult.fold(
      (failure) {
        categoriesError = _mapFailureToMessage(failure);
        return existingCategories; // Use existing or empty on failure
      },
      (categories) => categories,
    );

    // Handle items result - preserve partial success
    final loadedItems = itemsResult.fold(
      (failure) {
        itemsError = _mapFailureToMessage(failure);
        return existingItems; // Use existing or empty on failure
      },
      (items) => items,
    );

    // Determine if we have any data to show
    final hasCategories = loadedCategories.isNotEmpty;
    final hasItems = loadedItems.isNotEmpty;

    if (hasCategories || hasItems) {
      // Emit loaded state with whatever data we have (partial success)
      // This provides better UX - user sees partial data rather than error screen
      emit(MenuLoaded(
        categories: loadedCategories,
        items: loadedItems,
      ));
    } else {
      // Both failed and no existing data - emit error
      // Prefer categories error if available, otherwise items error
      final errorMessage = categoriesError ?? itemsError ?? 'Unknown error';
      emit(MenuError(message: errorMessage));
    }
  }

  Future<void> _onSearchMenuItems(
    SearchMenuItems event,
    Emitter<MenuState> emit,
  ) async {
    if (state is! MenuLoaded) return;

    final currentState = state as MenuLoaded;

    // Avoid unnecessary filtering if query hasn't changed
    if (currentState.searchQuery == event.query) return;

    // Clear filters when search query is empty or too short
    if (event.query.isEmpty || event.query.length < 2) {
      emit(currentState.copyWith(
        filteredItems: null,
        searchQuery: null,
        selectedCategory: null,
      ));
      return;
    }

    // Perform case-insensitive search on name and description
    final queryLower = event.query.toLowerCase();
    final filteredItems = currentState.items.where((item) {
      return item.name.toLowerCase().contains(queryLower) ||
          (item.description.isNotEmpty &&
              item.description.toLowerCase().contains(queryLower));
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

    // Avoid unnecessary filtering if category hasn't changed
    if (currentState.selectedCategory?.id == event.category.id) return;

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

    // Avoid unnecessary emission if filters are already cleared
    if (currentState.filteredItems == null &&
        currentState.selectedCategory == null &&
        currentState.searchQuery == null) {
      return;
    }

    final newState = currentState.copyWith(
      filteredItems: null,
      selectedCategory: null,
      searchQuery: null,
    );
    emit(newState);
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
