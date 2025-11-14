import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_bloc.dart';
import '../../domain/services/menu_item_price_calculator.dart';
import '../../domain/services/modifier_validator.dart';
import 'item_config_event.dart';
import 'item_config_state.dart';

/// Item Configuration BLoC for managing modifier selection
class ItemConfigBloc extends BaseBloc<ItemConfigEvent, ItemConfigState> {
  ItemConfigBloc() : super(ItemConfigInitial()) {
    on<InitializeItemConfig>(_onInitialize);
    on<SelectModifierOption>(_onSelectOption);
    on<SelectComboOption>(_onSelectCombo);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ResetConfiguration>(_onReset);
  }

  Future<void> _onInitialize(
    InitializeItemConfig event,
    Emitter<ItemConfigState> emit,
  ) async {
    // Initialize with default selections
    final selectedOptions = <String, List<String>>{};

    // Apply defaults for each group using domain service
    final defaultModifiers = MenuItemPriceCalculator.getDefaultModifiers(
      event.item,
    );
    selectedOptions.addAll(defaultModifiers);

    // Calculate initial price using domain service
    final initialPrice = MenuItemPriceCalculator.calculatePrice(
      item: event.item,
      selectedModifiers: selectedOptions,
      selectedComboId: null,
      quantity: 1,
    );

    // Validate required groups using domain service
    final canAdd = ModifierValidator.validateRequiredGroups(
      groups: event.item.modifierGroups,
      selectedModifiers: selectedOptions,
    );

    emit(
      ItemConfigLoaded(
        item: event.item,
        selectedOptions: selectedOptions,
        selectedComboId: null,
        quantity: 1,
        totalPrice: initialPrice,
        canAddToCart: canAdd,
      ),
    );
  }

  Future<void> _onSelectOption(
    SelectModifierOption event,
    Emitter<ItemConfigState> emit,
  ) async {
    if (state is! ItemConfigLoaded) return;

    final currentState = state as ItemConfigLoaded;
    final selectedOptions = Map<String, List<String>>.from(
      currentState.selectedOptions,
    );

    // Find the group
    final group = currentState.item.modifierGroups.firstWhere(
      (g) => g.id == event.groupId,
    );

    if (!selectedOptions.containsKey(event.groupId)) {
      selectedOptions[event.groupId] = [];
    }

    final currentSelections = selectedOptions[event.groupId]!;

    if (event.selected) {
      // Check if group is radio (max 1)
      if (group.maxSelection == 1) {
        selectedOptions[event.groupId] = [event.optionId];
      } else {
        // Check max selection
        if (currentSelections.length >= group.maxSelection) {
          return; // Max reached, don't add
        }
        if (!currentSelections.contains(event.optionId)) {
          selectedOptions[event.groupId] = [
            ...currentSelections,
            event.optionId,
          ];
        }
      }
    } else {
      // Deselect
      selectedOptions[event.groupId] =
          currentSelections.where((id) => id != event.optionId).toList();
    }

    // Calculate price using domain service
    final newPrice = MenuItemPriceCalculator.calculatePrice(
      item: currentState.item,
      selectedModifiers: selectedOptions,
      selectedComboId: currentState.selectedComboId,
      quantity: currentState.quantity,
    );

    // Validate required groups using domain service
    final canAdd = ModifierValidator.validateRequiredGroups(
      groups: currentState.item.modifierGroups,
      selectedModifiers: selectedOptions,
    );

    emit(
      currentState.copyWith(
        selectedOptions: selectedOptions,
        totalPrice: newPrice,
        canAddToCart: canAdd,
      ),
    );
  }

  Future<void> _onSelectCombo(
    SelectComboOption event,
    Emitter<ItemConfigState> emit,
  ) async {
    if (state is! ItemConfigLoaded) return;

    final currentState = state as ItemConfigLoaded;

    // Calculate price using domain service
    final newPrice = MenuItemPriceCalculator.calculatePrice(
      item: currentState.item,
      selectedModifiers: currentState.selectedOptions,
      selectedComboId: event.comboId,
      quantity: currentState.quantity,
    );

    emit(
      currentState.copyWith(
        selectedComboId: event.comboId,
        totalPrice: newPrice,
      ),
    );
  }

  Future<void> _onUpdateQuantity(
    UpdateQuantity event,
    Emitter<ItemConfigState> emit,
  ) async {
    if (state is! ItemConfigLoaded) return;

    final currentState = state as ItemConfigLoaded;

    if (event.quantity < 1) return;

    // Calculate price using domain service
    final newPrice = MenuItemPriceCalculator.calculatePrice(
      item: currentState.item,
      selectedModifiers: currentState.selectedOptions,
      selectedComboId: currentState.selectedComboId,
      quantity: event.quantity,
    );

    emit(currentState.copyWith(quantity: event.quantity, totalPrice: newPrice));
  }

  Future<void> _onReset(
    ResetConfiguration event,
    Emitter<ItemConfigState> emit,
  ) async {
    if (state is! ItemConfigLoaded) return;

    final currentState = state as ItemConfigLoaded;

    // Re-initialize with defaults
    add(InitializeItemConfig(item: currentState.item));
  }
}
