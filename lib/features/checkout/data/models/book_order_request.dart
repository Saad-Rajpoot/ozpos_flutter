/// Request models for the ozfoodz book-order API.
/// https://v3.ozfoodz.com.au/api/pos/orders/book-order

class BookOrderStore {
  final String vendorUuid;
  final String branchUuid;

  const BookOrderStore({
    required this.vendorUuid,
    required this.branchUuid,
  });

  Map<String, dynamic> toJson() => {
        'vendor_uuid': vendorUuid,
        'branch_uuid': branchUuid,
      };
}

class BookOrderEater {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;

  const BookOrderEater({
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
      };
}

class BookOrderAmount {
  final int amount; // cents
  final String currencyCode;

  const BookOrderAmount({
    required this.amount,
    this.currencyCode = 'AUD',
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency_code': currencyCode,
      };
}

class BookOrderPrice {
  final BookOrderAmount unitPrice;
  final BookOrderAmount totalPrice;

  const BookOrderPrice({
    required this.unitPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() => {
        'unit_price': unitPrice.toJson(),
        'total_price': totalPrice.toJson(),
      };
}

class BookOrderSelectedItem {
  final String id;
  final String title;
  final String? externalData;
  final int quantity;
  final BookOrderPrice price;
  final List<BookOrderModifierGroup>? selectedModifierGroups;

  const BookOrderSelectedItem({
    required this.id,
    required this.title,
    this.externalData,
    this.quantity = 1,
    required this.price,
    this.selectedModifierGroups,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'title': title,
      'quantity': quantity,
      'price': price.toJson(),
    };
    if (externalData != null && externalData!.isNotEmpty) {
      m['external_data'] = externalData;
    }
    if (selectedModifierGroups != null && selectedModifierGroups!.isNotEmpty) {
      m['selected_modifier_groups'] =
          selectedModifierGroups!.map((g) => g.toJson()).toList();
    }
    return m;
  }
}

class BookOrderModifierGroup {
  final String id;
  final String title;
  final String? externalData;
  final List<BookOrderSelectedItem> selectedItems;

  const BookOrderModifierGroup({
    required this.id,
    required this.title,
    this.externalData,
    required this.selectedItems,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'title': title,
      'selected_items': selectedItems.map((i) => i.toJson()).toList(),
    };
    if (externalData != null && externalData!.isNotEmpty) {
      m['external_data'] = externalData;
    }
    return m;
  }
}

class BookOrderCartItem {
  final String id;
  final String title;
  final String? externalData;
  final int quantity;
  final String? specialInstructions;
  final BookOrderPrice price;
  final List<BookOrderModifierGroup> selectedModifierGroups;

  const BookOrderCartItem({
    required this.id,
    required this.title,
    this.externalData,
    required this.quantity,
    this.specialInstructions,
    required this.price,
    this.selectedModifierGroups = const [],
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'title': title,
      'quantity': quantity,
      'price': price.toJson(),
    };
    if (externalData != null && externalData!.isNotEmpty) {
      m['external_data'] = externalData;
    }
    // Always send special_instructions so backend receives it (empty string when none).
    m['special_instructions'] = (specialInstructions?.trim().isNotEmpty == true)
        ? specialInstructions!.trim()
        : '';
    if (selectedModifierGroups.isNotEmpty) {
      m['selected_modifier_groups'] =
          selectedModifierGroups.map((g) => g.toJson()).toList();
    }
    return m;
  }
}

class BookOrderCart {
  final List<BookOrderCartItem> items;

  const BookOrderCart({required this.items});

  Map<String, dynamic> toJson() => {
        'items': items.map((i) => i.toJson()).toList(),
      };
}

class BookOrderChargeAmount {
  final int amount;
  final String currencyCode;
  final String? formattedAmount;

  const BookOrderChargeAmount({
    required this.amount,
    this.currencyCode = 'AUD',
    this.formattedAmount,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'amount': amount,
      'currency_code': currencyCode,
    };
    if (formattedAmount != null) m['formatted_amount'] = formattedAmount;
    return m;
  }
}

class BookOrderCharges {
  final BookOrderChargeAmount subTotal;
  final BookOrderChargeAmount tax;
  final BookOrderChargeAmount total;
  final BookOrderChargeAmount deliveryFee;
  final BookOrderChargeAmount tip;

  const BookOrderCharges({
    required this.subTotal,
    required this.tax,
    required this.total,
    required this.deliveryFee,
    required this.tip,
  });

  Map<String, dynamic> toJson() => {
        'sub_total': subTotal.toJson(),
        'tax': tax.toJson(),
        'total': total.toJson(),
        'delivery_fee': deliveryFee.toJson(),
        'tip': tip.toJson(),
      };
}

class BookOrderPayment {
  final BookOrderCharges charges;

  const BookOrderPayment({required this.charges});

  Map<String, dynamic> toJson() => {
        'charges': charges.toJson(),
      };
}

/// Service type for meta and request type
enum BookOrderServiceType { dineIn, delivery, takeaway }

extension BookOrderServiceTypeExt on BookOrderServiceType {
  String get apiValue {
    switch (this) {
      case BookOrderServiceType.dineIn:
        return 'DINE_IN';
      case BookOrderServiceType.delivery:
        return 'DELIVERY';
      case BookOrderServiceType.takeaway:
        return 'PICK_UP';
    }
  }
}

class BookOrderMeta {
  final String channel;
  final String paymentMethod;
  final String serviceType;
  final String? tableNumber; // Only for DINE_IN
  final String? address; // For DELIVERY
  final String? customerId;
  final String? customerUuid;
  final String? notes;

  const BookOrderMeta({
    this.channel = 'POS',
    required this.paymentMethod,
    required this.serviceType,
    this.tableNumber,
    this.address,
    this.customerId,
    this.customerUuid,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'channel': channel,
      'payment_method': paymentMethod,
      'service_type': serviceType,
    };
    if (tableNumber != null && tableNumber!.isNotEmpty) {
      m['table_number'] = tableNumber;
    }
    if (address != null && address!.isNotEmpty) {
      m['address'] = address;
    }
    if (customerId != null) m['customer_id'] = customerId;
    if (customerUuid != null) m['customer_uuid'] = customerUuid;
    if (notes != null && notes!.isNotEmpty) {
      m['notes'] = notes;
    }
    return m;
  }
}

class BookOrderRequest {
  final BookOrderStore store;
  final BookOrderEater eater;
  final BookOrderCart cart;
  final String type; // DINE_IN | DELIVERY | TAKEAWAY
  final String placedAt; // ISO 8601
  final BookOrderPayment payment;
  final BookOrderMeta meta;

  const BookOrderRequest({
    required this.store,
    required this.eater,
    required this.cart,
    required this.type,
    required this.placedAt,
    required this.payment,
    required this.meta,
  });

  Map<String, dynamic> toJson() => {
        'store': store.toJson(),
        'eater': eater.toJson(),
        'cart': cart.toJson(),
        'type': type,
        'placed_at': placedAt,
        'payment': payment.toJson(),
        'meta': meta.toJson(),
      };
}
