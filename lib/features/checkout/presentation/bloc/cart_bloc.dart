import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../../../tables/domain/entities/table_entity.dart';

// ============================================================================
// CART LINE ITEM
// ============================================================================

class CartLineItem extends Equatable {
  final String id; // Unique ID for this line item
  final MenuItemEntity menuItem;
  final int quantity;
  final double unitPrice; // Price per item (base + modifiers + combo)
  final String? selectedComboId;
  final Map<String, List<String>> selectedModifiers; // groupId -> [optionIds]
  final String modifierSummary; // Display string: "Large, Extra Cheese, BBQ"

  const CartLineItem({
    required this.id,
    required this.menuItem,
    required this.quantity,
    required this.unitPrice,
    this.selectedComboId,
    required this.selectedModifiers,
    required this.modifierSummary,
  });

  double get lineTotal => unitPrice * quantity;

  CartLineItem copyWith({
    int? quantity,
    Map<String, List<String>>? selectedModifiers,
  }) {
    return CartLineItem(
      id: id,
      menuItem: menuItem,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
      selectedComboId: selectedComboId,
      selectedModifiers: selectedModifiers ?? this.selectedModifiers,
      modifierSummary: modifierSummary,
    );
  }

  @override
  List<Object?> get props => [
        id,
        menuItem.id,
        quantity,
        unitPrice,
        selectedComboId,
        selectedModifiers,
        modifierSummary,
      ];
}

// ============================================================================
// ORDER TYPE
// ============================================================================

enum OrderType { dineIn, takeaway, delivery }

// ============================================================================
// CART STATE
// ============================================================================

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoaded extends CartState {
  final List<CartLineItem> items;
  final OrderType orderType;
  final TableEntity? selectedTable;
  final String? customerName;
  final String? customerPhone;
  final double subtotal;
  final double gst;
  final double total;

  const CartLoaded({
    required this.items,
    required this.orderType,
    this.selectedTable,
    this.customerName,
    this.customerPhone,
    required this.subtotal,
    required this.gst,
    required this.total,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartLoaded copyWith({
    List<CartLineItem>? items,
    OrderType? orderType,
    TableEntity? selectedTable,
    String? customerName,
    String? customerPhone,
    bool clearTable = false,
  }) {
    final newItems = items ?? this.items;
    final newSubtotal = _calculateSubtotal(newItems);
    final newGst = newSubtotal * 0.10; // 10% GST
    final newTotal = newSubtotal + newGst;

    return CartLoaded(
      items: newItems,
      orderType: orderType ?? this.orderType,
      selectedTable: clearTable ? null : (selectedTable ?? this.selectedTable),
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      subtotal: newSubtotal,
      gst: newGst,
      total: newTotal,
    );
  }

  static double _calculateSubtotal(List<CartLineItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  @override
  List<Object?> get props => [
        items,
        orderType,
        selectedTable,
        customerName,
        customerPhone,
        subtotal,
        gst,
        total,
      ];
}

// ============================================================================
// CART EVENTS
// ============================================================================

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCart extends CartEvent {
  final OrderType? initialOrderType;

  const InitializeCart({this.initialOrderType});

  @override
  List<Object?> get props => [initialOrderType];
}

class AddItemToCart extends CartEvent {
  final MenuItemEntity menuItem;
  final int quantity;
  final double unitPrice;
  final String? selectedComboId;
  final Map<String, List<String>> selectedModifiers;
  final String modifierSummary;

  const AddItemToCart({
    required this.menuItem,
    required this.quantity,
    required this.unitPrice,
    this.selectedComboId,
    required this.selectedModifiers,
    required this.modifierSummary,
  });

  @override
  List<Object?> get props => [
        menuItem.id,
        quantity,
        unitPrice,
        selectedComboId,
        selectedModifiers,
        modifierSummary,
      ];
}

class UpdateLineItemQuantity extends CartEvent {
  final String lineItemId;
  final int newQuantity;

  const UpdateLineItemQuantity({
    required this.lineItemId,
    required this.newQuantity,
  });

  @override
  List<Object?> get props => [lineItemId, newQuantity];
}

class RemoveLineItem extends CartEvent {
  final String lineItemId;

  const RemoveLineItem({required this.lineItemId});

  @override
  List<Object?> get props => [lineItemId];
}

class ChangeOrderType extends CartEvent {
  final OrderType orderType;

  const ChangeOrderType({required this.orderType});

  @override
  List<Object?> get props => [orderType];
}

class SelectTable extends CartEvent {
  final TableEntity table;

  const SelectTable({required this.table});

  @override
  List<Object?> get props => [table.id];
}

class ClearTable extends CartEvent {}

class UpdateCustomer extends CartEvent {
  final String? name;
  final String? phone;

  const UpdateCustomer({this.name, this.phone});

  @override
  List<Object?> get props => [name, phone];
}

class ClearCart extends CartEvent {}

// ============================================================================
// CART BLOC
// ============================================================================

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<InitializeCart>(_onInitializeCart);
    on<AddItemToCart>(_onAddItemToCart);
    on<UpdateLineItemQuantity>(_onUpdateLineItemQuantity);
    on<RemoveLineItem>(_onRemoveLineItem);
    on<ChangeOrderType>(_onChangeOrderType);
    on<SelectTable>(_onSelectTable);
    on<ClearTable>(_onClearTable);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<ClearCart>(_onClearCart);
  }

  void _onInitializeCart(InitializeCart event, Emitter<CartState> emit) {
    emit(
      CartLoaded(
        items: const [],
        orderType: event.initialOrderType ?? OrderType.dineIn,
        subtotal: 0.0,
        gst: 0.0,
        total: 0.0,
      ),
    );
  }

  /// Helper method to get default modifiers for a menu item
  Map<String, List<String>> _getDefaultModifiers(MenuItemEntity menuItem) {
    final defaultModifiers = <String, List<String>>{};

    for (final group in menuItem.modifierGroups) {
      final defaultOptions = group.options
          .where((opt) => opt.isDefault)
          .map((opt) => opt.id)
          .toList();
      if (defaultOptions.isNotEmpty) {
        defaultModifiers[group.id] = defaultOptions;
      }
    }

    return defaultModifiers;
  }

  /// Helper method to find index of identical item in cart
  /// Two items are considered identical if they have same menu item, modifiers, and combo
  int _findIdenticalItemIndex(List<CartLineItem> items, AddItemToCart event) {
    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      // Check if menu item IDs match
      if (item.menuItem.id != event.menuItem.id) continue;

      // Check if combo selections match (both null or both same)
      if (item.selectedComboId != event.selectedComboId) continue;

      // Check if modifiers match
      // If new item has empty modifiers, compare with default modifiers for the menu item
      final modifiersToCompare = event.selectedModifiers.isEmpty
          ? _getDefaultModifiers(event.menuItem)
          : event.selectedModifiers;

      if (!_modifiersMatch(item.selectedModifiers, modifiersToCompare)) {
        continue;
      }

      return i;
    }

    return -1; // No identical item found
  }

  /// Helper method to compare modifier selections
  bool _modifiersMatch(Map<String, List<String>> modifiers1,
      Map<String, List<String>> modifiers2) {
    // Check if both have same modifier groups
    if (modifiers1.keys.length != modifiers2.keys.length) return false;
    if (!modifiers1.keys.every((key) => modifiers2.containsKey(key))) {
      return false;
    }

    // Check if each modifier group has same options
    for (final groupId in modifiers1.keys) {
      final options1 = modifiers1[groupId] ?? [];
      final options2 = modifiers2[groupId] ?? [];

      if (options1.length != options2.length) return false;
      if (!options1.every((option) => options2.contains(option))) return false;
    }

    return true;
  }

  void _onAddItemToCart(AddItemToCart event, Emitter<CartState> emit) {
    if (state is! CartLoaded) return;

    final currentState = state as CartLoaded;

    // If event has empty modifiers, use defaults for comparison
    if (event.selectedModifiers.isEmpty) {}

    // Check if an identical item already exists in the cart
    final existingItemIndex =
        _findIdenticalItemIndex(currentState.items, event);

    if (existingItemIndex != -1) {
      // Update quantity of existing item
      final existingItem = currentState.items[existingItemIndex];
      final updatedQuantity = existingItem.quantity + event.quantity;

      // Ensure the existing item uses default modifiers if it had empty modifiers
      final finalModifiers = existingItem.selectedModifiers.isEmpty
          ? _getDefaultModifiers(event.menuItem)
          : existingItem.selectedModifiers;

      final updatedItems = List<CartLineItem>.from(currentState.items);
      updatedItems[existingItemIndex] = existingItem.copyWith(
        quantity: updatedQuantity,
        selectedModifiers: finalModifiers,
      );

      emit(currentState.copyWith(items: updatedItems));
    } else {
      // Add new item to cart
      // Generate unique line item ID
      final lineItemId =
          '${event.menuItem.id}_${DateTime.now().millisecondsSinceEpoch}';

      // Use default modifiers if event has empty modifiers
      final finalModifiers = event.selectedModifiers.isEmpty
          ? _getDefaultModifiers(event.menuItem)
          : event.selectedModifiers;

      final newLineItem = CartLineItem(
        id: lineItemId,
        menuItem: event.menuItem,
        quantity: event.quantity,
        unitPrice: event.unitPrice,
        selectedComboId: event.selectedComboId,
        selectedModifiers: finalModifiers,
        modifierSummary: event.modifierSummary,
      );

      final updatedItems = List<CartLineItem>.from(currentState.items)
        ..add(newLineItem);

      emit(currentState.copyWith(items: updatedItems));
    }
  }

  void _onUpdateLineItemQuantity(
    UpdateLineItemQuantity event,
    Emitter<CartState> emit,
  ) {
    if (state is! CartLoaded) return;

    final currentState = state as CartLoaded;

    if (event.newQuantity <= 0) {
      // Remove item if quantity is 0 or less
      add(RemoveLineItem(lineItemId: event.lineItemId));
      return;
    }

    final updatedItems = currentState.items.map((item) {
      if (item.id == event.lineItemId) {
        return item.copyWith(quantity: event.newQuantity);
      }
      return item;
    }).toList();

    emit(currentState.copyWith(items: updatedItems));
  }

  void _onRemoveLineItem(RemoveLineItem event, Emitter<CartState> emit) {
    if (state is! CartLoaded) return;

    final currentState = state as CartLoaded;

    final updatedItems = currentState.items
        .where((item) => item.id != event.lineItemId)
        .toList();

    emit(currentState.copyWith(items: updatedItems));
  }

  void _onChangeOrderType(ChangeOrderType event, Emitter<CartState> emit) {
    if (state is! CartLoaded) return;

    final currentState = state as CartLoaded;

    emit(
      currentState.copyWith(
        orderType: event.orderType,
        clearTable: event.orderType != OrderType.dineIn,
      ),
    );
  }

  void _onSelectTable(SelectTable event, Emitter<CartState> emit) {
    if (state is! CartLoaded) return;

    final currentState = state as CartLoaded;

    emit(
      currentState.copyWith(
        selectedTable: event.table,
        orderType: OrderType.dineIn,
      ),
    );
  }

  void _onClearTable(ClearTable event, Emitter<CartState> emit) {
    if (state is! CartLoaded) return;

    final currentState = state as CartLoaded;

    emit(currentState.copyWith(clearTable: true));
  }

  void _onUpdateCustomer(UpdateCustomer event, Emitter<CartState> emit) {
    if (state is! CartLoaded) return;

    final currentState = state as CartLoaded;

    emit(
      currentState.copyWith(
        customerName: event.name,
        customerPhone: event.phone,
      ),
    );
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(
      const CartLoaded(
        items: [],
        orderType: OrderType.dineIn,
        subtotal: 0.0,
        gst: 0.0,
        total: 0.0,
      ),
    );
  }
}
