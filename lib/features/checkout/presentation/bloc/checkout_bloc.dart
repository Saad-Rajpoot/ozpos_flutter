import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/base/base_bloc.dart';
import '../../../../core/services/customer_display_service.dart';
import '../../domain/entities/tender_entity.dart';
import '../../domain/entities/voucher_entity.dart';
import '../../domain/entities/payment_method_type.dart';
import '../../domain/entities/tender_status.dart';
import '../../domain/entities/book_order_item_input.dart';
import '../../domain/usecases/book_order.dart';
import '../../domain/usecases/initialize_checkout.dart';
import '../../domain/usecases/process_payment.dart';
import '../../domain/usecases/apply_voucher.dart';
import '../../domain/usecases/calculate_totals.dart';
import '../../domain/entities/cart_line_item_entity.dart';
import './cart_bloc.dart';

// ============================================================================
// CHECKOUT STATE
// ============================================================================

abstract class CheckoutState extends BaseState {
  const CheckoutState();
}

class CheckoutInitial extends CheckoutState {}

// ============================================================================
// SEPARATE STATE CLASSES FOR BETTER ORGANIZATION
// ============================================================================

class CheckoutPaymentState extends Equatable {
  final PaymentMethodType selectedMethod;
  final String cashReceived;

  const CheckoutPaymentState({
    required this.selectedMethod,
    required this.cashReceived,
  });

  CheckoutPaymentState copyWith({
    PaymentMethodType? selectedMethod,
    String? cashReceived,
  }) {
    return CheckoutPaymentState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      cashReceived: cashReceived ?? this.cashReceived,
    );
  }

  @override
  List<Object?> get props => [selectedMethod, cashReceived];
}

class CheckoutDiscountState extends Equatable {
  final int tipPercent;
  final String customTipAmount;
  final int discountPercent;
  final List<VoucherEntity> appliedVouchers;
  final double loyaltyRedemption;
  final bool isLoyaltyRedeemed;

  const CheckoutDiscountState({
    required this.tipPercent,
    required this.customTipAmount,
    required this.discountPercent,
    required this.appliedVouchers,
    required this.loyaltyRedemption,
    required this.isLoyaltyRedeemed,
  });

  CheckoutDiscountState copyWith({
    int? tipPercent,
    String? customTipAmount,
    int? discountPercent,
    List<VoucherEntity>? appliedVouchers,
    double? loyaltyRedemption,
    bool? isLoyaltyRedeemed,
  }) {
    return CheckoutDiscountState(
      tipPercent: tipPercent ?? this.tipPercent,
      customTipAmount: customTipAmount ?? this.customTipAmount,
      discountPercent: discountPercent ?? this.discountPercent,
      appliedVouchers: appliedVouchers ?? this.appliedVouchers,
      loyaltyRedemption: loyaltyRedemption ?? this.loyaltyRedemption,
      isLoyaltyRedeemed: isLoyaltyRedeemed ?? this.isLoyaltyRedeemed,
    );
  }

  @override
  List<Object?> get props => [
        tipPercent,
        customTipAmount,
        discountPercent,
        appliedVouchers,
        loyaltyRedemption,
        isLoyaltyRedeemed,
      ];
}

class CheckoutSplitState extends Equatable {
  final bool isSplitMode;
  final List<TenderEntity> tenders;

  const CheckoutSplitState({
    required this.isSplitMode,
    required this.tenders,
  });

  CheckoutSplitState copyWith({
    bool? isSplitMode,
    List<TenderEntity>? tenders,
  }) {
    return CheckoutSplitState(
      isSplitMode: isSplitMode ?? this.isSplitMode,
      tenders: tenders ?? this.tenders,
    );
  }

  @override
  List<Object?> get props => [isSplitMode, tenders];
}

class CheckoutCartState extends Equatable {
  final List<CartLineItem> items;
  final CalculateTotalsResult? totals;
  final OrderType orderType;
  final String? tableNumber;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  /// Order-level notes sent as meta.notes to the book-order API.
  final String? orderNotes;

  const CheckoutCartState({
    required this.items,
    this.totals,
    this.orderType = OrderType.dineIn,
    this.tableNumber,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.orderNotes,
  });

  CheckoutCartState copyWith({
    List<CartLineItem>? items,
    CalculateTotalsResult? totals,
    OrderType? orderType,
    String? tableNumber,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    String? orderNotes,
  }) {
    return CheckoutCartState(
      items: items ?? this.items,
      totals: totals ?? this.totals,
      orderType: orderType ?? this.orderType,
      tableNumber: tableNumber ?? this.tableNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      orderNotes: orderNotes ?? this.orderNotes,
    );
  }

  // Delegate calculations to use case result
  double get subtotal => totals?.subtotal ?? 0.0;
  double get tipAmount => totals?.tipAmount ?? 0.0;
  double get discountAmount => totals?.discountAmount ?? 0.0;
  double get voucherTotal => totals?.voucherTotal ?? 0.0;
  double get totalBeforeTax => totals?.totalBeforeTax ?? 0.0;
  double get tax => totals?.tax ?? 0.0;
  double get grandTotal => totals?.grandTotal ?? 0.0;
  double get cashReceivedNum => totals?.cashReceivedNum ?? 0.0;
  double get cashChange => totals?.cashChange ?? 0.0;
  int get itemCount => totals?.itemCount ?? 0;
  double get splitPaidTotal => totals?.splitPaidTotal ?? 0.0;
  double get splitRemaining => totals?.splitRemaining ?? 0.0;
  bool get canCompleteSplit => totals?.canCompleteSplit ?? false;
  bool get canPayCash => totals?.canPayCash ?? false;
  bool get canPayNonCash => totals?.canPayNonCash ?? false;
  bool get canPay => totals?.canPay ?? false;

  @override
  List<Object?> get props => [items, totals, orderType, tableNumber, customerName, customerPhone, deliveryAddress, orderNotes];
}

class CheckoutLoaded extends CheckoutState {
  final CheckoutPaymentState payment;
  final CheckoutDiscountState discounts;
  final CheckoutSplitState splitPayment;
  final CheckoutCartState cart;

  const CheckoutLoaded({
    required this.payment,
    required this.discounts,
    required this.splitPayment,
    required this.cart,
  });

  // Delegate properties to sub-states
  bool get isSplitMode => splitPayment.isSplitMode;
  PaymentMethodType get selectedMethod => payment.selectedMethod;
  String get cashReceived => payment.cashReceived;
  int get tipPercent => discounts.tipPercent;
  String get customTipAmount => discounts.customTipAmount;
  int get discountPercent => discounts.discountPercent;
  List<VoucherEntity> get appliedVouchers => discounts.appliedVouchers;
  double get loyaltyRedemption => discounts.loyaltyRedemption;
  bool get isLoyaltyRedeemed => discounts.isLoyaltyRedeemed;
  List<TenderEntity> get tenders => splitPayment.tenders;
  List<CartLineItem> get items => cart.items;
  CalculateTotalsResult? get totals => cart.totals;

  // Delegate calculations to cart state
  double get subtotal => cart.subtotal;
  double get tipAmount => cart.tipAmount;
  double get discountAmount => cart.discountAmount;
  double get voucherTotal => cart.voucherTotal;
  double get totalBeforeTax => cart.totalBeforeTax;
  double get tax => cart.tax;
  double get grandTotal => cart.grandTotal;
  double get cashReceivedNum => cart.cashReceivedNum;
  double get cashChange => cart.cashChange;
  int get itemCount => cart.itemCount;
  double get splitPaidTotal => cart.splitPaidTotal;
  double get splitRemaining => cart.splitRemaining;
  bool get canCompleteSplit => cart.canCompleteSplit;
  bool get canPayCash => cart.canPayCash;
  bool get canPayNonCash => cart.canPayNonCash;
  bool get canPay => cart.canPay;

  CheckoutLoaded copyWith({
    CheckoutPaymentState? payment,
    CheckoutDiscountState? discounts,
    CheckoutSplitState? splitPayment,
    CheckoutCartState? cart,
  }) {
    return CheckoutLoaded(
      payment: payment ?? this.payment,
      discounts: discounts ?? this.discounts,
      splitPayment: splitPayment ?? this.splitPayment,
      cart: cart ?? this.cart,
    );
  }

  @override
  List<Object?> get props => [payment, discounts, splitPayment, cart];
}

class CheckoutProcessing extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final String orderId;
  final double paidAmount;
  /// Pre-formatted receipt text for printing (order details, items, totals).
  final String? receiptText;

  const CheckoutSuccess({
    required this.orderId,
    required this.paidAmount,
    this.receiptText,
  });

  @override
  List<Object?> get props => [orderId, paidAmount, receiptText];
}

class CheckoutError extends CheckoutState {
  final String message;
  final DateTime timestamp;
  final bool canDismiss;
  final CheckoutLoaded? previousState;

  CheckoutError({
    required this.message,
    this.canDismiss = true,
    DateTime? timestamp,
    this.previousState,
  }) : timestamp = timestamp ?? DateTime.now();

  CheckoutError copyWith({
    String? message,
    bool? canDismiss,
    DateTime? timestamp,
    CheckoutLoaded? previousState,
  }) {
    return CheckoutError(
      message: message ?? this.message,
      canDismiss: canDismiss ?? this.canDismiss,
      timestamp: timestamp ?? this.timestamp,
      previousState: previousState ?? this.previousState,
    );
  }

  @override
  List<Object?> get props => [message, timestamp, canDismiss, previousState];
}

extension CheckoutStateView on CheckoutState {
  CheckoutLoaded? get viewState {
    if (this is CheckoutLoaded) {
      return this as CheckoutLoaded;
    }
    if (this is CheckoutError) {
      return (this as CheckoutError).previousState;
    }
    return null;
  }
}

// ============================================================================
// CHECKOUT EVENTS
// ============================================================================

abstract class CheckoutEvent extends BaseEvent {
  const CheckoutEvent();
}

class InitializeCheckout extends CheckoutEvent {
  final List<CartLineItem> items;
  final OrderType orderType;
  final String? tableNumber;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;

  const InitializeCheckout({
    required this.items,
    this.orderType = OrderType.dineIn,
    this.tableNumber,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
  });

  @override
  List<Object?> get props => [items, orderType, tableNumber, customerName, customerPhone, deliveryAddress];
}

class SyncCartItems extends CheckoutEvent {
  final List<CartLineItem> items;
  final OrderType? orderType;
  final String? tableNumber;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;

  SyncCartItems({
    required List<CartLineItem> items,
    this.orderType,
    this.tableNumber,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
  }) : items = List<CartLineItem>.unmodifiable(items);

  @override
  List<Object?> get props => [items, orderType, tableNumber, customerName, customerPhone, deliveryAddress];
}

class SelectPaymentMethod extends CheckoutEvent {
  final PaymentMethodType method;

  const SelectPaymentMethod({required this.method});

  @override
  List<Object?> get props => [method];
}

class SetOrderNotes extends CheckoutEvent {
  final String notes;

  const SetOrderNotes({required this.notes});

  @override
  List<Object?> get props => [notes];
}

class KeypadPress extends CheckoutEvent {
  final String key; // '0'-'9', '00', '⌫'

  const KeypadPress({required this.key});

  @override
  List<Object?> get props => [key];
}

class QuickAmountPress extends CheckoutEvent {
  final int amount; // 5, 10, 20, 50, 100

  const QuickAmountPress({required this.amount});

  @override
  List<Object?> get props => [amount];
}

class SelectTipPercent extends CheckoutEvent {
  final int percent; // 0, 5, 10, 15

  const SelectTipPercent({required this.percent});

  @override
  List<Object?> get props => [percent];
}

class SetCustomTip extends CheckoutEvent {
  final String amount;

  const SetCustomTip({required this.amount});

  @override
  List<Object?> get props => [amount];
}

class ApplyVoucher extends CheckoutEvent {
  final String code;

  const ApplyVoucher({required this.code});

  @override
  List<Object?> get props => [code];
}

class RemoveVoucher extends CheckoutEvent {
  final String id;

  const RemoveVoucher({required this.id});

  @override
  List<Object?> get props => [id];
}

class SetDiscountPercent extends CheckoutEvent {
  final int percent; // 0, 5, 10, 15

  const SetDiscountPercent({required this.percent});

  @override
  List<Object?> get props => [percent];
}

class RedeemLoyaltyPoints extends CheckoutEvent {
  final double amount;

  const RedeemLoyaltyPoints({required this.amount});

  @override
  List<Object?> get props => [amount];
}

class UndoLoyaltyRedemption extends CheckoutEvent {}

class ToggleSplitMode extends CheckoutEvent {}

class AddTender extends CheckoutEvent {
  final PaymentMethodType method;
  final double amount;

  const AddTender({required this.method, required this.amount});

  @override
  List<Object?> get props => [method, amount];
}

class RemoveTender extends CheckoutEvent {
  final String id;

  const RemoveTender({required this.id});

  @override
  List<Object?> get props => [id];
}

class SplitEvenly extends CheckoutEvent {
  final int ways; // 2, 3, 4

  const SplitEvenly({required this.ways});

  @override
  List<Object?> get props => [ways];
}

class ProcessPayment extends CheckoutEvent {}

class PayLater extends CheckoutEvent {}

class DismissError extends CheckoutEvent {}

// ============================================================================
//                            CHECKOUT BLOC
// ============================================================================

class CheckoutBloc extends BaseBloc<CheckoutEvent, CheckoutState> {
  final InitializeCheckoutUseCase _initializeCheckoutUseCase;
  final BookOrderUseCase _bookOrderUseCase;
  final ProcessPaymentUseCase _processPaymentUseCase;
  final ApplyVoucherUseCase _applyVoucherUseCase;
  final CalculateTotalsUseCase _calculateTotalsUseCase;
  final CustomerDisplayService? _customerDisplayService;
  CheckoutLoaded? _lastKnownLoadedState;

  CheckoutLoaded? _currentLoadedState() {
    if (state is CheckoutLoaded) {
      return state as CheckoutLoaded;
    }
    if (state is CheckoutError) {
      return (state as CheckoutError).previousState;
    }
    return null;
  }

  CheckoutBloc({
    required InitializeCheckoutUseCase initializeCheckoutUseCase,
    required BookOrderUseCase bookOrderUseCase,
    required ProcessPaymentUseCase processPaymentUseCase,
    required ApplyVoucherUseCase applyVoucherUseCase,
    required CalculateTotalsUseCase calculateTotalsUseCase,
    CustomerDisplayService? customerDisplayService,
  })  : _initializeCheckoutUseCase = initializeCheckoutUseCase,
        _bookOrderUseCase = bookOrderUseCase,
        _processPaymentUseCase = processPaymentUseCase,
        _applyVoucherUseCase = applyVoucherUseCase,
        _calculateTotalsUseCase = calculateTotalsUseCase,
        _customerDisplayService = customerDisplayService,
        super(CheckoutInitial()) {
    on<InitializeCheckout>(_onInitializeCheckout);
    on<SyncCartItems>(_onSyncCartItems);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<SetOrderNotes>(_onSetOrderNotes);
    on<KeypadPress>(_onKeypadPress);
    on<QuickAmountPress>(_onQuickAmountPress);
    on<SelectTipPercent>(_onSelectTipPercent);
    on<SetCustomTip>(_onSetCustomTip);
    on<ApplyVoucher>(_onApplyVoucher);
    on<RemoveVoucher>(_onRemoveVoucher);
    on<SetDiscountPercent>(_onSetDiscountPercent);
    on<RedeemLoyaltyPoints>(_onRedeemLoyaltyPoints);
    on<UndoLoyaltyRedemption>(_onUndoLoyaltyRedemption);
    on<ToggleSplitMode>(_onToggleSplitMode);
    on<AddTender>(_onAddTender);
    on<RemoveTender>(_onRemoveTender);
    on<SplitEvenly>(_onSplitEvenly);
    on<ProcessPayment>(_onProcessPayment);
    on<PayLater>(_onPayLater);
    on<DismissError>(_onDismissError);
  }

  Future<void> _onInitializeCheckout(
    InitializeCheckout event,
    Emitter<CheckoutState> emit,
  ) async {
    if (kDebugMode) {
      debugPrint(
        '🛒 CheckoutBloc: Initializing with ${event.items.length} items',
      );
      for (final item in event.items) {
        debugPrint(
          '  - ${item.menuItem.name} x${item.quantity} = \$${item.lineTotal}',
        );
      }
    }

    // Convert presentation entities to domain entities
    final domainItems = event.items
        .map((item) => CartLineItemEntity(
              id: item.id,
              menuItem: item.menuItem, // Use existing MenuItemEntity
              quantity: item.quantity,
              lineTotal: item.lineTotal,
              modifiers:
                  item.selectedModifiers.values.expand((list) => list).toList(),
              specialInstructions: item.specialInstructions?.trim().isNotEmpty == true
                  ? item.specialInstructions!.trim()
                  : null,
            ))
        .toList();

    final resultEither = await _initializeCheckoutUseCase(
      InitializeCheckoutParams(items: domainItems),
    );

    await resultEither.fold<Future<void>>(
      (failure) async {
        emit(
          CheckoutError(
            message: failure.message,
            canDismiss: true,
            previousState: _lastKnownLoadedState,
          ),
        );
      },
      (result) async {
        final originalItemsById = {
          for (final item in event.items) item.id: item,
        };

        final totalsEither = await _calculateTotalsUseCase(
          CalculateTotalsParams(
            items: result.items,
            tipPercent: result.tipPercent,
            customTipAmount: result.customTipAmount,
            discountPercent: result.discountPercent,
            appliedVouchers: result.appliedVouchers,
            loyaltyRedemption: result.loyaltyRedemption,
            tenders: result.tenders,
            isSplitMode: result.isSplitMode,
            selectedMethod: result.selectedMethod,
            cashReceived: result.cashReceived,
          ),
        );

        await totalsEither.fold<Future<void>>(
          (failure) async {
            emit(
              CheckoutError(
                message: failure.message,
                canDismiss: true,
                previousState: _lastKnownLoadedState,
              ),
            );
          },
          (totals) async {
            final cartItems = result.items.map((domainItem) {
              final sourceItem = originalItemsById[domainItem.id];

              final resolvedQuantity = domainItem.quantity == 0
                  ? (sourceItem?.quantity ?? 1)
                  : domainItem.quantity;
              final safeQuantity = resolvedQuantity == 0 ? 1 : resolvedQuantity;

              final unitPrice = domainItem.quantity == 0
                  ? (sourceItem?.unitPrice ??
                      (safeQuantity == 0
                          ? domainItem.menuItem.basePrice
                          : domainItem.lineTotal / safeQuantity))
                  : domainItem.lineTotal / safeQuantity;

              final selectedModifiers =
                  sourceItem != null && sourceItem.selectedModifiers.isNotEmpty
                      ? Map<String, List<String>>.from(
                          sourceItem.selectedModifiers,
                        )
                      : domainItem.modifiers.isEmpty
                          ? <String, List<String>>{}
                          : {
                              '__flat__':
                                  List<String>.from(domainItem.modifiers),
                            };

              return CartLineItem(
                id: domainItem.id,
                menuItem: domainItem.menuItem,
                quantity: safeQuantity,
                unitPrice: unitPrice,
                selectedComboId: sourceItem?.selectedComboId,
                selectedModifiers: selectedModifiers,
                modifierSummary: sourceItem?.modifierSummary ?? '',
                specialInstructions: sourceItem?.specialInstructions ??
                    domainItem.specialInstructions,
              );
            }).toList();

            _emitCheckoutLoaded(
              emit,
              CheckoutLoaded(
                payment: CheckoutPaymentState(
                  selectedMethod: result.selectedMethod,
                  cashReceived: result.cashReceived,
                ),
                discounts: CheckoutDiscountState(
                  tipPercent: result.tipPercent,
                  customTipAmount: result.customTipAmount,
                  discountPercent: result.discountPercent,
                  appliedVouchers: result.appliedVouchers,
                  loyaltyRedemption: result.loyaltyRedemption,
                  isLoyaltyRedeemed: result.isLoyaltyRedeemed,
                ),
                splitPayment: CheckoutSplitState(
                  isSplitMode: result.isSplitMode,
                  tenders: result.tenders,
                ),
                cart: CheckoutCartState(
                  items: cartItems,
                  totals: totals,
                  orderType: event.orderType,
                  tableNumber: event.tableNumber,
                  customerName: event.customerName,
                  customerPhone: event.customerPhone,
                  deliveryAddress: event.deliveryAddress,
                ),
              ),
            );
            await _customerDisplayService?.showOrderView();
          },
        );
      },
    );
  }

  Future<void> _onSyncCartItems(
    SyncCartItems event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    final cartSame = _areCartItemsEqual(currentState.items, event.items);
    final contextSame = event.orderType == null &&
        event.tableNumber == null &&
        event.customerName == null &&
        event.customerPhone == null &&
        event.deliveryAddress == null;
    if (cartSame && contextSame) return;

    final updatedCart = currentState.cart.copyWith(
      items: event.items,
      orderType: event.orderType ?? currentState.cart.orderType,
      tableNumber: event.tableNumber ?? currentState.cart.tableNumber,
      customerName: event.customerName ?? currentState.cart.customerName,
      customerPhone: event.customerPhone ?? currentState.cart.customerPhone,
      deliveryAddress: event.deliveryAddress ?? currentState.cart.deliveryAddress,
    );

    await _emitWithRecalculatedTotals(
      emit: emit,
      baseState: currentState,
      cart: updatedCart,
    );
  }

  Future<void> _onSelectPaymentMethod(
    SelectPaymentMethod event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    final updatedPayment = currentState.payment.copyWith(
      selectedMethod: event.method,
      cashReceived: '', // Reset cash when changing method
    );

    await _emitWithRecalculatedTotals(
      emit: emit,
      baseState: currentState,
      payment: updatedPayment,
    );

    if (event.method == PaymentMethodType.cash) {
      await _customerDisplayService?.showCashPaymentView();
    } else {
      await _customerDisplayService?.showCardPaymentView();
    }
  }

  void _onSetOrderNotes(SetOrderNotes event, Emitter<CheckoutState> emit) {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    final updatedCart = currentState.cart.copyWith(orderNotes: event.notes);
    emit(currentState.copyWith(cart: updatedCart));
  }

  Future<void> _onKeypadPress(
    KeypadPress event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    String newValue;
    if (event.key == '⌫') {
      // Backspace
      newValue = currentState.cashReceived.isEmpty
          ? ''
          : currentState.cashReceived.substring(
              0,
              currentState.cashReceived.length - 1,
            );
    } else {
      // Append digit
      if (currentState.cashReceived.toString() == '0' && event.key != '.') {
        newValue = event.key; // Replace leading zero
      } else {
        newValue = currentState.cashReceived.toString() + event.key;
      }
    }

    final updatedPayment =
        currentState.payment.copyWith(cashReceived: newValue);

    await _emitWithRecalculatedTotals(
      emit: emit,
      baseState: currentState,
      payment: updatedPayment,
    );
  }

  Future<void> _onQuickAmountPress(
    QuickAmountPress event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    // If empty or zero, set to quick amount; otherwise add to it (matching React line 106-108)
    final current = currentState.cashReceivedNum;
    final newAmount = current == 0 ? event.amount : current + event.amount;

    final updatedPayment =
        currentState.payment.copyWith(cashReceived: newAmount.toString());

    await _emitWithRecalculatedTotals(
      emit: emit,
      baseState: currentState,
      payment: updatedPayment,
    );
  }

  Future<void> _onSelectTipPercent(
    SelectTipPercent event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    final updatedDiscounts = currentState.discounts.copyWith(
      tipPercent: event.percent,
      customTipAmount: '', // Clear custom tip
    );

    await _emitWithRecalculatedTotals(
      emit: emit,
      baseState: currentState,
      discounts: updatedDiscounts,
    );
  }

  Future<void> _onSetCustomTip(
    SetCustomTip event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    final updatedDiscounts = currentState.discounts.copyWith(
      customTipAmount: event.amount,
      tipPercent: 0, // Clear percentage tip
    );

    await _emitWithRecalculatedTotals(
      emit: emit,
      baseState: currentState,
      discounts: updatedDiscounts,
    );
  }

  Future<void> _onApplyVoucher(
    ApplyVoucher event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    final resultEither = await _applyVoucherUseCase(
      ApplyVoucherParams(code: event.code),
    );

    await resultEither.fold<Future<void>>(
      (failure) async {
        emit(
          CheckoutError(
            message: failure.message,
            canDismiss: true,
            previousState: currentState,
          ),
        );
      },
      (result) async {
        if (result.isSuccess && result.voucher != null) {
          final updatedVouchers = List<VoucherEntity>.from(
            currentState.appliedVouchers,
          )..add(result.voucher!);

          final updatedDiscounts =
              currentState.discounts.copyWith(appliedVouchers: updatedVouchers);

          await _emitWithRecalculatedTotals(
            emit: emit,
            baseState: currentState,
            discounts: updatedDiscounts,
          );
        } else {
          emit(
            CheckoutError(
              message: result.errorMessage ?? 'Failed to apply voucher',
              canDismiss: true,
              previousState: currentState,
            ),
          );
        }
      },
    );
  }

  Future<void> _onRemoveVoucher(
    RemoveVoucher event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    final updatedVouchers =
        currentState.appliedVouchers.where((v) => v.id != event.id).toList();

    final updatedDiscounts =
        currentState.discounts.copyWith(appliedVouchers: updatedVouchers);

    await _emitWithRecalculatedTotals(
      emit: emit,
      baseState: currentState,
      discounts: updatedDiscounts,
    );
  }

  Future<void> _onSetDiscountPercent(
    SetDiscountPercent event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    final updatedDiscounts =
        currentState.discounts.copyWith(discountPercent: event.percent);

    await _emitWithRecalculatedTotals(
      emit: emit,
      baseState: currentState,
      discounts: updatedDiscounts,
    );
  }

  Future<void> _onRedeemLoyaltyPoints(
    RedeemLoyaltyPoints event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    final updatedDiscounts = currentState.discounts.copyWith(
      loyaltyRedemption: event.amount,
      isLoyaltyRedeemed: true,
    );

    await _emitWithRecalculatedTotals(
      emit: emit,
      baseState: currentState,
      discounts: updatedDiscounts,
    );
  }

  Future<void> _onUndoLoyaltyRedemption(
    UndoLoyaltyRedemption event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    final updatedDiscounts = currentState.discounts.copyWith(
      loyaltyRedemption: 0.0,
      isLoyaltyRedeemed: false,
    );

    await _emitWithRecalculatedTotals(
      emit: emit,
      baseState: currentState,
      discounts: updatedDiscounts,
    );
  }

  Future<void> _onToggleSplitMode(
    ToggleSplitMode event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    final updatedSplit = currentState.splitPayment.copyWith(
      isSplitMode: !currentState.isSplitMode,
      tenders: [], // Reset tenders when toggling
    );

    await _emitWithRecalculatedTotals(
      emit: emit,
      baseState: currentState,
      split: updatedSplit,
    );
  }

  Future<void> _onAddTender(
    AddTender event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    final newTender = TenderEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      method: event.method,
      amount: event.amount,
      status: TenderStatus.pending,
      createdAt: DateTime.now(),
    );

    final updatedTenders = List<TenderEntity>.from(currentState.tenders)
      ..add(newTender);

    final updatedSplit =
        currentState.splitPayment.copyWith(tenders: updatedTenders);

    await _emitWithRecalculatedTotals(
      emit: emit,
      baseState: currentState,
      split: updatedSplit,
    );
  }

  Future<void> _onRemoveTender(
    RemoveTender event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    final updatedTenders =
        currentState.tenders.where((t) => t.id != event.id).toList();

    final updatedSplit =
        currentState.splitPayment.copyWith(tenders: updatedTenders);

    await _emitWithRecalculatedTotals(
      emit: emit,
      baseState: currentState,
      split: updatedSplit,
    );
  }

  Future<void> _onSplitEvenly(
    SplitEvenly event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    final amountPerPerson = currentState.grandTotal / event.ways;

    final tenders = List.generate(
      event.ways,
      (index) => TenderEntity(
        id: '${DateTime.now().millisecondsSinceEpoch}_$index',
        method: PaymentMethodType.cash,
        amount: amountPerPerson,
        status: TenderStatus.pending,
        createdAt: DateTime.now(),
      ),
    );

    final updatedSplit = currentState.splitPayment.copyWith(tenders: tenders);

    await _emitWithRecalculatedTotals(
      emit: emit,
      baseState: currentState,
      split: updatedSplit,
    );
  }

  bool _areCartItemsEqual(
    List<CartLineItem> a,
    List<CartLineItem> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  Future<void> _emitWithRecalculatedTotals({
    required Emitter<CheckoutState> emit,
    required CheckoutLoaded baseState,
    CheckoutPaymentState? payment,
    CheckoutDiscountState? discounts,
    CheckoutSplitState? split,
    CheckoutCartState? cart,
  }) async {
    final updatedPayment = payment ?? baseState.payment;
    final updatedDiscounts = discounts ?? baseState.discounts;
    final updatedSplit = split ?? baseState.splitPayment;
    final updatedCart = cart ?? baseState.cart;

    final domainItems = _mapCartItemsToEntities(updatedCart.items);

    try {
      final totalsEither = await _calculateTotalsUseCase(
        CalculateTotalsParams(
          items: domainItems,
          tipPercent: updatedDiscounts.tipPercent,
          customTipAmount: updatedDiscounts.customTipAmount,
          discountPercent: updatedDiscounts.discountPercent,
          appliedVouchers: updatedDiscounts.appliedVouchers,
          loyaltyRedemption: updatedDiscounts.loyaltyRedemption,
          tenders: updatedSplit.tenders,
          isSplitMode: updatedSplit.isSplitMode,
          selectedMethod: updatedPayment.selectedMethod,
          cashReceived: updatedPayment.cashReceived,
        ),
      );

      await totalsEither.fold<Future<void>>(
        (failure) async {
          emit(
            CheckoutError(
              message: failure.message,
              canDismiss: true,
              previousState: baseState,
            ),
          );
        },
        (totals) async {
          _emitCheckoutLoaded(
            emit,
            baseState.copyWith(
              payment: updatedPayment,
              discounts: updatedDiscounts,
              splitPayment: updatedSplit,
              cart: updatedCart.copyWith(totals: totals),
            ),
          );
        },
      );
    } catch (error) {
      emit(
        CheckoutError(
          message: 'Failed to update totals: $error',
          canDismiss: true,
          previousState: baseState,
        ),
      );
    }
  }

  List<CartLineItemEntity> _mapCartItemsToEntities(List<CartLineItem> items) {
    return items
        .map(
          (item) => CartLineItemEntity(
            id: item.id,
            menuItem: item.menuItem,
            quantity: item.quantity,
            lineTotal: item.lineTotal,
            modifiers: item.selectedModifiers.values
                .expand((options) => options)
                .toList(),
            specialInstructions: item.specialInstructions?.trim().isNotEmpty == true
                ? item.specialInstructions!.trim()
                : null,
          ),
        )
        .toList();
  }

  void _onProcessPayment(
    ProcessPayment event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    if (!currentState.canPay) {
      emit(
        CheckoutError(
          message:
              'Insufficient payment amount. Please adjust payment method or amount.',
          canDismiss: true,
          previousState: currentState,
        ),
      );
      return;
    }

    emit(CheckoutProcessing());

    final items = _toBookOrderItemInputs(currentState.items);
    final serviceType = _orderTypeToServiceType(currentState.cart.orderType);
    final paymentMethod = currentState.selectedMethod.value;
    final tableNumber = serviceType == 'DINE_IN'
        ? currentState.cart.tableNumber
        : null;
    final eater = _eaterFromCart(currentState.cart, serviceType);
    const deliveryFeeAmount = 5.0;
    final deliveryFee = serviceType == 'DELIVERY' ? deliveryFeeAmount : 0.0;
    final total = serviceType == 'DELIVERY'
        ? currentState.subtotal + currentState.tax + deliveryFee
        : currentState.grandTotal;
    final address = serviceType == 'DELIVERY'
        ? (currentState.cart.deliveryAddress ?? '456 POS St, Sydney NSW')
        : null;
    final notes = (currentState.cart.orderNotes?.trim().isNotEmpty == true)
        ? currentState.cart.orderNotes!.trim()
        : null;

    final resultEither = await _bookOrderUseCase(
      BookOrderParams(
        items: items,
        serviceType: serviceType,
        placedAt: DateTime.now(),
        subtotal: currentState.subtotal,
        tax: currentState.tax,
        total: total,
        deliveryFee: deliveryFee,
        tip: currentState.tipAmount,
        paymentMethod: paymentMethod,
        eaterFirstName: eater.$1,
        eaterLastName: eater.$2,
        eaterPhone: eater.$3,
        eaterEmail: eater.$4,
        tableNumber: tableNumber,
        address: address,
        notes: notes,
      ),
    );

    await resultEither.fold<Future<void>>(
      (failure) async {
        emit(
          CheckoutError(
            message: failure.message,
            canDismiss: true,
            previousState: currentState,
          ),
        );
        await _customerDisplayService?.showPaymentErrorView();
      },
      (bookResult) async {
        final orderId = bookResult.displayId.isNotEmpty
            ? bookResult.displayId
            : '${bookResult.orderId}';
        final receiptText = _buildReceiptText(
          currentState,
          orderId,
          currentState.grandTotal,
        );
        emit(
          CheckoutSuccess(
            orderId: orderId,
            paidAmount: currentState.grandTotal,
            receiptText: receiptText,
          ),
        );

        if (currentState.selectedMethod == PaymentMethodType.cash &&
            currentState.cashChange > 0) {
          await _customerDisplayService?.showChangeDueView(
            changeDue: currentState.cashChange,
          );
        } else {
          await _customerDisplayService?.showPaymentApprovedView(
            paymentType: currentState.selectedMethod.value,
          );
        }
      },
    );
  }

  void _onPayLater(PayLater event, Emitter<CheckoutState> emit) async {
    final currentState = _currentLoadedState();
    if (currentState == null) return;

    emit(CheckoutProcessing());

    final items = _toBookOrderItemInputs(currentState.items);
    final serviceType = _orderTypeToServiceType(currentState.cart.orderType);
    final tableNumber = serviceType == 'DINE_IN'
        ? currentState.cart.tableNumber
        : null;
    final eater = _eaterFromCart(currentState.cart, serviceType);
    const deliveryFeeAmount = 5.0;
    final deliveryFee = serviceType == 'DELIVERY' ? deliveryFeeAmount : 0.0;
    final total = serviceType == 'DELIVERY'
        ? currentState.subtotal + currentState.tax + deliveryFee
        : currentState.grandTotal;
    final address = serviceType == 'DELIVERY'
        ? (currentState.cart.deliveryAddress ?? '456 POS St, Sydney NSW')
        : null;
    final notes = (currentState.cart.orderNotes?.trim().isNotEmpty == true)
        ? currentState.cart.orderNotes!.trim()
        : null;

    final resultEither = await _bookOrderUseCase(
      BookOrderParams(
        items: items,
        serviceType: serviceType,
        placedAt: DateTime.now(),
        subtotal: currentState.subtotal,
        tax: currentState.tax,
        total: total,
        deliveryFee: deliveryFee,
        tip: currentState.tipAmount,
        paymentMethod: 'pay_later',
        eaterFirstName: eater.$1,
        eaterLastName: eater.$2,
        eaterPhone: eater.$3,
        eaterEmail: eater.$4,
        tableNumber: tableNumber,
        address: address,
        notes: notes,
      ),
    );

    await resultEither.fold<Future<void>>(
      (failure) async {
        emit(
          CheckoutError(
            message: failure.message,
            canDismiss: true,
            previousState: currentState,
          ),
        );
      },
      (bookResult) async {
        final orderId = bookResult.displayId.isNotEmpty
            ? bookResult.displayId
            : '${bookResult.orderId}';
        final receiptText = _buildReceiptText(currentState, orderId, 0.0);
        emit(
          CheckoutSuccess(
            orderId: orderId,
            paidAmount: 0.0, // Unpaid
            receiptText: receiptText,
          ),
        );
      },
    );
  }

  List<BookOrderItemInput> _toBookOrderItemInputs(List<CartLineItem> items) {
    return items
        .map(
          (item) => BookOrderItemInput(
            id: item.id,
            menuItem: item.menuItem,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            selectedModifiers: Map<String, List<String>>.from(item.selectedModifiers),
            modifierSummary: item.modifierSummary,
            specialInstructions: item.specialInstructions,
          ),
        )
        .toList();
  }

  String _orderTypeToServiceType(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return 'DINE_IN';
      case OrderType.delivery:
        return 'DELIVERY';
      case OrderType.takeaway:
        return 'PICK_UP'; // API expects PICK_UP, not TAKEAWAY
    }
  }

  /// Eater fields for book-order API. Uses customer name/phone from cart when given; otherwise null.
  (String?, String?, String?, String?) _eaterFromCart(
    CheckoutCartState cart,
    String serviceType,
  ) {
    final name = cart.customerName?.trim();
    final rawPhone = cart.customerPhone?.trim();
    final phone = rawPhone != null && rawPhone.isNotEmpty ? rawPhone : null;

    String? firstName;
    String? lastName;
    if (name != null && name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      firstName = parts.isNotEmpty ? parts.first : null;
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : null;
    }

    String? email;
    if (name != null && name.isNotEmpty || phone != null) {
      email = null; // Customer from takeaway: send null for email
    } else {
      switch (serviceType) {
        case 'DINE_IN':
          email = 'posdine@example.com';
          break;
        case 'DELIVERY':
          email = 'posdelivery@example.com';
          break;
        case 'PICK_UP':
          email = 'pos@example.com';
          break;
        default:
          email = 'posdine@example.com';
      }
    }

    return (firstName, lastName, phone, email);
  }

  void _onDismissError(DismissError event, Emitter<CheckoutState> emit) {
    // For now, emit initial state - in a real app you'd want to store previous state
    // This could be improved by adding a previous state to CheckoutError
    if (state is CheckoutError) {
      if (_lastKnownLoadedState != null) {
        emit(_lastKnownLoadedState!);
      } else {
        emit(CheckoutInitial());
      }
    }
  }

  String _buildReceiptText(
    CheckoutLoaded state,
    String orderId,
    double paidAmount,
  ) {
    final buf = StringBuffer();
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    buf.writeln('ORDER #$orderId');
    buf.writeln('Date: $dateStr');
    buf.writeln('--------------------------------');
    for (final item in state.items) {
      final name = item.menuItem.name.length > 20
          ? '${item.menuItem.name.substring(0, 17)}...'
          : item.menuItem.name;
      buf.writeln(name);
      buf.writeln(
          '  ${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)} = \$${item.lineTotal.toStringAsFixed(2)}');
    }
    buf.writeln('--------------------------------');
    buf.writeln('Subtotal:    \$${state.subtotal.toStringAsFixed(2)}');
    buf.writeln('Tax:         \$${state.tax.toStringAsFixed(2)}');
    buf.writeln('Total:       \$${state.grandTotal.toStringAsFixed(2)}');
    buf.writeln('Paid:        \$${paidAmount.toStringAsFixed(2)}');
    buf.writeln('--------------------------------');
    buf.writeln('Thank you!');

    return buf.toString();
  }

  void _emitCheckoutLoaded(
    Emitter<CheckoutState> emit,
    CheckoutLoaded state,
  ) {
    _lastKnownLoadedState = state;
    emit(state);
  }
}
