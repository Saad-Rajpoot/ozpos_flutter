import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class CustomerDisplayPresentationState extends Equatable {
  final String storeName;
  final List<CustomerDisplayPresentationItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final String status; // 'order', 'payment_card', 'payment_cash', 'approved', 'change_due', 'error'
  final String? paymentType; // 'card' or 'cash'
  final double? changeDue;

  const CustomerDisplayPresentationState({
    required this.storeName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.status = 'order',
    this.paymentType,
    this.changeDue,
  });

  const CustomerDisplayPresentationState.empty()
      : storeName = 'OZPOS',
        items = const [],
        subtotal = 0,
        tax = 0,
        total = 0,
        status = 'order',
        paymentType = null,
        changeDue = null;

  @override
  List<Object?> get props =>
      [storeName, items, subtotal, tax, total, status, paymentType, changeDue];
}

class CustomerDisplayPresentationItem extends Equatable {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final String? modifierSummary;

  const CustomerDisplayPresentationItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.modifierSummary,
  });

  double get lineTotal => unitPrice * quantity;

  @override
  List<Object?> get props => [id, name, quantity, unitPrice, modifierSummary];
}

class CustomerDisplayPresentationCubit
    extends Cubit<CustomerDisplayPresentationState> {
  CustomerDisplayPresentationCubit()
      : super(const CustomerDisplayPresentationState.empty());

  void applyPayload(dynamic payload) {
    if (payload is! Map) return;
    if (payload['type'] != 'cart_update') return;

    if (kDebugMode) {
      final items = payload['items'];
      debugPrint(
        'CustomerDisplayPresentationCubit: received cart_update '
        '(items=${items is List ? items.length : 'n/a'}, '
        'total=${payload['total']}, '
        'status=${payload['status']}, '
        'paymentType=${payload['paymentType']}, '
        'changeDue=${payload['changeDue']})',
      );
    }

    final storeName = (payload['storeName'] as String?)?.trim();
    final itemsRaw = payload['items'];
    final items = <CustomerDisplayPresentationItem>[];

    if (itemsRaw is List) {
      for (final item in itemsRaw) {
        if (item is! Map) continue;
        final id = item['id']?.toString();
        final name = item['name']?.toString();
        final quantity = item['quantity'];
        final unitPrice = item['unitPrice'];
        if (id == null || name == null) continue;
        items.add(
          CustomerDisplayPresentationItem(
            id: id,
            name: name,
            quantity: quantity is int ? quantity : int.tryParse('$quantity') ?? 0,
            unitPrice: unitPrice is num ? unitPrice.toDouble() : 0,
            modifierSummary: item['modifierSummary']?.toString(),
          ),
        );
      }
    }

    final status = (payload['status'] as String?) ?? state.status;
    final paymentType = payload['paymentType'] as String?;
    final changeDueValue = _num(payload['changeDue']);

    emit(
      CustomerDisplayPresentationState(
        storeName: (storeName == null || storeName.isEmpty)
            ? state.storeName
            : storeName,
        items: items,
        subtotal: _num(payload['subtotal']),
        tax: _num(payload['tax']),
        total: _num(payload['total']),
        status: status,
        paymentType: paymentType,
        changeDue: changeDueValue > 0 ? changeDueValue : null,
      ),
    );
  }

  double _num(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0;
  }
}

