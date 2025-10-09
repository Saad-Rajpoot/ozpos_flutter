import 'package:equatable/equatable.dart';
import '../../domain/entities/reports_entities.dart';

/// Model class for PaymentMethod JSON serialization/deserialization
class PaymentMethodModel extends Equatable {
  final String method;
  final int percentage;
  final String color;

  const PaymentMethodModel({
    required this.method,
    required this.percentage,
    required this.color,
  });

  /// Convert JSON to PaymentMethodModel
  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      method: json['method'] as String,
      percentage: json['percentage'] as int,
      color: json['color'] as String,
    );
  }

  /// Convert PaymentMethodModel to JSON
  Map<String, dynamic> toJson() {
    return {'method': method, 'percentage': percentage, 'color': color};
  }

  /// Convert PaymentMethodModel to PaymentMethod entity
  PaymentMethod toEntity() {
    return PaymentMethod(method: method, percentage: percentage, color: color);
  }

  /// Create PaymentMethodModel from PaymentMethod entity
  factory PaymentMethodModel.fromEntity(PaymentMethod entity) {
    return PaymentMethodModel(
      method: entity.method,
      percentage: entity.percentage,
      color: entity.color,
    );
  }

  @override
  List<Object?> get props => [method, percentage, color];
}
