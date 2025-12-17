import 'package:equatable/equatable.dart';
import '../../domain/entities/delivery_entities.dart';

/// Model class for KPIData JSON serialization/deserialization
class KPIDataModel extends Equatable {
  final int activeDrivers;
  final int inProgress;
  final int delayedOrders;
  final int avgEtaMinutes;

  const KPIDataModel({
    required this.activeDrivers,
    required this.inProgress,
    required this.delayedOrders,
    required this.avgEtaMinutes,
  });

  /// Convert JSON to KPIDataModel
  factory KPIDataModel.fromJson(Map<String, dynamic> json) {
    return KPIDataModel(
      activeDrivers: json['activeDrivers'] as int,
      inProgress: json['inProgress'] as int,
      delayedOrders: json['delayedOrders'] as int,
      avgEtaMinutes: json['avgEtaMinutes'] as int,
    );
  }

  /// Convert KPIDataModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'activeDrivers': activeDrivers,
      'inProgress': inProgress,
      'delayedOrders': delayedOrders,
      'avgEtaMinutes': avgEtaMinutes,
    };
  }

  /// Convert KPIDataModel to KPIData entity
  KPIDataEntity toEntity() {
    return KPIDataEntity(
      activeDrivers: activeDrivers,
      inProgress: inProgress,
      delayedOrders: delayedOrders,
      avgEtaMinutes: avgEtaMinutes,
    );
  }

  /// Create KPIDataModel from KPIData entity
  factory KPIDataModel.fromEntity(KPIDataEntity entity) {
    return KPIDataModel(
      activeDrivers: entity.activeDrivers,
      inProgress: entity.inProgress,
      delayedOrders: entity.delayedOrders,
      avgEtaMinutes: entity.avgEtaMinutes,
    );
  }

  @override
  List<Object?> get props => [
    activeDrivers,
    inProgress,
    delayedOrders,
    avgEtaMinutes,
  ];
}
