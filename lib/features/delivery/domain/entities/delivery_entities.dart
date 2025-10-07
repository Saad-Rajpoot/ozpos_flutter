/// Driver status enum
enum DriverStatus {
  online,
  busy,
  offline,
}

/// Order status enum
enum DeliveryOrderStatus {
  ready,
  inProgress,
  delayed,
  completed,
  cancelled,
}

/// Order channel enum
enum OrderChannel {
  website,
  uberEats,
  doorDash,
  app,
  qr,
  phone,
}

/// Driver entity
class DriverEntity {
  final String id;
  final String name;
  final String? avatarUrl;
  final DriverStatus status;
  final String role; // "Self-managed", "Company", etc.
  final String zone; // "Downtown", "Uptown", etc.
  final int currentOrders;
  final int maxCapacity;
  final int avgTimeMinutes;
  final double todayEarnings;
  final double? latitude;
  final double? longitude;

  const DriverEntity({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.status,
    required this.role,
    required this.zone,
    required this.currentOrders,
    required this.maxCapacity,
    required this.avgTimeMinutes,
    required this.todayEarnings,
    this.latitude,
    this.longitude,
  });

  double get capacityPercentage => currentOrders / maxCapacity;
  bool get isAvailable => status != DriverStatus.offline && currentOrders < maxCapacity;
}

/// Delivery order entity
class DeliveryOrderEntity {
  final String id;
  final String orderNumber;
  final OrderChannel channel;
  final DeliveryOrderStatus status;
  final String customerName;
  final String address;
  final String? addressDetails;
  final List<String> items;
  final int pickupEtaMinutes;
  final int deliveryEtaMinutes;
  final String? assignedDriverId;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final DateTime createdAt;

  const DeliveryOrderEntity({
    required this.id,
    required this.orderNumber,
    required this.channel,
    required this.status,
    required this.customerName,
    required this.address,
    this.addressDetails,
    required this.items,
    required this.pickupEtaMinutes,
    required this.deliveryEtaMinutes,
    this.assignedDriverId,
    this.pickupLatitude,
    this.pickupLongitude,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.createdAt,
  });

  bool get isDelayed => status == DeliveryOrderStatus.delayed;
  bool get isReady => status == DeliveryOrderStatus.ready;
  bool get isInProgress => status == DeliveryOrderStatus.inProgress;
  bool get hasDriver => assignedDriverId != null;
}

/// KPI data
class DeliveryKpiData {
  final int activeDrivers;
  final int inProgress;
  final int delayedOrders;
  final int avgEtaMinutes;

  const DeliveryKpiData({
    required this.activeDrivers,
    required this.inProgress,
    required this.delayedOrders,
    required this.avgEtaMinutes,
  });
}
