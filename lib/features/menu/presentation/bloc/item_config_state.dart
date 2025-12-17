import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/menu_item_entity.dart';

/// Item Configuration States
abstract class ItemConfigState extends BaseState {
  const ItemConfigState();

  @override
  List<Object?> get props => [];
}

class ItemConfigInitial extends ItemConfigState {
  const ItemConfigInitial();

  @override
  List<Object?> get props => [];
}

class ItemConfigLoading extends ItemConfigState {
  const ItemConfigLoading();

  @override
  List<Object?> get props => [];
}

class ItemConfigLoaded extends ItemConfigState {
  final MenuItemEntity item;
  final Map<String, List<String>> selectedOptions;
  final String? selectedComboId;
  final int quantity;
  final double totalPrice;
  final bool canAddToCart;
  final String? specialInstructions;

  const ItemConfigLoaded({
    required this.item,
    required this.selectedOptions,
    this.selectedComboId,
    required this.quantity,
    required this.totalPrice,
    required this.canAddToCart,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [
        item,
        selectedOptions,
        selectedComboId,
        quantity,
        totalPrice,
        canAddToCart,
        specialInstructions,
      ];

  ItemConfigLoaded copyWith({
    MenuItemEntity? item,
    Map<String, List<String>>? selectedOptions,
    String? selectedComboId,
    int? quantity,
    double? totalPrice,
    bool? canAddToCart,
    String? specialInstructions,
  }) {
    return ItemConfigLoaded(
      item: item ?? this.item,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      selectedComboId: selectedComboId ?? this.selectedComboId,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      canAddToCart: canAddToCart ?? this.canAddToCart,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

class ItemConfigError extends ItemConfigState {
  final String message;

  const ItemConfigError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ItemConfigAddingToCart extends ItemConfigState {
  const ItemConfigAddingToCart();

  @override
  List<Object?> get props => [];
}

class ItemConfigAddedToCart extends ItemConfigState {
  const ItemConfigAddedToCart();

  @override
  List<Object?> get props => [];
}
