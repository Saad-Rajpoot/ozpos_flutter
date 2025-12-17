import 'package:equatable/equatable.dart';

import '../../domain/entities/customer_display_entity.dart';
import '../../domain/entities/customer_display_mode.dart';
import 'customer_display_cart_item_model.dart';
import 'customer_display_loyalty_model.dart';
import 'customer_display_promo_slide_model.dart';
import 'customer_display_totals_model.dart';

class CustomerDisplayModel extends Equatable {
  final String orderNumber;
  final List<CustomerDisplayCartItemModel> cartItems;
  final CustomerDisplayTotalsModel totals;
  final CustomerDisplayLoyaltyModel loyalty;
  final List<CustomerDisplayPromoSlideModel> promoSlides;
  final List<CustomerDisplayMode> demoSequence;
  final int modeIntervalSeconds;
  final int slideIntervalSeconds;

  const CustomerDisplayModel({
    required this.orderNumber,
    required this.cartItems,
    required this.totals,
    required this.loyalty,
    required this.promoSlides,
    required this.demoSequence,
    required this.modeIntervalSeconds,
    required this.slideIntervalSeconds,
  });

  factory CustomerDisplayModel.fromJson(Map<String, dynamic> json) {
    final cartItemsJson = json['cartItems'] as List<dynamic>? ?? const [];
    final promoSlidesJson = json['promoSlides'] as List<dynamic>? ?? const [];

    final cartItems = cartItemsJson
        .whereType<Map<String, dynamic>>()
        .map(CustomerDisplayCartItemModel.fromJson)
        .toList();
    final promoSlides = promoSlidesJson
        .whereType<Map<String, dynamic>>()
        .map(CustomerDisplayPromoSlideModel.fromJson)
        .toList();

    final totalsJson = json['totals'] as Map<String, dynamic>? ?? const {};
    final loyaltyJson = json['loyalty'] as Map<String, dynamic>? ?? const {};

    final demoSequence = CustomerDisplayModeParser.fromKeys(
      json['demoSequence'] as List<dynamic>? ?? const [],
    );

    return CustomerDisplayModel(
      orderNumber: json['orderNumber'] as String? ?? '000',
      cartItems: cartItems,
      totals: CustomerDisplayTotalsModel.fromJson(totalsJson),
      loyalty: CustomerDisplayLoyaltyModel.fromJson(loyaltyJson),
      promoSlides: promoSlides,
      demoSequence:
          demoSequence.isNotEmpty ? demoSequence : [CustomerDisplayMode.idle],
      modeIntervalSeconds: (json['modeIntervalSeconds'] as num?)?.toInt() ?? 5,
      slideIntervalSeconds:
          (json['slideIntervalSeconds'] as num?)?.toInt() ?? 4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderNumber': orderNumber,
      'cartItems': cartItems.map((item) => item.toJson()).toList(),
      'totals': totals.toJson(),
      'loyalty': loyalty.toJson(),
      'promoSlides': promoSlides.map((slide) => slide.toJson()).toList(),
      'demoSequence': demoSequence.map((mode) => mode.key).toList(),
      'modeIntervalSeconds': modeIntervalSeconds,
      'slideIntervalSeconds': slideIntervalSeconds,
    };
  }

  CustomerDisplayEntity toEntity() {
    return CustomerDisplayEntity(
      orderNumber: orderNumber,
      cartItems: cartItems.map((item) => item.toEntity()).toList(),
      totals: totals.toEntity(),
      loyalty: loyalty.toEntity(),
      promoSlides: promoSlides.map((slide) => slide.toEntity()).toList(),
      demoSequence: demoSequence,
      modeIntervalSeconds: modeIntervalSeconds,
      slideIntervalSeconds: slideIntervalSeconds,
    );
  }

  factory CustomerDisplayModel.fromEntity(CustomerDisplayEntity entity) {
    return CustomerDisplayModel(
      orderNumber: entity.orderNumber,
      cartItems: entity.cartItems
          .map(CustomerDisplayCartItemModel.fromEntity)
          .toList(),
      totals: CustomerDisplayTotalsModel.fromEntity(entity.totals),
      loyalty: CustomerDisplayLoyaltyModel.fromEntity(entity.loyalty),
      promoSlides: entity.promoSlides
          .map(CustomerDisplayPromoSlideModel.fromEntity)
          .toList(),
      demoSequence: entity.demoSequence,
      modeIntervalSeconds: entity.modeIntervalSeconds,
      slideIntervalSeconds: entity.slideIntervalSeconds,
    );
  }

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
