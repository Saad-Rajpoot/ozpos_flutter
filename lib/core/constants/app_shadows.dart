import 'package:flutter/material.dart';

class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get tileShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 32,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 40,
          offset: const Offset(0, 12),
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> get hoverShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 48,
          offset: const Offset(0, 16),
          spreadRadius: -8,
        ),
      ];

  static List<BoxShadow> get button => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];
}
