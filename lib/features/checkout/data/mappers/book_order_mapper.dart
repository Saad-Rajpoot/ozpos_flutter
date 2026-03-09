import '../../../menu/domain/entities/modifier_group_entity.dart';
import '../../domain/entities/book_order_item_input.dart';
import '../models/book_order_request.dart';

/// Maps cart items and checkout state to the ozfoodz book-order API format.
class BookOrderMapper {
  BookOrderMapper._();

  static const _currencyCode = 'AUD';

  /// Convert dollars to cents (int).
  static int _toCents(double dollars) => (dollars * 100).round();

  /// Build BookOrderRequest from checkout context.
  /// [serviceType] is request type: DINE_IN | DELIVERY | PICK_UP.
  /// Meta.service_type uses PICKUP for PICK_UP to match API.
  static BookOrderRequest toRequest({
    required BookOrderStore store,
    required BookOrderEater eater,
    required List<BookOrderItemInput> items,
    required String serviceType,
    required DateTime placedAt,
    required double subtotal,
    required double tax,
    required double total,
    required double deliveryFee,
    required double tip,
    required String paymentMethod,
    String? tableNumber,
    String? address,
    String? notes,
  }) {
    final cart = toCart(items);
    final subTotalCents = _toCents(subtotal);
    final taxCents = _toCents(tax);
    final totalCents = _toCents(total);
    final deliveryFeeCents = _toCents(deliveryFee);
    final tipCents = _toCents(tip);

    final payment = BookOrderPayment(
      charges: BookOrderCharges(
        subTotal: BookOrderChargeAmount(
          amount: subTotalCents,
          currencyCode: _currencyCode,
          formattedAmount: 'A\$${subtotal.toStringAsFixed(2)}',
        ),
        tax: BookOrderChargeAmount(
          amount: taxCents,
          currencyCode: _currencyCode,
          formattedAmount: 'A\$${tax.toStringAsFixed(2)}',
        ),
        total: BookOrderChargeAmount(
          amount: totalCents,
          currencyCode: _currencyCode,
          formattedAmount: 'A\$${total.toStringAsFixed(2)}',
        ),
        deliveryFee: BookOrderChargeAmount(
          amount: deliveryFeeCents,
          currencyCode: _currencyCode,
          formattedAmount: 'A\$${deliveryFee.toStringAsFixed(2)}',
        ),
        tip: BookOrderChargeAmount(
          amount: tipCents,
          currencyCode: _currencyCode,
          formattedAmount: 'A\$${tip.toStringAsFixed(2)}',
        ),
      ),
    );

    final metaServiceType = serviceType == 'PICK_UP' ? 'PICKUP' : serviceType;
    final meta = BookOrderMeta(
      channel: 'POS',
      paymentMethod: paymentMethod,
      serviceType: metaServiceType,
      tableNumber: (serviceType == 'DINE_IN' && tableNumber != null && tableNumber.isNotEmpty)
          ? tableNumber
          : null,
      address: (serviceType == 'DELIVERY' && address != null && address!.isNotEmpty)
          ? address
          : null,
      customerId: null,
      customerUuid: null,
      notes: notes,
    );

    return BookOrderRequest(
      store: store,
      eater: eater,
      cart: cart,
      type: serviceType,
      placedAt: placedAt.toIso8601String(),
      payment: payment,
      meta: meta,
    );
  }

  static BookOrderCart toCart(List<BookOrderItemInput> items) {
    return BookOrderCart(
      items: items.map(toCartItem).toList(),
    );
  }

  static BookOrderCartItem toCartItem(BookOrderItemInput item) {
    final unitCents = _toCents(item.unitPrice);
    final totalCents = _toCents(item.unitPrice * item.quantity);
    final price = BookOrderPrice(
      unitPrice: BookOrderAmount(amount: unitCents, currencyCode: _currencyCode),
      totalPrice: BookOrderAmount(amount: totalCents, currencyCode: _currencyCode),
    );

    final selectedGroups = _buildModifierGroups(
      modifierGroups: item.menuItem.modifierGroups,
      selectedModifiers: item.selectedModifiers,
    );

    return BookOrderCartItem(
      id: item.id,
      title: item.menuItem.name,
      externalData: _extractExternalId(item.menuItem.id),
      quantity: item.quantity,
      specialInstructions: item.specialInstructions?.trim().isNotEmpty == true
          ? item.specialInstructions!.trim()
          : null,
      price: price,
      selectedModifierGroups: selectedGroups,
    );
  }

  /// Extract numeric external ID if present (e.g. from item_half_half_pizza_1_8 -> 8).
  static String? _extractExternalId(String id) {
    final parts = id.split('_');
    if (parts.isEmpty) return null;
    final last = parts.last;
    if (int.tryParse(last) != null) return last;
    return id;
  }

  static List<BookOrderModifierGroup> _buildModifierGroups({
    required List<ModifierGroupEntity> modifierGroups,
    required Map<String, List<String>> selectedModifiers,
  }) {
    final result = <BookOrderModifierGroup>[];
    for (final group in modifierGroups) {
      final selectedIds = selectedModifiers[group.id];
      if (selectedIds == null || selectedIds.isEmpty) continue;

      final selectedItems = <BookOrderSelectedItem>[];
      for (final optionId in selectedIds) {
        final option = group.options.where((o) => o.id == optionId).firstOrNull;
        if (option == null) continue;

        final unitCents = _toCents(option.priceDelta);
        final price = BookOrderPrice(
          unitPrice: BookOrderAmount(amount: unitCents, currencyCode: _currencyCode),
          totalPrice: BookOrderAmount(amount: unitCents, currencyCode: _currencyCode),
        );

        List<BookOrderModifierGroup>? nestedGroups;
        if (option.nestedModifierGroups.isNotEmpty) {
          nestedGroups = _buildModifierGroups(
            modifierGroups: option.nestedModifierGroups,
            selectedModifiers: selectedModifiers,
          );
          if (nestedGroups.isEmpty) nestedGroups = null;
        }

        selectedItems.add(BookOrderSelectedItem(
          id: option.id,
          title: option.name,
          externalData: _extractExternalId(option.id),
          quantity: 1,
          price: price,
          selectedModifierGroups: nestedGroups,
        ));
      }

      if (selectedItems.isEmpty) continue;

      result.add(BookOrderModifierGroup(
        id: group.id,
        title: group.name,
        externalData: _extractExternalId(group.id),
        selectedItems: selectedItems,
      ));
    }
    return result;
  }
}
