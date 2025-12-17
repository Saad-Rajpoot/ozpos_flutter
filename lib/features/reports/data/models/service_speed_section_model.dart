import 'package:equatable/equatable.dart';
import '../../domain/entities/reports_entities.dart';

/// Model class for ServiceSpeedSection JSON serialization/deserialization
class ServiceSpeedSectionModel extends Equatable {
  final int value;
  final String color;

  const ServiceSpeedSectionModel({required this.value, required this.color});

  /// Convert JSON to ServiceSpeedSectionModel
  factory ServiceSpeedSectionModel.fromJson(Map<String, dynamic> json) {
    return ServiceSpeedSectionModel(
      value: json['value'] as int,
      color: json['color'] as String,
    );
  }

  /// Convert ServiceSpeedSectionModel to JSON
  Map<String, dynamic> toJson() {
    return {'value': value, 'color': color};
  }

  /// Convert ServiceSpeedSectionModel to ServiceSpeedSection entity
  ServiceSpeedSection toEntity() {
    return ServiceSpeedSection(value: value, color: color);
  }

  /// Create ServiceSpeedSectionModel from ServiceSpeedSection entity
  factory ServiceSpeedSectionModel.fromEntity(ServiceSpeedSection entity) {
    return ServiceSpeedSectionModel(value: entity.value, color: entity.color);
  }

  @override
  List<Object?> get props => [value, color];
}
