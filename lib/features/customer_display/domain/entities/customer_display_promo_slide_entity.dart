import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Promotional slide used in idle mode slideshow
class CustomerDisplayPromoSlideEntity extends Equatable {
  final int id;
  final String emoji;
  final String title;
  final String subtitle;
  final String priceText;
  final String savingsText;
  final Color gradientStart;
  final Color gradientEnd;

  const CustomerDisplayPromoSlideEntity({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.priceText,
    required this.savingsText,
    required this.gradientStart,
    required this.gradientEnd,
  });

  @override
  List<Object?> get props => [
        id,
        emoji,
        title,
        subtitle,
        priceText,
        savingsText,
        gradientStart,
        gradientEnd,
      ];
}
