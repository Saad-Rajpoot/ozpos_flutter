import 'package:equatable/equatable.dart';
import '../../domain/entities/tender_entity.dart';
import '../../domain/entities/payment_method_type.dart';
import '../../domain/entities/tender_status.dart';

// Tender model
class TenderModel extends Equatable {
  final String id;
  final PaymentMethodType method;
  final double amount;
  final TenderStatus status;
  final DateTime createdAt;

  const TenderModel({
    required this.id,
    required this.method,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory TenderModel.fromJson(Map<String, dynamic> json) {
    return TenderModel(
      id: json['id'] as String,
      method: PaymentMethodType.fromString(json['method'] as String),
      amount: (json['amount'] as num).toDouble(),
      status: TenderStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method.value,
      'amount': amount,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, method, amount, status, createdAt];

  // Convert to domain entity
  TenderEntity toEntity() {
    return TenderEntity(
      id: id,
      method: method,
      amount: amount,
      status: status,
      createdAt: createdAt,
    );
  }

  // Create from domain entity
  factory TenderModel.fromEntity(TenderEntity entity) {
    return TenderModel(
      id: entity.id,
      method: entity.method,
      amount: entity.amount,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }
}
