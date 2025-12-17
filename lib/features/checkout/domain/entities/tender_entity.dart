import 'package:equatable/equatable.dart';
import 'payment_method_type.dart';
import 'tender_status.dart';

class TenderEntity extends Equatable {
  final String id;
  final PaymentMethodType method;
  final double amount;
  final TenderStatus status;
  final String? authorizationId;
  final String? errorMessage;
  final DateTime createdAt;

  const TenderEntity({
    required this.id,
    required this.method,
    required this.amount,
    required this.status,
    this.authorizationId,
    this.errorMessage,
    required this.createdAt,
  });

  factory TenderEntity.fromJson(Map<String, dynamic> json) {
    return TenderEntity(
      id: json['id'],
      method: PaymentMethodType.fromString(json['method']),
      amount: json['amount'],
      status: TenderStatus.fromString(json['status']),
      authorizationId: json['authorizationId'],
      createdAt: DateTime.parse(json['createdAt']),
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method.value,
      'amount': amount,
      'status': status.value,
      'authorizationId': authorizationId,
      'createdAt': createdAt.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  TenderEntity copyWith({
    String? id,
    PaymentMethodType? method,
    double? amount,
    TenderStatus? status,
    String? authorizationId,
    String? errorMessage,
    DateTime? createdAt,
  }) {
    return TenderEntity(
      id: id ?? this.id,
      method: method ?? this.method,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      authorizationId: authorizationId ?? this.authorizationId,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        method,
        amount,
        status,
        authorizationId,
        errorMessage,
        createdAt,
      ];
}
