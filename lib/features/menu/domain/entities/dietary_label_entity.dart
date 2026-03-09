import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Dietary label (e.g. Dairy Free, Gluten Free, Vegan)
class DietaryLabelEntity extends Equatable {
  final String name;
  final Color badgeColor;

  const DietaryLabelEntity({
    required this.name,
    required this.badgeColor,
  });

  @override
  List<Object?> get props => [name, badgeColor];
}
