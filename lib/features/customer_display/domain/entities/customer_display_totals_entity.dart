import 'package:equatable/equatable.dart';

/// Aggregated totals for the currently displayed order
class CustomerDisplayTotalsEntity extends Equatable {
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final double cashReceived;
  final double changeDue;

  const CustomerDisplayTotalsEntity({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.cashReceived,
    required this.changeDue,
  });

  bool get hasDiscount => discount > 0;

  bool get hasCashPayment => cashReceived > 0;

  @override
  List<Object?> get props => [
        subtotal,
        discount,
        tax,
        total,
        cashReceived,
        changeDue,
      ];
}
