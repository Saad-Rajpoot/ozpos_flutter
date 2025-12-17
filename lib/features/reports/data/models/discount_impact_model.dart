import 'package:equatable/equatable.dart';
import '../../domain/entities/reports_entities.dart';

/// Model class for DiscountImpact JSON serialization/deserialization
class DiscountImpactModel extends Equatable {
  final String category;
  final int value;

  const DiscountImpactModel({required this.category, required this.value});

  /// Convert JSON to DiscountImpactModel
  factory DiscountImpactModel.fromJson(Map<String, dynamic> json) {
    return DiscountImpactModel(
      category: json['category'] as String,
      value: json['value'] as int,
    );
  }

  /// Convert DiscountImpactModel to JSON
  Map<String, dynamic> toJson() {
    return {'category': category, 'value': value};
  }

  /// Convert DiscountImpactModel to DiscountImpact entity
  DiscountImpact toEntity() {
    return DiscountImpact(category: category, value: value);
  }

  /// Create DiscountImpactModel from DiscountImpact entity
  factory DiscountImpactModel.fromEntity(DiscountImpact entity) {
    return DiscountImpactModel(category: entity.category, value: entity.value);
  }

  @override
  List<Object?> get props => [category, value];
}
