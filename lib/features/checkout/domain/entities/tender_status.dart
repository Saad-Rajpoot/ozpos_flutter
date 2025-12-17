import 'package:flutter/material.dart';

enum TenderStatus {
  pending('pending'),
  authorized('authorized'),
  captured('captured'),
  failed('failed'),
  voided('voided'),
  approved('approved'),
  declined('declined'),
  refunded('refunded');

  const TenderStatus(this.value);
  final String value;

  bool get isSuccessful =>
      this == TenderStatus.authorized ||
      this == TenderStatus.captured ||
      this == TenderStatus.approved;

  bool get isFailed =>
      this == TenderStatus.failed ||
      this == TenderStatus.voided ||
      this == TenderStatus.declined;

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
      case TenderStatus.approved:
        return 'Approved';
      case TenderStatus.declined:
        return 'Declined';
      case TenderStatus.refunded:
        return 'Refunded';
    }
  }

  Color get color {
    switch (this) {
      case TenderStatus.pending:
        return const Color(0xFFFF9800); // Orange
      case TenderStatus.authorized:
      case TenderStatus.captured:
      case TenderStatus.approved:
        return const Color(0xFF4CAF50); // Green
      case TenderStatus.failed:
      case TenderStatus.voided:
      case TenderStatus.declined:
        return const Color(0xFFD32F2F); // Red
      case TenderStatus.refunded:
        return const Color(0xFF2196F3); // Blue
    }
  }

  IconData get icon {
    switch (this) {
      case TenderStatus.pending:
        return Icons.access_time;
      case TenderStatus.authorized:
      case TenderStatus.captured:
      case TenderStatus.approved:
        return Icons.check_circle;
      case TenderStatus.failed:
      case TenderStatus.voided:
      case TenderStatus.declined:
        return Icons.error;
      case TenderStatus.refunded:
        return Icons.refresh;
    }
  }

  static TenderStatus fromString(String value) {
    return TenderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TenderStatus.pending,
    );
  }
}
