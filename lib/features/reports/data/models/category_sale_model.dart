import 'package:equatable/equatable.dart';
import '../../domain/entities/reports_entities.dart';

/// Model class for CategorySale JSON serialization/deserialization
class CategorySaleModel extends Equatable {
  final String name;
  final String amount;
  final double percentage;
  final String color;

  const CategorySaleModel({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  /// Convert JSON to CategorySaleModel
  factory CategorySaleModel.fromJson(Map<String, dynamic> json) {
    return CategorySaleModel(
      name: json['name'] as String,
      amount: json['amount'] as String,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      color: json['color'] as String,
    );
  }

  /// Convert CategorySaleModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'percentage': percentage,
      'color': color,
    };
  }

  /// Convert CategorySaleModel to CategorySale entity
  CategorySale toEntity() {
    return CategorySale(
      name: name,
      amount: amount,
      percentage: percentage,
      color: color,
    );
  }

  /// Create CategorySaleModel from CategorySale entity
  factory CategorySaleModel.fromEntity(CategorySale entity) {
    return CategorySaleModel(
      name: entity.name,
      amount: entity.amount,
      percentage: entity.percentage,
      color: entity.color,
    );
  }

  @override
  List<Object?> get props => [name, amount, percentage, color];
}
