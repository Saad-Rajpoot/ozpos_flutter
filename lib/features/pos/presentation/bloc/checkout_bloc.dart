import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/tender_entity.dart';
import '../../domain/entities/voucher_entity.dart';
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

class CheckoutLoaded extends CheckoutState {
  // Mode
  final bool isSplitMode;

  // Payment
  final PaymentMethod selectedMethod;
  final String cashReceived; // String for keypad entry

  // Tips
  final int tipPercent; // 0, 5, 10, 15
  final String customTipAmount;

  // Discounts
  final int discountPercent; // 0, 5, 10, 15
  final List<VoucherEntity> appliedVouchers;
  final double loyaltyRedemption;
  final bool isLoyaltyRedeemed;

  // Split payment
  final List<TenderEntity> tenders;

  // Cart items
  final List<CartLineItem> items;

  const CheckoutLoaded({
    required this.isSplitMode,
    required this.selectedMethod,
    required this.cashReceived,
    required this.tipPercent,
    required this.customTipAmount,
    required this.discountPercent,
    required this.appliedVouchers,
    required this.loyaltyRedemption,
    required this.isLoyaltyRedeemed,
    required this.tenders,
    required this.items,
  });

  // Calculated properties (matching React lines 72-82)
  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  double get tipAmount {
    if (tipPercent > 0) {
      return (subtotal * tipPercent) / 100;
    }
    return double.tryParse(customTipAmount) ?? 0.0;
  }

  double get discountAmount {
    return (subtotal * discountPercent) / 100;
  }

  double get voucherTotal {
    return appliedVouchers.fold(0.0, (sum, voucher) => sum + voucher.amount);
  }

  double get totalBeforeTax {
    return math.max(
      0.0,
      subtotal + tipAmount - discountAmount - voucherTotal - loyaltyRedemption,
    );
  }

  double get tax {
    return totalBeforeTax * 0.10; // 10% GST
  }

  double get grandTotal {
    return math.max(0.0, totalBeforeTax + tax);
  }

  double get cashReceivedNum {
    // Handle decimal point in string
    return double.tryParse(cashReceived.replaceAll(',', '')) ?? 0.0;
  }

  double get cashChange {
    return math.max(0.0, cashReceivedNum - grandTotal);
  }

  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Split payment calculations
  double get splitPaidTotal {
    return tenders
        .where((t) => t.status.isSuccessful)
        .fold(0.0, (sum, tender) => sum + tender.amount);
  }

  double get splitRemaining {
    return math.max(0.0, grandTotal - splitPaidTotal);
  }

  bool get canCompleteSplit {
    return splitRemaining == 0 &&
        tenders.isNotEmpty &&
        tenders.every((t) => t.status.isSuccessful);
  }

  // Payment validation
  bool get canPayCash {
    return selectedMethod == PaymentMethod.cash &&
        cashReceivedNum >= grandTotal;
  }

  bool get canPayNonCash {
    return selectedMethod != PaymentMethod.cash;
  }

  bool get canPay {
    if (isSplitMode) {
      return canCompleteSplit;
    }
    return selectedMethod == PaymentMethod.cash ? canPayCash : canPayNonCash;
  }

  CheckoutLoaded copyWith({
    bool? isSplitMode,
    PaymentMethod? selectedMethod,
    String? cashReceived,
    int? tipPercent,
    String? customTipAmount,
    int? discountPercent,
    List<VoucherEntity>? appliedVouchers,
    double? loyaltyRedemption,
    bool? isLoyaltyRedeemed,
    List<TenderEntity>? tenders,
    List<CartLineItem>? items,
  }) {
    return CheckoutLoaded(
      isSplitMode: isSplitMode ?? this.isSplitMode,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      cashReceived: cashReceived ?? this.cashReceived,
      tipPercent: tipPercent ?? this.tipPercent,
      customTipAmount: customTipAmount ?? this.customTipAmount,
      discountPercent: discountPercent ?? this.discountPercent,
      appliedVouchers: appliedVouchers ?? this.appliedVouchers,
      loyaltyRedemption: loyaltyRedemption ?? this.loyaltyRedemption,
      isLoyaltyRedeemed: isLoyaltyRedeemed ?? this.isLoyaltyRedeemed,
      tenders: tenders ?? this.tenders,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
    isSplitMode,
    selectedMethod,
    cashReceived,
    tipPercent,
    customTipAmount,
    discountPercent,
    appliedVouchers,
    loyaltyRedemption,
    isLoyaltyRedeemed,
    tenders,
    items,
  ];
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

  const CheckoutError({required this.message});

  @override
  List<Object?> get props => [message];
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
  final PaymentMethod method;

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
  final PaymentMethod method;
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

// ============================================================================
// CHECKOUT BLOC
// ============================================================================

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc() : super(CheckoutInitial()) {
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
  }

  void _onInitializeCheckout(
    InitializeCheckout event,
    Emitter<CheckoutState> emit,
  ) {
    emit(
      CheckoutLoaded(
        isSplitMode: false,
        selectedMethod: PaymentMethod.cash,
        cashReceived: '',
        tipPercent: 0,
        customTipAmount: '',
        discountPercent: 0,
        appliedVouchers: const [],
        loyaltyRedemption: 0.0,
        isLoyaltyRedeemed: false,
        tenders: const [],
        items: event.items,
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
        selectedMethod: event.method,
        cashReceived: '', // Reset cash when changing method
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
      if (currentState.cashReceived == '0' && event.key != '.') {
        newValue = event.key; // Replace leading zero
      } else {
        newValue = currentState.cashReceived + event.key;
      }
    }

    emit(currentState.copyWith(cashReceived: newValue));
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

    emit(currentState.copyWith(cashReceived: newAmount.toString()));
  }

  void _onSelectTipPercent(
    SelectTipPercent event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    emit(
      currentState.copyWith(
        tipPercent: event.percent,
        customTipAmount: '', // Clear custom tip
      ),
    );
  }

  void _onSetCustomTip(SetCustomTip event, Emitter<CheckoutState> emit) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    emit(
      currentState.copyWith(
        customTipAmount: event.amount,
        tipPercent: 0, // Clear percentage tip
      ),
    );
  }

  void _onApplyVoucher(ApplyVoucher event, Emitter<CheckoutState> emit) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    if (event.code.trim().isEmpty) return;

    // Simple voucher validation (matching React lines 111-120)
    double voucherAmount = 10.0; // Default
    final code = event.code.toLowerCase();

    if (code.contains('save5')) voucherAmount = 5.0;
    if (code.contains('save15')) voucherAmount = 15.0;
    if (code.contains('save20')) voucherAmount = 20.0;

    final newVoucher = VoucherEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      code: event.code,
      amount: voucherAmount,
      appliedAt: DateTime.now(),
    );

    final updatedVouchers = List<VoucherEntity>.from(
      currentState.appliedVouchers,
    )..add(newVoucher);

    emit(currentState.copyWith(appliedVouchers: updatedVouchers));
  }

  void _onRemoveVoucher(RemoveVoucher event, Emitter<CheckoutState> emit) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    final updatedVouchers = currentState.appliedVouchers
        .where((v) => v.id != event.id)
        .toList();

    emit(currentState.copyWith(appliedVouchers: updatedVouchers));
  }

  void _onSetDiscountPercent(
    SetDiscountPercent event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    emit(currentState.copyWith(discountPercent: event.percent));
  }

  void _onRedeemLoyaltyPoints(
    RedeemLoyaltyPoints event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    emit(
      currentState.copyWith(
        loyaltyRedemption: event.amount,
        isLoyaltyRedeemed: true,
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
      currentState.copyWith(loyaltyRedemption: 0.0, isLoyaltyRedeemed: false),
    );
  }

  void _onToggleSplitMode(ToggleSplitMode event, Emitter<CheckoutState> emit) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    emit(
      currentState.copyWith(
        isSplitMode: !currentState.isSplitMode,
        tenders: [], // Reset tenders when toggling
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

    emit(currentState.copyWith(tenders: updatedTenders));
  }

  void _onRemoveTender(RemoveTender event, Emitter<CheckoutState> emit) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    final updatedTenders = currentState.tenders
        .where((t) => t.id != event.id)
        .toList();

    emit(currentState.copyWith(tenders: updatedTenders));
  }

  void _onSplitEvenly(SplitEvenly event, Emitter<CheckoutState> emit) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    final amountPerPerson = currentState.grandTotal / event.ways;

    final tenders = List.generate(
      event.ways,
      (index) => TenderEntity(
        id: '${DateTime.now().millisecondsSinceEpoch}_$index',
        method: PaymentMethod.cash,
        amount: amountPerPerson,
        status: TenderStatus.pending,
        createdAt: DateTime.now(),
      ),
    );

    emit(currentState.copyWith(tenders: tenders));
  }

  void _onProcessPayment(
    ProcessPayment event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    if (!currentState.canPay) {
      emit(const CheckoutError(message: 'Insufficient payment'));
      emit(currentState);
      return;
    }

    emit(CheckoutProcessing());

    // Simulate payment processing
    await Future.delayed(const Duration(milliseconds: 800));

    // TODO: Actual payment processing through use cases
    // - For cash: record transaction
    // - For card/wallet/BNPL: create payment intent server-side
    // - For split: process all tenders

    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    emit(
      CheckoutSuccess(orderId: orderId, paidAmount: currentState.grandTotal),
    );
  }

  void _onPayLater(PayLater event, Emitter<CheckoutState> emit) async {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

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
}
