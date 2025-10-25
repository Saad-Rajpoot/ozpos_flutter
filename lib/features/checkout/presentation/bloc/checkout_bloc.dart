import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/tender_entity.dart';
import '../../domain/entities/voucher_entity.dart';
import '../../domain/entities/payment_method_type.dart';
import '../../domain/entities/tender_status.dart';
import '../../domain/entities/checkout_metadata_entity.dart';
import '../../domain/usecases/initialize_checkout.dart';
import '../../domain/usecases/process_payment.dart';
import '../../domain/usecases/apply_voucher.dart';
import '../../domain/usecases/calculate_totals.dart';
import '../../domain/entities/cart_line_item_entity.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import './cart_bloc.dart';

// ============================================================================
// CHECKOUT STATE
// ============================================================================

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
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

  const CheckoutCartState({
    required this.items,
    this.totals,
  });

  CheckoutCartState copyWith({
    List<CartLineItem>? items,
    CalculateTotalsResult? totals,
  }) {
    return CheckoutCartState(
      items: items ?? this.items,
      totals: totals ?? this.totals,
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
  List<Object?> get props => [items, totals];
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

  const CheckoutSuccess({required this.orderId, required this.paidAmount});

  @override
  List<Object?> get props => [orderId, paidAmount];
}

class CheckoutError extends CheckoutState {
  final String message;
  final DateTime timestamp;
  final bool canDismiss;

  CheckoutError({
    required this.message,
    this.canDismiss = true,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  CheckoutError copyWith({
    String? message,
    bool? canDismiss,
    DateTime? timestamp,
  }) {
    return CheckoutError(
      message: message ?? this.message,
      canDismiss: canDismiss ?? this.canDismiss,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [message, timestamp, canDismiss];
}

// ============================================================================
// CHECKOUT EVENTS
// ============================================================================

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCheckout extends CheckoutEvent {
  final List<CartLineItem> items;

  const InitializeCheckout({required this.items});

  @override
  List<Object?> get props => [items];
}

class SelectPaymentMethod extends CheckoutEvent {
  final PaymentMethodType method;

  const SelectPaymentMethod({required this.method});

  @override
  List<Object?> get props => [method];
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
// CHECKOUT BLOC
// ============================================================================

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final InitializeCheckoutUseCase _initializeCheckoutUseCase;
  final ProcessPaymentUseCase _processPaymentUseCase;
  final ApplyVoucherUseCase _applyVoucherUseCase;
  final CalculateTotalsUseCase _calculateTotalsUseCase;

  CheckoutBloc({
    required InitializeCheckoutUseCase initializeCheckoutUseCase,
    required ProcessPaymentUseCase processPaymentUseCase,
    required ApplyVoucherUseCase applyVoucherUseCase,
    required CalculateTotalsUseCase calculateTotalsUseCase,
  })  : _initializeCheckoutUseCase = initializeCheckoutUseCase,
        _processPaymentUseCase = processPaymentUseCase,
        _applyVoucherUseCase = applyVoucherUseCase,
        _calculateTotalsUseCase = calculateTotalsUseCase,
        super(CheckoutInitial()) {
    on<InitializeCheckout>(_onInitializeCheckout);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
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
    debugPrint(
      '🛒 CheckoutBloc: Initializing with ${event.items.length} items',
    );
    for (var item in event.items) {
      debugPrint(
        '  - ${item.menuItem.name} x${item.quantity} = \$${item.lineTotal}',
      );
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
              specialInstructions: item.modifierSummary,
            ))
        .toList();

    final resultEither = await _initializeCheckoutUseCase(
      InitializeCheckoutParams(items: domainItems),
    );

    final result = resultEither.fold(
      (failure) => throw Exception(failure.message),
      (success) => success,
    );

    // Calculate totals using use case
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

    final totals = totalsEither.fold(
      (failure) => throw Exception(failure.message),
      (success) => success,
    );

    final cartItems = result.items
        .map((domainItem) => CartLineItem(
              id: domainItem.id,
              menuItem: MenuItemEntity(
                id: domainItem.menuItem.id,
                name: domainItem.menuItem.name,
                description: domainItem.menuItem.description,
                categoryId: domainItem.menuItem.categoryId,
                basePrice: domainItem.menuItem.basePrice,
                tags: domainItem.menuItem.tags,
                modifierGroups: domainItem.menuItem.modifierGroups,
                comboOptions: domainItem.menuItem.comboOptions,
                recommendedAddOnIds: domainItem.menuItem.recommendedAddOnIds,
                image: domainItem.menuItem.image,
              ),
              quantity: domainItem.quantity,
              unitPrice: domainItem.menuItem.basePrice,
              selectedModifiers: {},
              modifierSummary: domainItem.specialInstructions ?? '',
            ))
        .toList();

    emit(
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
        ),
      ),
    );
  }

  void _onSelectPaymentMethod(
    SelectPaymentMethod event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    emit(
      currentState.copyWith(
        payment: currentState.payment.copyWith(
          selectedMethod: event.method,
          cashReceived: '', // Reset cash when changing method
        ),
      ),
    );
  }

  void _onKeypadPress(KeypadPress event, Emitter<CheckoutState> emit) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

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

    emit(currentState.copyWith(
      payment: currentState.payment.copyWith(cashReceived: newValue),
    ));
  }

  void _onQuickAmountPress(
    QuickAmountPress event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    // If empty or zero, set to quick amount; otherwise add to it (matching React line 106-108)
    final current = currentState.cashReceivedNum;
    final newAmount = current == 0 ? event.amount : current + event.amount;

    emit(currentState.copyWith(
      payment:
          currentState.payment.copyWith(cashReceived: newAmount.toString()),
    ));
  }

  void _onSelectTipPercent(
    SelectTipPercent event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    emit(
      currentState.copyWith(
        discounts: currentState.discounts.copyWith(
          tipPercent: event.percent,
          customTipAmount: '', // Clear custom tip
        ),
      ),
    );
  }

  void _onSetCustomTip(SetCustomTip event, Emitter<CheckoutState> emit) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    emit(
      currentState.copyWith(
        discounts: currentState.discounts.copyWith(
          customTipAmount: event.amount,
          tipPercent: 0, // Clear percentage tip
        ),
      ),
    );
  }

  void _onApplyVoucher(ApplyVoucher event, Emitter<CheckoutState> emit) async {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    final resultEither = await _applyVoucherUseCase(
      ApplyVoucherParams(code: event.code),
    );

    resultEither.fold(
      (failure) {
        // Handle error - show dismissible error state
        emit(CheckoutError(
          message: failure.message,
          canDismiss: true,
        ));
      },
      (result) {
        if (result.isSuccess && result.voucher != null) {
          final updatedVouchers = List<VoucherEntity>.from(
            currentState.appliedVouchers,
          )..add(result.voucher!);

          emit(currentState.copyWith(
            discounts: currentState.discounts
                .copyWith(appliedVouchers: updatedVouchers),
          ));
        } else {
          // Handle voucher failure - show dismissible error
          emit(CheckoutError(
            message: result.errorMessage ?? 'Failed to apply voucher',
            canDismiss: true,
          ));
        }
      },
    );
  }

  void _onRemoveVoucher(RemoveVoucher event, Emitter<CheckoutState> emit) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    final updatedVouchers =
        currentState.appliedVouchers.where((v) => v.id != event.id).toList();

    emit(currentState.copyWith(
      discounts:
          currentState.discounts.copyWith(appliedVouchers: updatedVouchers),
    ));
  }

  void _onSetDiscountPercent(
    SetDiscountPercent event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    emit(currentState.copyWith(
      discounts:
          currentState.discounts.copyWith(discountPercent: event.percent),
    ));
  }

  void _onRedeemLoyaltyPoints(
    RedeemLoyaltyPoints event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    emit(
      currentState.copyWith(
        discounts: currentState.discounts.copyWith(
          loyaltyRedemption: event.amount,
          isLoyaltyRedeemed: true,
        ),
      ),
    );
  }

  void _onUndoLoyaltyRedemption(
    UndoLoyaltyRedemption event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    emit(
      currentState.copyWith(
        discounts: currentState.discounts.copyWith(
          loyaltyRedemption: 0.0,
          isLoyaltyRedeemed: false,
        ),
      ),
    );
  }

  void _onToggleSplitMode(ToggleSplitMode event, Emitter<CheckoutState> emit) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    emit(
      currentState.copyWith(
        splitPayment: currentState.splitPayment.copyWith(
          isSplitMode: !currentState.isSplitMode,
          tenders: [], // Reset tenders when toggling
        ),
      ),
    );
  }

  void _onAddTender(AddTender event, Emitter<CheckoutState> emit) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    final newTender = TenderEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      method: event.method,
      amount: event.amount,
      status: TenderStatus.pending,
      createdAt: DateTime.now(),
    );

    final updatedTenders = List<TenderEntity>.from(currentState.tenders)
      ..add(newTender);

    emit(currentState.copyWith(
      splitPayment: currentState.splitPayment.copyWith(tenders: updatedTenders),
    ));
  }

  void _onRemoveTender(RemoveTender event, Emitter<CheckoutState> emit) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    final updatedTenders =
        currentState.tenders.where((t) => t.id != event.id).toList();

    emit(currentState.copyWith(
      splitPayment: currentState.splitPayment.copyWith(tenders: updatedTenders),
    ));
  }

  void _onSplitEvenly(SplitEvenly event, Emitter<CheckoutState> emit) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

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

    emit(currentState.copyWith(
      splitPayment: currentState.splitPayment.copyWith(tenders: tenders),
    ));
  }

  void _onProcessPayment(
    ProcessPayment event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    if (!currentState.canPay) {
      emit(CheckoutError(
        message:
            'Insufficient payment amount. Please adjust payment method or amount.',
        canDismiss: true,
      ));
      return;
    }

    emit(CheckoutProcessing());

    final resultEither = await _processPaymentUseCase(
      ProcessPaymentParams(
        paymentMethod: currentState.selectedMethod.value,
        amount: currentState.grandTotal,
        metadata: CheckoutMetadataEntity(
          totalOrders: 0,
          completedOrders: 0,
          pendingOrders: 0,
          totalRevenue: 0.0,
          averageOrderValue: 0.0,
          lastUpdated: DateTime.now(),
        ),
      ),
    );

    resultEither.fold(
      (failure) {
        // Handle payment error - show dismissible error
        emit(CheckoutError(
          message: failure.message,
          canDismiss: true,
        ));
      },
      (result) {
        if (result.isSuccess) {
          emit(
            CheckoutSuccess(
              orderId: result.orderId!,
              paidAmount: result.paidAmount!,
            ),
          );
        } else {
          // Handle payment failure - show dismissible error
          emit(CheckoutError(
            message: result.errorMessage ?? 'Payment failed',
            canDismiss: true,
          ));
        }
      },
    );
  }

  void _onPayLater(PayLater event, Emitter<CheckoutState> emit) async {
    if (state is! CheckoutLoaded) return;

    emit(CheckoutProcessing());

    // Simulate saving unpaid order
    await Future.delayed(const Duration(milliseconds: 500));

    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}-UNPAID';

    emit(
      CheckoutSuccess(
        orderId: orderId,
        paidAmount: 0.0, // Unpaid
      ),
    );
  }

  void _onDismissError(DismissError event, Emitter<CheckoutState> emit) {
    // For now, emit initial state - in a real app you'd want to store previous state
    // This could be improved by adding a previous state to CheckoutError
    if (state is CheckoutError) {
      emit(CheckoutInitial());
    }
  }
}
