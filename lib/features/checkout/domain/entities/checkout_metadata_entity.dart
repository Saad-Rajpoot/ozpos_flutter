import 'package:equatable/equatable.dart';

class CheckoutMetadataEntity extends Equatable {
  final int totalOrders;
  final int completedOrders;
  final int pendingOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final DateTime lastUpdated;

  const CheckoutMetadataEntity({
    required this.totalOrders,
    required this.completedOrders,
    required this.pendingOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        totalOrders,
        completedOrders,
        pendingOrders,
        totalRevenue,
        averageOrderValue,
        lastUpdated,
      ];
}
