import 'package:equatable/equatable.dart';
import '../../domain/entities/reports_entities.dart';
import 'service_speed_section_model.dart';

/// Model class for ServiceSpeedData JSON serialization/deserialization
class ServiceSpeedDataModel extends Equatable {
  final String avgTime;
  final String avgTimeLabel;
  final String prepTime;
  final String serviceTime;
  final List<ServiceSpeedSectionModel> chartSections;

  const ServiceSpeedDataModel({
    required this.avgTime,
    required this.avgTimeLabel,
    required this.prepTime,
    required this.serviceTime,
    required this.chartSections,
  });

  /// Convert JSON to ServiceSpeedDataModel
  factory ServiceSpeedDataModel.fromJson(Map<String, dynamic> json) {
    return ServiceSpeedDataModel(
      avgTime: json['avgTime'] as String,
      avgTimeLabel: json['avgTimeLabel'] as String,
      prepTime: json['prepTime'] as String,
      serviceTime: json['serviceTime'] as String,
      chartSections:
          (json['chartSections'] as List<dynamic>?)
              ?.map(
                (item) => ServiceSpeedSectionModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList() ??
          <ServiceSpeedSectionModel>[],
    );
  }

  /// Convert ServiceSpeedDataModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'avgTime': avgTime,
      'avgTimeLabel': avgTimeLabel,
      'prepTime': prepTime,
      'serviceTime': serviceTime,
      'chartSections': chartSections.map((item) => item.toJson()).toList(),
    };
  }

  /// Convert ServiceSpeedDataModel to ServiceSpeedData entity
  ServiceSpeedData toEntity() {
    return ServiceSpeedData(
      avgTime: avgTime,
      avgTimeLabel: avgTimeLabel,
      prepTime: prepTime,
      serviceTime: serviceTime,
      chartSections: chartSections.map((item) => item.toEntity()).toList(),
    );
  }

  /// Create ServiceSpeedDataModel from ServiceSpeedData entity
  factory ServiceSpeedDataModel.fromEntity(ServiceSpeedData entity) {
    return ServiceSpeedDataModel(
      avgTime: entity.avgTime,
      avgTimeLabel: entity.avgTimeLabel,
      prepTime: entity.prepTime,
      serviceTime: entity.serviceTime,
      chartSections: entity.chartSections
          .map((item) => ServiceSpeedSectionModel.fromEntity(item))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    avgTime,
    avgTimeLabel,
    prepTime,
    serviceTime,
    chartSections,
  ];
}
