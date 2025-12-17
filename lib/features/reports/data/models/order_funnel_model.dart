import 'package:equatable/equatable.dart';
import '../../domain/entities/reports_entities.dart';

/// Model class for OrderFunnelStage JSON serialization/deserialization
class OrderFunnelStageModel extends Equatable {
  final String label;
  final int value;
  final int max;
  final String color;

  const OrderFunnelStageModel({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  /// Convert JSON to OrderFunnelStageModel
  factory OrderFunnelStageModel.fromJson(Map<String, dynamic> json) {
    return OrderFunnelStageModel(
      label: json['label'] as String,
      value: json['value'] as int,
      max: json['max'] as int,
      color: json['color'] as String,
    );
  }

  /// Convert OrderFunnelStageModel to JSON
  Map<String, dynamic> toJson() {
    return {'label': label, 'value': value, 'max': max, 'color': color};
  }

  /// Convert OrderFunnelStageModel to OrderFunnelStage entity
  OrderFunnelStage toEntity() {
    return OrderFunnelStage(label: label, value: value, max: max, color: color);
  }

  /// Create OrderFunnelStageModel from OrderFunnelStage entity
  factory OrderFunnelStageModel.fromEntity(OrderFunnelStage entity) {
    return OrderFunnelStageModel(
      label: entity.label,
      value: entity.value,
      max: entity.max,
      color: entity.color,
    );
  }

  @override
  List<Object?> get props => [label, value, max, color];
}
