import 'package:equatable/equatable.dart';
import '../../domain/entities/reports_entities.dart';

/// Model class for KPICard JSON serialization/deserialization
class KPICardModel extends Equatable {
  final String label;
  final String value;
  final String delta;
  final bool positive;
  final String color;

  const KPICardModel({
    required this.label,
    required this.value,
    required this.delta,
    required this.positive,
    required this.color,
  });

  /// Convert JSON to KPICardModel
  factory KPICardModel.fromJson(Map<String, dynamic> json) {
    return KPICardModel(
      label: json['label'] as String,
      value: json['value'] as String,
      delta: json['delta'] as String,
      positive: json['positive'] as bool,
      color: json['color'] as String,
    );
  }

  /// Convert KPICardModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'delta': delta,
      'positive': positive,
      'color': color,
    };
  }

  /// Convert KPICardModel to KPICard entity
  KPICard toEntity() {
    return KPICard(
      label: label,
      value: value,
      delta: delta,
      positive: positive,
      color: color,
    );
  }

  /// Create KPICardModel from KPICard entity
  factory KPICardModel.fromEntity(KPICard entity) {
    return KPICardModel(
      label: entity.label,
      value: entity.value,
      delta: entity.delta,
      positive: entity.positive,
      color: entity.color,
    );
  }

  @override
  List<Object?> get props => [label, value, delta, positive, color];
}
