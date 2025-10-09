import 'package:equatable/equatable.dart';
import '../../domain/entities/delivery_entities.dart';

/// Model class for Driver JSON serialization/deserialization
class DriverModel extends Equatable {
  final String id;
  final String name;
  final String status;
  final String role;
  final String zone;
  final int currentOrders;
  final int maxCapacity;
  final int avgTimeMinutes;
  final double todayEarnings;
  final double latitude;
  final double longitude;

  const DriverModel({
    required this.id,
    required this.name,
    required this.status,
    required this.role,
    required this.zone,
    required this.currentOrders,
    required this.maxCapacity,
    required this.avgTimeMinutes,
    required this.todayEarnings,
    required this.latitude,
    required this.longitude,
  });

  /// Convert JSON to DriverModel
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      role: json['role'] as String,
      zone: json['zone'] as String,
      currentOrders: json['currentOrders'] as int,
      maxCapacity: json['maxCapacity'] as int,
      avgTimeMinutes: json['avgTimeMinutes'] as int,
      todayEarnings: (json['todayEarnings'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  /// Convert DriverModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'role': role,
      'zone': zone,
      'currentOrders': currentOrders,
      'maxCapacity': maxCapacity,
      'avgTimeMinutes': avgTimeMinutes,
      'todayEarnings': todayEarnings,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Convert DriverModel to Driver entity
  DriverEntity toEntity() {
    return DriverEntity(
      id: id,
      name: name,
      status: status,
      role: role,
      zone: zone,
      currentOrders: currentOrders,
      maxCapacity: maxCapacity,
      avgTimeMinutes: avgTimeMinutes,
      todayEarnings: todayEarnings,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Create DriverModel from Driver entity
  factory DriverModel.fromEntity(DriverEntity entity) {
    return DriverModel(
      id: entity.id,
      name: entity.name,
      status: entity.status,
      role: entity.role,
      zone: entity.zone,
      currentOrders: entity.currentOrders,
      maxCapacity: entity.maxCapacity,
      avgTimeMinutes: entity.avgTimeMinutes,
      todayEarnings: entity.todayEarnings,
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    status,
    role,
    zone,
    currentOrders,
    maxCapacity,
    avgTimeMinutes,
    todayEarnings,
    latitude,
    longitude,
  ];
}
