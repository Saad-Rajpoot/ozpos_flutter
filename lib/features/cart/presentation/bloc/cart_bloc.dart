import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_bloc.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/remove_from_cart.dart';
import '../../domain/usecases/update_cart_item.dart';
import '../../domain/usecases/clear_cart.dart';
import '../../domain/repositories/cart_repository.dart';


/// Cart BLoC
class CartBloc extends BaseBloc<CartEvent, CartState> {
  final AddToCart addToCart;
  final RemoveFromCart removeFromCart;
  final UpdateCartItem updateCartItem;
  final ClearCart clearCart;
  final CartRepository cartRepository; // To get initial items

  CartBloc({
    required this.addToCart,
    required this.removeFromCart,
    required this.updateCartItem,
    required this.clearCart,
    required this.cartRepository,
  }) : super(const CartLoaded(items: [])) {
    on<GetCartItemsEvent>(_onGetCartItems);
    on<AddItemToCartEvent>(_onAddItemToCart);
    on<RemoveItemFromCartEvent>(_onRemoveItemFromCart);
    on<UpdateCartItemEvent>(_onUpdateCartItem);
    on<ClearCartEvent>(_onClearCart);
  }

  Future<void> _onGetCartItems(
    GetCartItemsEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    final result = await cartRepository.getCartItems();
    result.fold(
      (failure) => emit(CartError(message: _mapFailureToMessage(failure))),
      (items) => emit(_calculateTotals(items)),
    );
  }

  Future<void> _onAddItemToCart(
    AddItemToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      final currentItems = (state as CartLoaded).items;
      final existingItemIndex = currentItems.indexWhere(
        (item) => item.itemId == event.item.itemId && item.modifiers.toString() == event.item.modifiers.toString(),
      );

      if (existingItemIndex != -1) {
        // Update existing item
        final existingItem = currentItems[existingItemIndex];
        final updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity + event.item.quantity,
          totalPrice: existingItem.totalPrice + event.item.totalPrice,
        );
        final result = await updateCartItem(UpdateCartItemParams(
          lineItemId: updatedItem.lineItemId,
          quantity: updatedItem.quantity,
        ));
        result.fold(
          (failure) => emit(CartError(message: _mapFailureToMessage(failure))),
          (_) => add(GetCartItemsEvent()), // Refresh cart
        );
      } else {
        // Add new item
        final result = await addToCart(event.item);
        result.fold(
          (failure) => emit(CartError(message: _mapFailureToMessage(failure))),
          (_) => add(GetCartItemsEvent()), // Refresh cart
        );
      }
    }
  }

  Future<void> _onRemoveItemFromCart(
    RemoveItemFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final result = await removeFromCart(event.lineItemId);
    result.fold(
      (failure) => emit(CartError(message: _mapFailureToMessage(failure))),
      (_) => add(GetCartItemsEvent()), // Refresh cart
    );
  }

  Future<void> _onUpdateCartItem(
    UpdateCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    final result = await updateCartItem(UpdateCartItemParams(
      lineItemId: event.item.lineItemId,
      quantity: event.item.quantity,
    ));
    result.fold(
      (failure) => emit(CartError(message: _mapFailureToMessage(failure))),
      (_) => add(GetCartItemsEvent()), // Refresh cart
    );
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final result = await clearCart(const NoParams());
    result.fold(
      (failure) => emit(CartError(message: _mapFailureToMessage(failure))),
      (_) => emit(const CartLoaded(items: [])), // Clear cart state
    );
  }

  CartLoaded _calculateTotals(List<CartItemEntity> items) {
    double subtotal = 0.0;
    for (var item in items) {
      subtotal += item.totalPrice;
    }
    // TODO: Implement actual tax calculation
    const double taxRate = 0.05;
    final double tax = subtotal * taxRate;
    final double total = subtotal + tax;
    return CartLoaded(items: items, subtotal: subtotal, tax: tax, total: total);
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
abstract class CartEvent extends BaseEvent {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class GetCartItemsEvent extends CartEvent {}

class AddItemToCartEvent extends CartEvent {
  final CartItemEntity item;

  const AddItemToCartEvent({required this.item});

  @override
  List<Object?> get props => [item];
}

class RemoveItemFromCartEvent extends CartEvent {
  final String lineItemId;

  const RemoveItemFromCartEvent({required this.lineItemId});

  @override
  List<Object?> get props => [lineItemId];
}

class UpdateCartItemEvent extends CartEvent {
  final CartItemEntity item;

  const UpdateCartItemEvent({required this.item});

  @override
  List<Object?> get props => [item];
}

class ClearCartEvent extends CartEvent {}

// States
abstract class CartState extends BaseState {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  final double subtotal;
  final double tax;
  final double total;

  const CartLoaded({
    required this.items,
    this.subtotal = 0.0,
    this.tax = 0.0,
    this.total = 0.0,
  });

  CartLoaded copyWith({
    List<CartItemEntity>? items,
    double? subtotal,
    double? tax,
    double? total,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [items, subtotal, tax, total];
}

class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object?> get props => [message];
}
