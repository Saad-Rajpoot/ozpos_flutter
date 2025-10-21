import 'package:equatable/equatable.dart';
import '../../domain/entities/voucher_entity.dart';

// Voucher model
class VoucherModel extends Equatable {
  final String id;
  final String code;
  final double amount;
  final DateTime appliedAt;

  const VoucherModel({
    required this.id,
    required this.code,
    required this.amount,
    required this.appliedAt,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] as String,
      code: json['code'] as String,
      amount: (json['amount'] as num).toDouble(),
      appliedAt: DateTime.parse(json['appliedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'amount': amount,
      'appliedAt': appliedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, code, amount, appliedAt];

  // Convert to domain entity
  VoucherEntity toEntity() {
    return VoucherEntity(
      id: id,
      code: code,
      amount: amount,
      appliedAt: appliedAt,
    );
  }

  // Create from domain entity
  factory VoucherModel.fromEntity(VoucherEntity entity) {
    return VoucherModel(
      id: entity.id,
      code: entity.code,
      amount: entity.amount,
      appliedAt: entity.appliedAt,
    );
  }
}
