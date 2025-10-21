import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/tender_entity.dart';
import '../../domain/entities/voucher_entity.dart';
import '../../domain/entities/payment_method_type.dart';
import '../../domain/entities/tender_status.dart';
import '../../domain/entities/checkout_metadata_entity.dart';
import '../../../checkout/domain/usecases/initialize_checkout.dart';
import '../../../checkout/domain/usecases/process_payment.dart';
import '../../../checkout/domain/usecases/apply_voucher.dart';
import '../../../checkout/domain/usecases/calculate_totals.dart';
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

class CheckoutLoaded extends CheckoutState {
  // Mode
  final bool isSplitMode;

  // Payment
  final PaymentMethodType selectedMethod;
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

  // Calculated totals (from use case)
  final CalculateTotalsResult? totals;

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
    this.totals,
  });

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

  CheckoutLoaded copyWith({
    bool? isSplitMode,
    PaymentMethodType? selectedMethod,
    String? cashReceived,
    int? tipPercent,
    String? customTipAmount,
    int? discountPercent,
    List<VoucherEntity>? appliedVouchers,
    double? loyaltyRedemption,
    bool? isLoyaltyRedeemed,
    List<TenderEntity>? tenders,
    List<CartLineItem>? items,
    CalculateTotalsResult? totals,
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
      totals: totals ?? this.totals,
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
        totals,
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
  }

  void _onInitializeCheckout(
    InitializeCheckout event,
    Emitter<CheckoutState> emit,
  ) {
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

    final result = _initializeCheckoutUseCase(
      InitializeCheckoutParams(items: domainItems),
    );

    // Calculate totals using use case
    final totals = _calculateTotalsUseCase(
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

    emit(
      CheckoutLoaded(
        isSplitMode: result.isSplitMode,
        selectedMethod: result.selectedMethod,
        cashReceived: result.cashReceived,
        tipPercent: result.tipPercent,
        customTipAmount: result.customTipAmount,
        discountPercent: result.discountPercent,
        appliedVouchers: result.appliedVouchers,
        loyaltyRedemption: result.loyaltyRedemption,
        isLoyaltyRedeemed: result.isLoyaltyRedeemed,
        tenders: result.tenders,
        items: result.items
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
                    recommendedAddOnIds:
                        domainItem.menuItem.recommendedAddOnIds,
                    image: domainItem.menuItem.image,
                  ),
                  quantity: domainItem.quantity,
                  unitPrice: domainItem.menuItem.basePrice,
                  selectedModifiers: {},
                  modifierSummary: domainItem.specialInstructions ?? '',
                ))
            .toList(),
        totals: totals,
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
      if (currentState.cashReceived.toString() == '0' && event.key != '.') {
        newValue = event.key; // Replace leading zero
      } else {
        newValue = currentState.cashReceived.toString() + event.key;
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

  void _onApplyVoucher(ApplyVoucher event, Emitter<CheckoutState> emit) async {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    final result = await _applyVoucherUseCase(
      ApplyVoucherParams(code: event.code),
    );

    if (result.isSuccess && result.voucher != null) {
      final updatedVouchers = List<VoucherEntity>.from(
        currentState.appliedVouchers,
      )..add(result.voucher!);

      emit(currentState.copyWith(appliedVouchers: updatedVouchers));
    } else {
      // Handle error - could emit error state or show snackbar
      emit(CheckoutError(
          message: result.errorMessage ?? 'Failed to apply voucher'));
      emit(currentState); // Return to previous state
    }
  }

  void _onRemoveVoucher(RemoveVoucher event, Emitter<CheckoutState> emit) {
    if (state is! CheckoutLoaded) return;
    final currentState = state as CheckoutLoaded;

    final updatedVouchers =
        currentState.appliedVouchers.where((v) => v.id != event.id).toList();

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

    final updatedTenders =
        currentState.tenders.where((t) => t.id != event.id).toList();

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
        method: PaymentMethodType.cash,
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

    final result = await _processPaymentUseCase(
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

    if (result.isSuccess) {
      emit(
        CheckoutSuccess(
          orderId: result.orderId!,
          paidAmount: result.paidAmount!,
        ),
      );
    } else {
      emit(CheckoutError(message: result.errorMessage ?? 'Payment failed'));
      emit(currentState); // Return to previous state
    }
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
}
