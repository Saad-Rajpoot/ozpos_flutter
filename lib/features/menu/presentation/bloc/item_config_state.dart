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
  final int? totalCalories;
  final bool canAddToCart;
  final String? specialInstructions;
  final String? feedbackMessage;

  const ItemConfigLoaded({
    required this.item,
    required this.selectedOptions,
    this.selectedComboId,
    required this.quantity,
    required this.totalPrice,
    this.totalCalories,
    required this.canAddToCart,
    this.specialInstructions,
    this.feedbackMessage,
  });

  @override
  List<Object?> get props => [
        item,
        selectedOptions,
        selectedComboId,
        quantity,
        totalPrice,
        totalCalories,
        canAddToCart,
        specialInstructions,
        feedbackMessage,
      ];

  ItemConfigLoaded copyWith({
    MenuItemEntity? item,
    Map<String, List<String>>? selectedOptions,
    String? selectedComboId,
    int? quantity,
    double? totalPrice,
    int? totalCalories,
    bool? canAddToCart,
    String? specialInstructions,
    String? feedbackMessage,
    bool clearFeedbackMessage = false,
  }) {
    return ItemConfigLoaded(
      item: item ?? this.item,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      selectedComboId: selectedComboId ?? this.selectedComboId,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      totalCalories: totalCalories ?? this.totalCalories,
      canAddToCart: canAddToCart ?? this.canAddToCart,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      feedbackMessage:
          clearFeedbackMessage ? null : (feedbackMessage ?? this.feedbackMessage),
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
