import 'package:equatable/equatable.dart';

/// Represents an applied voucher/discount code
class VoucherEntity extends Equatable {
  final String id;
  final String code;
  final double amount;
  final DateTime appliedAt;

  const VoucherEntity({
    required this.id,
    required this.code,
    required this.amount,
    required this.appliedAt,
  });

  @override
  List<Object?> get props => [id, code, amount, appliedAt];
}
