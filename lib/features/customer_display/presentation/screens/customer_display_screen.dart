import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../checkout/presentation/bloc/cart_bloc.dart';
import '../bloc/customer_display_presentation_cubit.dart';
import '../../domain/entities/customer_display_cart_item_entity.dart';
import '../../domain/entities/customer_display_entity.dart';
import '../../domain/entities/customer_display_loyalty_entity.dart';
import '../../domain/entities/customer_display_mode.dart';
import '../../domain/entities/customer_display_totals_entity.dart';
import '../widgets/customer_display_approved_view.dart';
import '../widgets/customer_display_change_due_view.dart';
import '../widgets/customer_display_order_layout.dart';
import '../widgets/customer_display_payment_declined_view.dart';

class CustomerDisplayScreen extends StatelessWidget {
  const CustomerDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartBloc = _maybeReadCartBloc(context);
    if (cartBloc != null) {
      return BlocBuilder<CartBloc, CartState>(
        bloc: cartBloc,
        builder: (context, state) {
          final loaded = state is CartLoaded ? state : null;
          final entity = _mapCartToEntity('OZPOS', loaded);
          return _buildFromStatus(
            const CustomerDisplayPresentationState.empty(),
            entity,
          );
        },
      );
    }

    return BlocBuilder<CustomerDisplayPresentationCubit,
        CustomerDisplayPresentationState>(
      builder: (context, state) {
        final entity = _mapStateToEntity(state);
        return _buildFromStatus(state, entity);
      },
    );
  }
}

CartBloc? _maybeReadCartBloc(BuildContext context) {
  try {
    return context.read<CartBloc>();
  } catch (_) {
    return null;
  }
}

Widget _buildFromStatus(
  CustomerDisplayPresentationState state,
  CustomerDisplayEntity entity,
) {
  switch (state.status) {
    case 'payment_card':
      return CustomerDisplayOrderLayout(
        content: entity,
        rightPanel: CustomerDisplayPaymentPanel(
          content: entity,
          mode: CustomerDisplayMode.paymentCard,
        ),
      );
    case 'payment_cash':
      return CustomerDisplayOrderLayout(
        content: entity,
        rightPanel: CustomerDisplayPaymentPanel(
          content: entity,
          mode: CustomerDisplayMode.paymentCash,
        ),
      );
    case 'approved':
      return CustomerDisplayApprovedView(content: entity);
    case 'change_due':
      return CustomerDisplayChangeDueView(content: entity);
    case 'error':
      return const CustomerDisplayPaymentDeclinedView();
    case 'order':
    default:
      return CustomerDisplayOrderLayout(
        content: entity,
        rightPanel: CustomerDisplayOrderSummary(content: entity),
      );
  }
}

CustomerDisplayEntity _mapCartToEntity(
  String storeName,
  CartLoaded? cart,
) {
  if (cart == null) {
    return _emptyEntity(storeName);
  }

  return CustomerDisplayEntity(
    orderNumber: '',
    cartItems: cart.items
        .map(
          (i) => CustomerDisplayCartItemEntity(
            id: i.id,
            name: i.menuItem.name,
            price: i.unitPrice,
            quantity: i.quantity,
            modifiers: (i.modifierSummary == null ||
                    i.modifierSummary!.trim().isEmpty)
                ? const []
                : [i.modifierSummary!],
          ),
        )
        .toList(growable: false),
    totals: CustomerDisplayTotalsEntity(
      subtotal: cart.subtotal,
      discount: 0,
      tax: cart.gst,
      total: cart.total,
      cashReceived: 0,
      changeDue: 0,
    ),
    loyalty: const CustomerDisplayLoyaltyEntity(
      pointsEarned: 0,
      currentBalance: 0,
      showLoyalty: false,
    ),
    promoSlides: const [],
    demoSequence: const [
      CustomerDisplayMode.order,
    ],
    modeIntervalSeconds: 0,
    slideIntervalSeconds: 0,
  );
}

CustomerDisplayEntity _mapStateToEntity(
  CustomerDisplayPresentationState s,
) {
  return CustomerDisplayEntity(
    orderNumber: '',
    cartItems: s.items
        .map(
          (i) => CustomerDisplayCartItemEntity(
            id: i.id,
            name: i.name,
            price: i.unitPrice,
            quantity: i.quantity,
            modifiers: (i.modifierSummary == null ||
                    i.modifierSummary!.trim().isEmpty)
                ? const []
                : [i.modifierSummary!],
          ),
        )
        .toList(growable: false),
    totals: CustomerDisplayTotalsEntity(
      subtotal: s.subtotal,
      discount: 0,
      tax: s.tax,
      total: s.total,
      cashReceived: s.changeDue != null ? s.total + s.changeDue! : 0,
      changeDue: s.changeDue ?? 0,
    ),
    loyalty: const CustomerDisplayLoyaltyEntity(
      pointsEarned: 0,
      currentBalance: 0,
      showLoyalty: false,
    ),
    promoSlides: const [],
    demoSequence: const [
      CustomerDisplayMode.order,
      CustomerDisplayMode.paymentCard,
      CustomerDisplayMode.paymentCash,
      CustomerDisplayMode.approved,
      CustomerDisplayMode.changeDue,
    ],
    modeIntervalSeconds: 0,
    slideIntervalSeconds: 0,
  );
}

CustomerDisplayEntity _emptyEntity(String storeName) {
  return const CustomerDisplayEntity(
    orderNumber: '',
    cartItems: [],
    totals: CustomerDisplayTotalsEntity(
      subtotal: 0,
      discount: 0,
      tax: 0,
      total: 0,
      cashReceived: 0,
      changeDue: 0,
    ),
    loyalty: CustomerDisplayLoyaltyEntity(
      pointsEarned: 0,
      currentBalance: 0,
      showLoyalty: false,
    ),
    promoSlides: [],
    demoSequence: [CustomerDisplayMode.order],
    modeIntervalSeconds: 0,
    slideIntervalSeconds: 0,
  );
}
