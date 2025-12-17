import 'package:flutter/material.dart';

enum PaymentMethodType {
  cash('cash'),
  card('card'),
  digitalWallet('digital_wallet'),
  bankTransfer('bank_transfer'),
  loyaltyPoints('loyalty_points'),
  wallet('wallet'),
  gift('gift'),
  bnpl('bnpl'),
  split('split');

  const PaymentMethodType(this.value);
  final String value;

  /// Icon for each payment method
  IconData get icon {
    switch (this) {
      case PaymentMethodType.cash:
        return Icons.payments;
      case PaymentMethodType.card:
        return Icons.credit_card;
      case PaymentMethodType.digitalWallet:
      case PaymentMethodType.wallet:
        return Icons.account_balance_wallet;
      case PaymentMethodType.bankTransfer:
        return Icons.account_balance;
      case PaymentMethodType.loyaltyPoints:
        return Icons.stars;
      case PaymentMethodType.gift:
        return Icons.card_giftcard;
      case PaymentMethodType.bnpl:
        return Icons.schedule;
      case PaymentMethodType.split:
        return Icons.call_split;
    }
  }

  /// Display label for each payment method
  String get label {
    switch (this) {
      case PaymentMethodType.cash:
        return 'Cash';
      case PaymentMethodType.card:
        return 'Card';
      case PaymentMethodType.digitalWallet:
        return 'Digital Wallet';
      case PaymentMethodType.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethodType.loyaltyPoints:
        return 'Loyalty Points';
      case PaymentMethodType.wallet:
        return 'Wallet';
      case PaymentMethodType.gift:
        return 'Gift';
      case PaymentMethodType.bnpl:
        return 'BNPL';
      case PaymentMethodType.split:
        return 'Split';
    }
  }

  /// Whether this method requires cash input
  bool get requiresCashInput {
    return this == PaymentMethodType.cash;
  }

  /// Whether this method supports keypad entry
  bool get supportsKeypad {
    return this == PaymentMethodType.cash || this == PaymentMethodType.gift;
  }

  static PaymentMethodType fromString(String value) {
    return PaymentMethodType.values.firstWhere(
      (method) => method.value == value,
      orElse: () => PaymentMethodType.cash,
    );
  }
}
