import 'package:flutter/material.dart';

/// Payment method types for checkout
enum PaymentMethod {
  cash,
  card,
  wallet,
  gift,
  bnpl,
  split;

  /// Icon for each payment method
  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.payments;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet;
      case PaymentMethod.gift:
        return Icons.card_giftcard;
      case PaymentMethod.bnpl:
        return Icons.schedule;
      case PaymentMethod.split:
        return Icons.call_split;
    }
  }

  /// Display label for each payment method
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.gift:
        return 'Gift';
      case PaymentMethod.bnpl:
        return 'BNPL';
      case PaymentMethod.split:
        return 'Split';
    }
  }

  /// Whether this method requires cash input
  bool get requiresCashInput {
    return this == PaymentMethod.cash;
  }

  /// Whether this method supports keypad entry
  bool get supportsKeypad {
    return this == PaymentMethod.cash || this == PaymentMethod.gift;
  }
}
