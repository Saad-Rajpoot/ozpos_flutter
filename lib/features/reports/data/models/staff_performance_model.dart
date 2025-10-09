import 'package:equatable/equatable.dart';
import '../../domain/entities/reports_entities.dart';

/// Model class for StaffPerformance JSON serialization/deserialization
class StaffPerformanceModel extends Equatable {
  final String initial;
  final String name;
  final String orders;
  final String upsells;
  final String efficiency;
  final String color;

  const StaffPerformanceModel({
    required this.initial,
    required this.name,
    required this.orders,
    required this.upsells,
    required this.efficiency,
    required this.color,
  });

  /// Convert JSON to StaffPerformanceModel
  factory StaffPerformanceModel.fromJson(Map<String, dynamic> json) {
    return StaffPerformanceModel(
      initial: json['initial'] as String,
      name: json['name'] as String,
      orders: json['orders'] as String,
      upsells: json['upsells'] as String,
      efficiency: json['efficiency'] as String,
      color: json['color'] as String,
    );
  }

  /// Convert StaffPerformanceModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'initial': initial,
      'name': name,
      'orders': orders,
      'upsells': upsells,
      'efficiency': efficiency,
      'color': color,
    };
  }

  /// Convert StaffPerformanceModel to StaffPerformance entity
  StaffPerformance toEntity() {
    return StaffPerformance(
      initial: initial,
      name: name,
      orders: orders,
      upsells: upsells,
      efficiency: efficiency,
      color: color,
    );
  }

  /// Create StaffPerformanceModel from StaffPerformance entity
  factory StaffPerformanceModel.fromEntity(StaffPerformance entity) {
    return StaffPerformanceModel(
      initial: entity.initial,
      name: entity.name,
      orders: entity.orders,
      upsells: entity.upsells,
      efficiency: entity.efficiency,
      color: entity.color,
    );
  }

  @override
  List<Object?> get props => [
    initial,
    name,
    orders,
    upsells,
    efficiency,
    color,
  ];
}
