import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../checkout/presentation/bloc/cart_bloc.dart';
import '../bloc/customer_display_presentation_cubit.dart';
import '../../domain/entities/customer_display_cart_item_entity.dart';
import '../../domain/entities/customer_display_entity.dart';
import '../../domain/entities/customer_display_loyalty_entity.dart';
import '../../domain/entities/customer_display_mode.dart';
import '../../domain/entities/customer_display_promo_slide_entity.dart';
import '../../domain/entities/customer_display_totals_entity.dart';
import '../../data/models/customer_display_model.dart';
import '../widgets/customer_display_approved_view.dart';
import '../widgets/customer_display_change_due_view.dart';
import '../widgets/customer_display_idle_view.dart';
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
          // On the main POS screen, always render the order/cart UI (no promos).
          return _buildFromStatus(
            const CustomerDisplayPresentationState(
              storeName: 'OZPOS',
              items: [],
              subtotal: 0,
              tax: 0,
              total: 0,
              status: 'order',
            ),
            entity,
          );
        },
      );
    }

    return const _PresentationCustomerDisplay();
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
  CustomerDisplayEntity entity, {
  List<CustomerDisplayPromoSlideEntity> promoSlides = const [],
  int activePromoIndex = 0,
}) {
  switch (state.status) {
    case 'idle':
    final slide = promoSlides.isEmpty
        ? null
        : promoSlides[activePromoIndex % promoSlides.length];
      return CustomerDisplayIdleView(
        slide: slide,
        totalSlides: promoSlides.length,
        activeIndex: activePromoIndex,
      );
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
            modifiers: (i.modifierSummary.trim().isEmpty)
                ? const []
                : [i.modifierSummary],
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
  CustomerDisplayPresentationState s, {
  List<CustomerDisplayPromoSlideEntity> promoSlides = const [],
}) {
  return CustomerDisplayEntity(
    // Keep the same UI chrome as the demo (order pill visible).
    // We don't have a real order number in the presentation payload yet.
    orderNumber: '—',
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
    // Match the demo layout by always showing the loyalty card on the
    // customer-facing display (values are placeholders unless you wire real loyalty).
    loyalty: const CustomerDisplayLoyaltyEntity(
      pointsEarned: 0,
      currentBalance: 0,
      showLoyalty: true,
    ),
    promoSlides: promoSlides,
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

class _PresentationCustomerDisplay extends StatefulWidget {
  const _PresentationCustomerDisplay();

  @override
  State<_PresentationCustomerDisplay> createState() =>
      _PresentationCustomerDisplayState();
}

class _PresentationCustomerDisplayState extends State<_PresentationCustomerDisplay> {
  Timer? _timer;
  int _promoIndex = 0;
  List<CustomerDisplayPromoSlideEntity> _slides = const [];

  @override
  void initState() {
    super.initState();
    _loadSlides();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSlides() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/customer_display_data/customer_display_data.json',
      );
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final model = CustomerDisplayModel.fromJson(data);
      final slides = model.promoSlides.map((s) => s.toEntity()).toList();

      if (!mounted) return;
      setState(() {
        _slides = slides;
      });

      final seconds = model.slideIntervalSeconds <= 0 ? 4 : model.slideIntervalSeconds;
      _timer?.cancel();
      if (slides.isEmpty) return;
      _timer = Timer.periodic(Duration(seconds: seconds), (_) {
        if (!mounted) return;
        setState(() {
          _promoIndex = (_promoIndex + 1) % slides.length;
        });
      });
    } catch (_) {
      // If promo data fails to load, keep slides empty (idle becomes black).
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerDisplayPresentationCubit,
        CustomerDisplayPresentationState>(
      builder: (context, state) {
        final entity = _mapStateToEntity(state, promoSlides: _slides);
        return _buildFromStatus(
          state,
          entity,
          promoSlides: _slides,
          activePromoIndex: _promoIndex,
        );
      },
    );
  }
}
