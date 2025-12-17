import 'package:equatable/equatable.dart';

/// KPI data that matches JSON structure
class KPIDataEntity extends Equatable {
  final int activeDrivers;
  final int inProgress;
  final int delayedOrders;
  final int avgEtaMinutes;

  const KPIDataEntity({
    required this.activeDrivers,
    required this.inProgress,
    required this.delayedOrders,
    required this.avgEtaMinutes,
  });

  KPIDataEntity copyWith({
    int? activeDrivers,
    int? inProgress,
    int? delayedOrders,
    int? avgEtaMinutes,
  }) {
    return KPIDataEntity(
      activeDrivers: activeDrivers ?? this.activeDrivers,
      inProgress: inProgress ?? this.inProgress,
      delayedOrders: delayedOrders ?? this.delayedOrders,
      avgEtaMinutes: avgEtaMinutes ?? this.avgEtaMinutes,
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

/// Driver entity that matches JSON structure
class DriverEntity extends Equatable {
  final String id;
  final String name;
  final String status; // online, busy, offline
  final String role; // Self-managed, Company
  final String zone;
  final int currentOrders;
  final int maxCapacity;
  final int avgTimeMinutes;
  final double todayEarnings;
  final double latitude;
  final double longitude;

  const DriverEntity({
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

  DriverEntity copyWith({
    String? id,
    String? name,
    String? status,
    String? role,
    String? zone,
    int? currentOrders,
    int? maxCapacity,
    int? avgTimeMinutes,
    double? todayEarnings,
    double? latitude,
    double? longitude,
  }) {
    return DriverEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      role: role ?? this.role,
      zone: zone ?? this.zone,
      currentOrders: currentOrders ?? this.currentOrders,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      avgTimeMinutes: avgTimeMinutes ?? this.avgTimeMinutes,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  double get capacityPercentage => currentOrders / maxCapacity;
  bool get isAvailable => status != 'offline' && currentOrders < maxCapacity;

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

/// Order entity that matches JSON structure
class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String channel; // website, uberEats, doorDash, app
  final String status; // ready, delayed, inProgress
  final String customerName;
  final String address;
  final List<String> items;
  final int pickupEtaMinutes;
  final int deliveryEtaMinutes;
  final String? assignedDriverId;
  final double pickupLatitude;
  final double pickupLongitude;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final int createdAtMinutes;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.channel,
    required this.status,
    required this.customerName,
    required this.address,
    required this.items,
    required this.pickupEtaMinutes,
    required this.deliveryEtaMinutes,
    this.assignedDriverId,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.createdAtMinutes,
  });

  OrderEntity copyWith({
    String? id,
    String? orderNumber,
    String? channel,
    String? status,
    String? customerName,
    String? address,
    List<String>? items,
    int? pickupEtaMinutes,
    int? deliveryEtaMinutes,
    String? assignedDriverId,
    double? pickupLatitude,
    double? pickupLongitude,
    double? deliveryLatitude,
    double? deliveryLongitude,
    int? createdAtMinutes,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      channel: channel ?? this.channel,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      address: address ?? this.address,
      items: items ?? this.items,
      pickupEtaMinutes: pickupEtaMinutes ?? this.pickupEtaMinutes,
      deliveryEtaMinutes: deliveryEtaMinutes ?? this.deliveryEtaMinutes,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      createdAtMinutes: createdAtMinutes ?? this.createdAtMinutes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    channel,
    status,
    customerName,
    address,
    items,
    pickupEtaMinutes,
    deliveryEtaMinutes,
    assignedDriverId,
    pickupLatitude,
    pickupLongitude,
    deliveryLatitude,
    deliveryLongitude,
    createdAtMinutes,
  ];
}

/// Delivery data containing all delivery information
class DeliveryData extends Equatable {
  final KPIDataEntity kpiData;
  final List<DriverEntity> drivers;
  final List<OrderEntity> orders;

  const DeliveryData({
    required this.kpiData,
    required this.drivers,
    required this.orders,
  });

  DeliveryData copyWith({
    KPIDataEntity? kpiData,
    List<DriverEntity>? drivers,
    List<OrderEntity>? orders,
  }) {
    return DeliveryData(
      kpiData: kpiData ?? this.kpiData,
      drivers: drivers ?? this.drivers,
      orders: orders ?? this.orders,
    );
  }

  @override
  List<Object?> get props => [kpiData, drivers, orders];
}
