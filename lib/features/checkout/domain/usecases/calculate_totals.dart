import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import '../entities/voucher_entity.dart';
import '../entities/tender_entity.dart';
import '../entities/tender_status.dart';
import '../entities/payment_method_type.dart';
import '../entities/cart_line_item_entity.dart';

class CalculateTotalsUseCase {
  CalculateTotalsUseCase();

  CalculateTotalsResult call(CalculateTotalsParams params) {
    // Calculate subtotal
    final subtotal =
        params.items.fold(0.0, (sum, item) => sum + item.lineTotal);

    // Calculate tip amount
    double tipAmount = 0.0;
    if (params.tipPercent > 0) {
      tipAmount = (subtotal * params.tipPercent) / 100;
    } else {
      tipAmount = double.tryParse(params.customTipAmount) ?? 0.0;
    }

    // Calculate discount amount
    final discountAmount = (subtotal * params.discountPercent) / 100;

    // Calculate voucher total
    final voucherTotal = params.appliedVouchers
        .fold(0.0, (sum, voucher) => sum + voucher.amount);

    // Calculate total before tax
    final totalBeforeTax = math.max(
      0.0,
      subtotal +
          tipAmount -
          discountAmount -
          voucherTotal -
          params.loyaltyRedemption,
    );

    // Calculate tax (10% GST)
    final tax = totalBeforeTax * 0.10;

    // Calculate grand total
    final grandTotal = math.max(0.0, totalBeforeTax + tax);

    // Calculate cash received number
    final cashReceivedNum =
        double.tryParse(params.cashReceived.toString().replaceAll(',', '')) ??
            0.0;

    // Calculate cash change
    final cashChange = math.max(0.0, cashReceivedNum - grandTotal);

    // Calculate item count
    final itemCount = params.items.fold(0, (sum, item) => sum + item.quantity);

    // Split payment calculations
    final splitPaidTotal = params.tenders
        .where((t) => t.status == TenderStatus.approved)
        .fold(0.0, (sum, tender) => sum + tender.amount);

    final splitRemaining = math.max(0.0, grandTotal - splitPaidTotal);

    final canCompleteSplit = splitRemaining == 0 &&
        params.tenders.isNotEmpty &&
        params.tenders.every((t) => t.status == TenderStatus.approved);

    // Payment validation
    final canPayCash = params.selectedMethod == PaymentMethodType.cash &&
        cashReceivedNum >= grandTotal;

    final canPayNonCash = params.selectedMethod != PaymentMethodType.cash;

    bool canPay;
    if (params.isSplitMode) {
      canPay = canCompleteSplit;
    } else {
      canPay = params.selectedMethod == PaymentMethodType.cash
          ? canPayCash
          : canPayNonCash;
    }

    return CalculateTotalsResult(
      subtotal: subtotal,
      tipAmount: tipAmount,
      discountAmount: discountAmount,
      voucherTotal: voucherTotal,
      totalBeforeTax: totalBeforeTax,
      tax: tax,
      grandTotal: grandTotal,
      cashReceivedNum: cashReceivedNum,
      cashChange: cashChange,
      itemCount: itemCount,
      splitPaidTotal: splitPaidTotal,
      splitRemaining: splitRemaining,
      canCompleteSplit: canCompleteSplit,
      canPayCash: canPayCash,
      canPayNonCash: canPayNonCash,
      canPay: canPay,
    );
  }
}

class CalculateTotalsParams extends Equatable {
  final List<CartLineItemEntity> items;
  final int tipPercent;
  final String customTipAmount;
  final int discountPercent;
  final List<VoucherEntity> appliedVouchers;
  final double loyaltyRedemption;
  final List<TenderEntity> tenders;
  final bool isSplitMode;
  final PaymentMethodType selectedMethod;
  final String cashReceived;

  const CalculateTotalsParams({
    required this.items,
    required this.tipPercent,
    required this.customTipAmount,
    required this.discountPercent,
    required this.appliedVouchers,
    required this.loyaltyRedemption,
    required this.tenders,
    required this.isSplitMode,
    required this.selectedMethod,
    required this.cashReceived,
  });

  @override
  List<Object?> get props => [
        items,
        tipPercent,
        customTipAmount,
        discountPercent,
        appliedVouchers,
        loyaltyRedemption,
        tenders,
        isSplitMode,
        selectedMethod,
        cashReceived,
      ];
}

class CalculateTotalsResult extends Equatable {
  final double subtotal;
  final double tipAmount;
  final double discountAmount;
  final double voucherTotal;
  final double totalBeforeTax;
  final double tax;
  final double grandTotal;
  final double cashReceivedNum;
  final double cashChange;
  final int itemCount;
  final double splitPaidTotal;
  final double splitRemaining;
  final bool canCompleteSplit;
  final bool canPayCash;
  final bool canPayNonCash;
  final bool canPay;

  const CalculateTotalsResult({
    required this.subtotal,
    required this.tipAmount,
    required this.discountAmount,
    required this.voucherTotal,
    required this.totalBeforeTax,
    required this.tax,
    required this.grandTotal,
    required this.cashReceivedNum,
    required this.cashChange,
    required this.itemCount,
    required this.splitPaidTotal,
    required this.splitRemaining,
    required this.canCompleteSplit,
    required this.canPayCash,
    required this.canPayNonCash,
    required this.canPay,
  });

  @override
  List<Object?> get props => [
        subtotal,
        tipAmount,
        discountAmount,
        voucherTotal,
        totalBeforeTax,
        tax,
        grandTotal,
        cashReceivedNum,
        cashChange,
        itemCount,
        splitPaidTotal,
        splitRemaining,
        canCompleteSplit,
        canPayCash,
        canPayNonCash,
        canPay,
      ];
}
