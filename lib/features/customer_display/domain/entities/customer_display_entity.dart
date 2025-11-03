import 'package:equatable/equatable.dart';

import 'customer_display_cart_item_entity.dart';
import 'customer_display_loyalty_entity.dart';
import 'customer_display_mode.dart';
import 'customer_display_promo_slide_entity.dart';
import 'customer_display_totals_entity.dart';

/// Aggregate entity that contains all data required by the customer display
class CustomerDisplayEntity extends Equatable {
  final String orderNumber;
  final List<CustomerDisplayCartItemEntity> cartItems;
  final CustomerDisplayTotalsEntity totals;
  final CustomerDisplayLoyaltyEntity loyalty;
  final List<CustomerDisplayPromoSlideEntity> promoSlides;
  final List<CustomerDisplayMode> demoSequence;
  final int modeIntervalSeconds;
  final int slideIntervalSeconds;

  const CustomerDisplayEntity({
    required this.orderNumber,
    required this.cartItems,
    required this.totals,
    required this.loyalty,
    required this.promoSlides,
    required this.demoSequence,
    required this.modeIntervalSeconds,
    required this.slideIntervalSeconds,
  });

  int get totalSteps => demoSequence.length;

  CustomerDisplayMode get initialMode =>
      demoSequence.isNotEmpty ? demoSequence.first : CustomerDisplayMode.idle;

  @override
  List<Object?> get props => [
        orderNumber,
        cartItems,
        totals,
        loyalty,
        promoSlides,
        demoSequence,
        modeIntervalSeconds,
        slideIntervalSeconds,
      ];
}
