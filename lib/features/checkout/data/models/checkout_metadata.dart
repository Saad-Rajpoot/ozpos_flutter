import 'package:equatable/equatable.dart';
import '../../domain/entities/checkout_metadata_entity.dart';

// Metadata model
class CheckoutMetadata extends Equatable {
  final int totalOrders;
  final int completedOrders;
  final int pendingOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final DateTime lastUpdated;

  const CheckoutMetadata({
    required this.totalOrders,
    required this.completedOrders,
    required this.pendingOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.lastUpdated,
  });

  factory CheckoutMetadata.fromJson(Map<String, dynamic> json) {
    return CheckoutMetadata(
      totalOrders: json['totalOrders'] as int,
      completedOrders: json['completedOrders'] as int,
      pendingOrders: json['pendingOrders'] as int,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'pendingOrders': pendingOrders,
      'totalRevenue': totalRevenue,
      'averageOrderValue': averageOrderValue,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        totalOrders,
        completedOrders,
        pendingOrders,
        totalRevenue,
        averageOrderValue,
        lastUpdated,
      ];

  // Convert to domain entity
  CheckoutMetadataEntity toEntity() {
    return CheckoutMetadataEntity(
      totalOrders: totalOrders,
      completedOrders: completedOrders,
      pendingOrders: pendingOrders,
      totalRevenue: totalRevenue,
      averageOrderValue: averageOrderValue,
      lastUpdated: lastUpdated,
    );
  }

  // Create from domain entity
  factory CheckoutMetadata.fromEntity(CheckoutMetadataEntity entity) {
    return CheckoutMetadata(
      totalOrders: entity.totalOrders,
      completedOrders: entity.completedOrders,
      pendingOrders: entity.pendingOrders,
      totalRevenue: entity.totalRevenue,
      averageOrderValue: entity.averageOrderValue,
      lastUpdated: entity.lastUpdated,
    );
  }
}
