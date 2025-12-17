/// Supported customer display modes
enum CustomerDisplayMode {
  idle,
  order,
  paymentCard,
  paymentCash,
  approved,
  changeDue,
  error,
}

extension CustomerDisplayModeX on CustomerDisplayMode {
  /// Mode key used by data sources (matches original React implementation)
  String get key {
    switch (this) {
      case CustomerDisplayMode.idle:
        return 'idle';
      case CustomerDisplayMode.order:
        return 'order';
      case CustomerDisplayMode.paymentCard:
        return 'payment-card';
      case CustomerDisplayMode.paymentCash:
        return 'payment-cash';
      case CustomerDisplayMode.approved:
        return 'approved';
      case CustomerDisplayMode.changeDue:
        return 'change-due';
      case CustomerDisplayMode.error:
        return 'error';
    }
  }

  /// Human readable label for progress indicator and accessibility text
  String get displayLabel {
    switch (this) {
      case CustomerDisplayMode.idle:
        return 'IDLE';
      case CustomerDisplayMode.order:
        return 'ORDER';
      case CustomerDisplayMode.paymentCard:
        return 'PAYMENT CARD';
      case CustomerDisplayMode.paymentCash:
        return 'PAYMENT CASH';
      case CustomerDisplayMode.approved:
        return 'APPROVED';
      case CustomerDisplayMode.changeDue:
        return 'CHANGE DUE';
      case CustomerDisplayMode.error:
        return 'ERROR';
    }
  }

  /// Indicates whether the mode should display the idle slideshow
  bool get showsPromoSlides => this == CustomerDisplayMode.idle;
}

/// Helper methods to parse string keys into modes
class CustomerDisplayModeParser {
  const CustomerDisplayModeParser._();

  static CustomerDisplayMode fromKey(String key) {
    switch (key) {
      case 'idle':
        return CustomerDisplayMode.idle;
      case 'order':
        return CustomerDisplayMode.order;
      case 'payment-card':
        return CustomerDisplayMode.paymentCard;
      case 'payment-cash':
        return CustomerDisplayMode.paymentCash;
      case 'approved':
        return CustomerDisplayMode.approved;
      case 'change-due':
        return CustomerDisplayMode.changeDue;
      case 'error':
        return CustomerDisplayMode.error;
      default:
        return CustomerDisplayMode.idle;
    }
  }

  static List<CustomerDisplayMode> fromKeys(List<dynamic> keys) {
    return keys
        .whereType<String>()
        .map(CustomerDisplayModeParser.fromKey)
        .toList();
  }
}
