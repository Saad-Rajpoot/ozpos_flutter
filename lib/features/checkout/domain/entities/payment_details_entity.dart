import 'package:equatable/equatable.dart';
import 'payment_method_type.dart';

class PaymentDetailsEntity extends Equatable {
  final PaymentMethodType method;
  final double subtotal;
  final double tipAmount;
  final int tipPercent;
  final double discountAmount;
  final int discountPercent;
  final double voucherTotal;
  final double loyaltyRedemption;
  final double tax;
  final double totalBeforeTax;
  final double grandTotal;
  final double cashReceived;
  final double change;

  const PaymentDetailsEntity({
    required this.method,
    required this.subtotal,
    required this.tipAmount,
    required this.tipPercent,
    required this.discountAmount,
    required this.discountPercent,
    required this.voucherTotal,
    required this.loyaltyRedemption,
    required this.tax,
    required this.totalBeforeTax,
    required this.grandTotal,
    required this.cashReceived,
    required this.change,
  });

  @override
  List<Object?> get props => [
        method,
        subtotal,
        tipAmount,
        tipPercent,
        discountAmount,
        discountPercent,
        voucherTotal,
        loyaltyRedemption,
        tax,
        totalBeforeTax,
        grandTotal,
        cashReceived,
        change,
      ];
}
