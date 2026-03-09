import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_bloc.dart';
import '../../domain/services/menu_item_price_calculator.dart';
import '../../domain/services/modifier_validator.dart';
import '../../domain/utils/modifier_tree_utils.dart';
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
    on<UpdateSpecialInstructions>(_onUpdateSpecialInstructions);
    on<ClearFeedbackMessage>(_onClearFeedbackMessage);
    on<ShowFeedbackMessage>(_onShowFeedbackMessage);
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

    // Validate required groups (including nested) using domain service
    final canAdd = ModifierValidator.validateRequiredGroups(
      item: event.item,
      selectedModifiers: selectedOptions,
    );

    final totalCalories = MenuItemPriceCalculator.calculateTotalCalories(
      item: event.item,
      selectedModifiers: selectedOptions,
    );

    emit(
      ItemConfigLoaded(
        item: event.item,
        selectedOptions: selectedOptions,
        selectedComboId: null,
        quantity: 1,
        totalPrice: initialPrice,
        totalCalories: totalCalories,
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

    // Find the group (may be nested)
    final group = ModifierTreeUtils.findGroupById(
      currentState.item,
      event.groupId,
    );
    if (group == null) return;

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
        if (currentSelections.length >= group.maxSelection &&
            !currentSelections.contains(event.optionId)) {
          final limit = group.maxSelection;
          emit(
            currentState.copyWith(
              feedbackMessage: limit == 1
                  ? 'Please select only one option for ${group.name}'
                  : 'You can select up to $limit options for ${group.name}. Deselect one to choose another.',
            ),
          );
          return;
        }
        if (!currentSelections.contains(event.optionId)) {
          selectedOptions[event.groupId] = [
            ...currentSelections,
            event.optionId,
          ];
        }
      }
    } else {
      // Deselect - also clear nested selections for this option
      selectedOptions[event.groupId] =
          currentSelections.where((id) => id != event.optionId).toList();
      final nestedPrefix =
          '${event.groupId}${ModifierTreeUtils.modifierPathSeparator}${event.optionId}${ModifierTreeUtils.modifierPathSeparator}';
      selectedOptions.removeWhere((key, _) => key.startsWith(nestedPrefix));
    }

    // Calculate price using domain service
    final newPrice = MenuItemPriceCalculator.calculatePrice(
      item: currentState.item,
      selectedModifiers: selectedOptions,
      selectedComboId: currentState.selectedComboId,
      quantity: currentState.quantity,
    );

    // Validate required groups (including nested) using domain service
    final canAdd = ModifierValidator.validateRequiredGroups(
      item: currentState.item,
      selectedModifiers: selectedOptions,
    );

    final totalCalories = MenuItemPriceCalculator.calculateTotalCalories(
      item: currentState.item,
      selectedModifiers: selectedOptions,
    );

    emit(
      currentState.copyWith(
        selectedOptions: selectedOptions,
        totalPrice: newPrice,
        totalCalories: totalCalories,
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

    final totalCalories = MenuItemPriceCalculator.calculateTotalCalories(
      item: currentState.item,
      selectedModifiers: currentState.selectedOptions,
    );

    emit(
      currentState.copyWith(
        selectedComboId: event.comboId,
        totalPrice: newPrice,
        totalCalories: totalCalories,
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

  void _onUpdateSpecialInstructions(
    UpdateSpecialInstructions event,
    Emitter<ItemConfigState> emit,
  ) {
    if (state is! ItemConfigLoaded) return;
    emit(
      (state as ItemConfigLoaded).copyWith(
        specialInstructions: event.instructions.isEmpty ? null : event.instructions,
      ),
    );
  }

  void _onClearFeedbackMessage(
    ClearFeedbackMessage event,
    Emitter<ItemConfigState> emit,
  ) {
    if (state is! ItemConfigLoaded) return;
    emit((state as ItemConfigLoaded).copyWith(clearFeedbackMessage: true));
  }

  void _onShowFeedbackMessage(
    ShowFeedbackMessage event,
    Emitter<ItemConfigState> emit,
  ) {
    if (state is! ItemConfigLoaded) return;
    emit((state as ItemConfigLoaded).copyWith(feedbackMessage: event.message));
  }
}
