import 'package:equatable/equatable.dart';

import '../../domain/entities/customer_display_totals_entity.dart';

class CustomerDisplayTotalsModel extends Equatable {
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final double cashReceived;
  final double changeDue;

  const CustomerDisplayTotalsModel({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.cashReceived,
    required this.changeDue,
  });

  factory CustomerDisplayTotalsModel.fromJson(Map<String, dynamic> json) {
    return CustomerDisplayTotalsModel(
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      cashReceived: (json['cashReceived'] as num).toDouble(),
      changeDue: (json['change'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'cashReceived': cashReceived,
      'change': changeDue,
    };
  }

  CustomerDisplayTotalsEntity toEntity() {
    return CustomerDisplayTotalsEntity(
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      cashReceived: cashReceived,
      changeDue: changeDue,
    );
  }

  factory CustomerDisplayTotalsModel.fromEntity(
      CustomerDisplayTotalsEntity entity) {
    return CustomerDisplayTotalsModel(
      subtotal: entity.subtotal,
      discount: entity.discount,
      tax: entity.tax,
      total: entity.total,
      cashReceived: entity.cashReceived,
      changeDue: entity.changeDue,
    );
  }

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
