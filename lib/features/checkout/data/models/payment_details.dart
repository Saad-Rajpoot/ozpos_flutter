import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_details_entity.dart';
import '../../domain/entities/payment_method_type.dart';

// Payment details model
class PaymentDetails extends Equatable {
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

  const PaymentDetails({
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

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      method: PaymentMethodType.fromString(json['method'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      tipAmount: (json['tipAmount'] as num).toDouble(),
      tipPercent: json['tipPercent'] as int,
      discountAmount: (json['discountAmount'] as num).toDouble(),
      discountPercent: json['discountPercent'] as int,
      voucherTotal: (json['voucherTotal'] as num).toDouble(),
      loyaltyRedemption: (json['loyaltyRedemption'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      totalBeforeTax: (json['totalBeforeTax'] as num).toDouble(),
      grandTotal: (json['grandTotal'] as num).toDouble(),
      cashReceived: (json['cashReceived'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method.value,
      'subtotal': subtotal,
      'tipAmount': tipAmount,
      'tipPercent': tipPercent,
      'discountAmount': discountAmount,
      'discountPercent': discountPercent,
      'voucherTotal': voucherTotal,
      'loyaltyRedemption': loyaltyRedemption,
      'tax': tax,
      'totalBeforeTax': totalBeforeTax,
      'grandTotal': grandTotal,
      'cashReceived': cashReceived,
      'change': change,
    };
  }

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

  // Convert to domain entity
  PaymentDetailsEntity toEntity() {
    return PaymentDetailsEntity(
      method: method,
      subtotal: subtotal,
      tipAmount: tipAmount,
      tipPercent: tipPercent,
      discountAmount: discountAmount,
      discountPercent: discountPercent,
      voucherTotal: voucherTotal,
      loyaltyRedemption: loyaltyRedemption,
      tax: tax,
      totalBeforeTax: totalBeforeTax,
      grandTotal: grandTotal,
      cashReceived: cashReceived,
      change: change,
    );
  }

  // Create from domain entity
  factory PaymentDetails.fromEntity(PaymentDetailsEntity entity) {
    return PaymentDetails(
      method: entity.method,
      subtotal: entity.subtotal,
      tipAmount: entity.tipAmount,
      tipPercent: entity.tipPercent,
      discountAmount: entity.discountAmount,
      discountPercent: entity.discountPercent,
      voucherTotal: entity.voucherTotal,
      loyaltyRedemption: entity.loyaltyRedemption,
      tax: entity.tax,
      totalBeforeTax: entity.totalBeforeTax,
      grandTotal: entity.grandTotal,
      cashReceived: entity.cashReceived,
      change: entity.change,
    );
  }
}
