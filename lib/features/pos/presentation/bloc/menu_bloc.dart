import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_bloc.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/usecases/get_menu_items.dart';
import '../../domain/usecases/get_menu_categories.dart';

/// Menu BLoC
class MenuBloc extends BaseBloc<MenuEvent, MenuState> {
  final GetMenuItems getMenuItems;
  final GetMenuCategories getMenuCategories;

  MenuBloc({required this.getMenuItems, required this.getMenuCategories})
    : super(MenuInitial()) {
    on<GetMenuItemsEvent>(_onGetMenuItems);
    on<GetMenuCategoriesEvent>(_onGetMenuCategories);
  }

  Future<void> _onGetMenuItems(
    GetMenuItemsEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(MenuLoading());
    final result = await getMenuItems(const NoParams());
    result.fold(
      (failure) => emit(MenuError(message: _mapFailureToMessage(failure))),
      (items) {
        // If categories are already loaded, combine them
        if (state is MenuLoaded) {
          final currentCategories = (state as MenuLoaded).categories;
          emit(MenuLoaded(categories: currentCategories, items: items));
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
    emit(MenuLoading());
    final result = await getMenuCategories(const NoParams());
    result.fold(
      (failure) => emit(MenuError(message: _mapFailureToMessage(failure))),
      (categories) {
        // If items are already loaded, combine them
        if (state is MenuLoaded) {
          final currentItems = (state as MenuLoaded).items;
          emit(MenuLoaded(categories: categories, items: currentItems));
        } else {
          emit(MenuLoaded(categories: categories, items: const []));
        }
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case CacheFailure:
        return (failure as CacheFailure).message;
      case NetworkFailure:
        return (failure as NetworkFailure).message;
      default:
        return 'Unexpected error';
    }
  }
}

// Events
abstract class MenuEvent extends BaseEvent {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

class GetMenuCategoriesEvent extends MenuEvent {}

class GetMenuItemsEvent extends MenuEvent {}

// States
abstract class MenuState extends BaseState {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<MenuCategoryEntity> categories;
  final List<MenuItemEntity> items;

  const MenuLoaded({required this.categories, required this.items});

  @override
  List<Object?> get props => [categories, items];
}

class MenuError extends MenuState {
  final String message;

  const MenuError({required this.message});

  @override
  List<Object?> get props => [message];
}
