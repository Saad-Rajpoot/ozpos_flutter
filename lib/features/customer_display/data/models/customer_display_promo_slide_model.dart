import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/customer_display_promo_slide_entity.dart';

class CustomerDisplayPromoSlideModel extends Equatable {
  final int id;
  final String emoji;
  final String title;
  final String subtitle;
  final String priceText;
  final String savingsText;
  final Color gradientStart;
  final Color gradientEnd;

  const CustomerDisplayPromoSlideModel({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.priceText,
    required this.savingsText,
    required this.gradientStart,
    required this.gradientEnd,
  });

  factory CustomerDisplayPromoSlideModel.fromJson(Map<String, dynamic> json) {
    return CustomerDisplayPromoSlideModel(
      id: (json['id'] as num).toInt(),
      emoji: json['emoji'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      priceText: json['price'] as String,
      savingsText: json['savings'] as String,
      gradientStart: _parseHexColor(json['gradientStart'] as String),
      gradientEnd: _parseHexColor(json['gradientEnd'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emoji': emoji,
      'title': title,
      'subtitle': subtitle,
      'price': priceText,
      'savings': savingsText,
      'gradientStart': _colorToHex(gradientStart),
      'gradientEnd': _colorToHex(gradientEnd),
    };
  }

  CustomerDisplayPromoSlideEntity toEntity() {
    return CustomerDisplayPromoSlideEntity(
      id: id,
      emoji: emoji,
      title: title,
      subtitle: subtitle,
      priceText: priceText,
      savingsText: savingsText,
      gradientStart: gradientStart,
      gradientEnd: gradientEnd,
    );
  }

  factory CustomerDisplayPromoSlideModel.fromEntity(
      CustomerDisplayPromoSlideEntity entity) {
    return CustomerDisplayPromoSlideModel(
      id: entity.id,
      emoji: entity.emoji,
      title: entity.title,
      subtitle: entity.subtitle,
      priceText: entity.priceText,
      savingsText: entity.savingsText,
      gradientStart: entity.gradientStart,
      gradientEnd: entity.gradientEnd,
    );
  }

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

Color _parseHexColor(String hexColor) {
  var color = hexColor.replaceAll('#', '');
  if (color.length == 6) {
    color = 'FF$color';
  }
  return Color(int.parse(color, radix: 16));
}

String _colorToHex(Color color) {
  return '#'
          '${color.alpha.toRadixString(16).padLeft(2, '0')}'
          '${color.red.toRadixString(16).padLeft(2, '0')}'
          '${color.green.toRadixString(16).padLeft(2, '0')}'
          '${color.blue.toRadixString(16).padLeft(2, '0')}'
      .toUpperCase();
}
