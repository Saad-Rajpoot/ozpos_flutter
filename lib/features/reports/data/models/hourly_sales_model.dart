import 'package:equatable/equatable.dart';
import '../../domain/entities/reports_entities.dart';

/// Model class for HourlySalesPoint JSON serialization/deserialization
class HourlySalesPointModel extends Equatable {
  final int hour;
  final int value;

  const HourlySalesPointModel({required this.hour, required this.value});

  /// Convert JSON to HourlySalesPointModel
  factory HourlySalesPointModel.fromJson(Map<String, dynamic> json) {
    return HourlySalesPointModel(
      hour: json['hour'] as int,
      value: json['value'] as int,
    );
  }

  /// Convert HourlySalesPointModel to JSON
  Map<String, dynamic> toJson() {
    return {'hour': hour, 'value': value};
  }

  /// Convert HourlySalesPointModel to HourlySalesPoint entity
  HourlySalesPoint toEntity() {
    return HourlySalesPoint(hour: hour, value: value);
  }

  /// Create HourlySalesPointModel from HourlySalesPoint entity
  factory HourlySalesPointModel.fromEntity(HourlySalesPoint entity) {
    return HourlySalesPointModel(hour: entity.hour, value: entity.value);
  }

  @override
  List<Object?> get props => [hour, value];
}
