import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'payment_method.dart';

/// Status of a tender in split payment
enum TenderStatus {
  pending,
  authorized,
  captured,
  failed,
  voided;

  bool get isSuccessful => this == TenderStatus.authorized || this == TenderStatus.captured;
  bool get isFailed => this == TenderStatus.failed || this == TenderStatus.voided;
  
  String get label {
    switch (this) {
      case TenderStatus.pending:
        return 'Pending';
      case TenderStatus.authorized:
        return 'Authorized';
      case TenderStatus.captured:
        return 'Captured';
      case TenderStatus.failed:
        return 'Failed';
      case TenderStatus.voided:
        return 'Voided';
    }
  }
  
  Color get color {
    switch (this) {
      case TenderStatus.pending:
        return const Color(0xFFFF9800); // Orange
      case TenderStatus.authorized:
      case TenderStatus.captured:
        return const Color(0xFF4CAF50); // Green
      case TenderStatus.failed:
      case TenderStatus.voided:
        return const Color(0xFFD32F2F); // Red
    }
  }
  
  IconData get icon {
    switch (this) {
      case TenderStatus.pending:
        return Icons.access_time;
      case TenderStatus.authorized:
      case TenderStatus.captured:
        return Icons.check_circle;
      case TenderStatus.failed:
      case TenderStatus.voided:
        return Icons.error;
    }
  }
}

/// Represents a single payment tender in split payment mode
class TenderEntity extends Equatable {
  final String id;
  final PaymentMethod method;
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

  TenderEntity copyWith({
    String? id,
    PaymentMethod? method,
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
