import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/modifier_group_entity.dart';
import '../../domain/entities/modifier_option_entity.dart';
import '../../domain/entities/combo_option_entity.dart';

/// Item Configuration BLoC for managing modifier selection
class ItemConfigBloc extends Bloc<ItemConfigEvent, ItemConfigState> {
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
    
    // Apply defaults for each group
    for (final group in event.item.modifierGroups) {
      final defaultOptions = group.options
          .where((opt) => opt.isDefault)
          .map((opt) => opt.id)
          .toList();
      if (defaultOptions.isNotEmpty) {
        selectedOptions[group.id] = defaultOptions;
      }
    }

    final initialPrice = _calculatePrice(
      event.item,
      selectedOptions,
      null,
      1,
    );

    final canAdd = _checkRequiredGroups(event.item.modifierGroups, selectedOptions);

    emit(ItemConfigLoaded(
      item: event.item,
      selectedOptions: selectedOptions,
      selectedComboId: null,
      quantity: 1,
      totalPrice: initialPrice,
      canAddToCart: canAdd,
    ));
  }

  Future<void> _onSelectOption(
    SelectModifierOption event,
    Emitter<ItemConfigState> emit,
  ) async {
    if (state is! ItemConfigLoaded) return;
    
    final currentState = state as ItemConfigLoaded;
    final selectedOptions = Map<String, List<String>>.from(currentState.selectedOptions);
    
    // Find the group
    final group = currentState.item.modifierGroups
        .firstWhere((g) => g.id == event.groupId);
    
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
          selectedOptions[event.groupId] = [...currentSelections, event.optionId];
        }
      }
    } else {
      // Deselect
      selectedOptions[event.groupId] = currentSelections
          .where((id) => id != event.optionId)
          .toList();
    }

    final newPrice = _calculatePrice(
      currentState.item,
      selectedOptions,
      currentState.selectedComboId,
      currentState.quantity,
    );

    final canAdd = _checkRequiredGroups(
      currentState.item.modifierGroups,
      selectedOptions,
    );

    emit(currentState.copyWith(
      selectedOptions: selectedOptions,
      totalPrice: newPrice,
      canAddToCart: canAdd,
    ));
  }

  Future<void> _onSelectCombo(
    SelectComboOption event,
    Emitter<ItemConfigState> emit,
  ) async {
    if (state is! ItemConfigLoaded) return;
    
    final currentState = state as ItemConfigLoaded;
    
    final newPrice = _calculatePrice(
      currentState.item,
      currentState.selectedOptions,
      event.comboId,
      currentState.quantity,
    );

    emit(currentState.copyWith(
      selectedComboId: event.comboId,
      totalPrice: newPrice,
    ));
  }

  Future<void> _onUpdateQuantity(
    UpdateQuantity event,
    Emitter<ItemConfigState> emit,
  ) async {
    if (state is! ItemConfigLoaded) return;
    
    final currentState = state as ItemConfigLoaded;
    
    if (event.quantity < 1) return;

    final newPrice = _calculatePrice(
      currentState.item,
      currentState.selectedOptions,
      currentState.selectedComboId,
      event.quantity,
    );

    emit(currentState.copyWith(
      quantity: event.quantity,
      totalPrice: newPrice,
    ));
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

  double _calculatePrice(
    MenuItemEntity item,
    Map<String, List<String>> selectedOptions,
    String? selectedComboId,
    int quantity,
  ) {
    double base = item.basePrice;
    
    // Add modifier prices
    for (final groupEntry in selectedOptions.entries) {
      final group = item.modifierGroups.firstWhere((g) => g.id == groupEntry.key);
      for (final optionId in groupEntry.value) {
        final option = group.options.firstWhere((o) => o.id == optionId);
        base += option.priceDelta;
      }
    }
    
    // Add combo price
    if (selectedComboId != null && item.comboOptions.isNotEmpty) {
      final combo = item.comboOptions.firstWhere((c) => c.id == selectedComboId);
      base += combo.priceDelta;
    }
    
    return base * quantity;
  }

  bool _checkRequiredGroups(
    List<ModifierGroupEntity> groups,
    Map<String, List<String>> selectedOptions,
  ) {
    for (final group in groups) {
      if (group.isRequired) {
        final selections = selectedOptions[group.id] ?? [];
        if (selections.length < group.minSelection) {
          return false;
        }
      }
    }
    return true;
  }
}

// Events
abstract class ItemConfigEvent extends Equatable {
  const ItemConfigEvent();
  
  @override
  List<Object?> get props => [];
}

class InitializeItemConfig extends ItemConfigEvent {
  final MenuItemEntity item;
  
  const InitializeItemConfig({required this.item});
  
  @override
  List<Object?> get props => [item];
}

class SelectModifierOption extends ItemConfigEvent {
  final String groupId;
  final String optionId;
  final bool selected;
  
  const SelectModifierOption({
    required this.groupId,
    required this.optionId,
    required this.selected,
  });
  
  @override
  List<Object?> get props => [groupId, optionId, selected];
}

class SelectComboOption extends ItemConfigEvent {
  final String? comboId;
  
  const SelectComboOption({this.comboId});
  
  @override
  List<Object?> get props => [comboId];
}

class UpdateQuantity extends ItemConfigEvent {
  final int quantity;
  
  const UpdateQuantity({required this.quantity});
  
  @override
  List<Object?> get props => [quantity];
}

class ResetConfiguration extends ItemConfigEvent {
  const ResetConfiguration();
}

// States
abstract class ItemConfigState extends Equatable {
  const ItemConfigState();
  
  @override
  List<Object?> get props => [];
}

class ItemConfigInitial extends ItemConfigState {}

class ItemConfigLoaded extends ItemConfigState {
  final MenuItemEntity item;
  final Map<String, List<String>> selectedOptions;
  final String? selectedComboId;
  final int quantity;
  final double totalPrice;
  final bool canAddToCart;
  
  const ItemConfigLoaded({
    required this.item,
    required this.selectedOptions,
    this.selectedComboId,
    required this.quantity,
    required this.totalPrice,
    required this.canAddToCart,
  });
  
  ItemConfigLoaded copyWith({
    MenuItemEntity? item,
    Map<String, List<String>>? selectedOptions,
    String? selectedComboId,
    int? quantity,
    double? totalPrice,
    bool? canAddToCart,
  }) {
    return ItemConfigLoaded(
      item: item ?? this.item,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      selectedComboId: selectedComboId ?? this.selectedComboId,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      canAddToCart: canAddToCart ?? this.canAddToCart,
    );
  }
  
  @override
  List<Object?> get props => [
        item,
        selectedOptions,
        selectedComboId,
        quantity,
        totalPrice,
        canAddToCart,
      ];
}
