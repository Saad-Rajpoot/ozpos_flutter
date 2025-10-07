import '../../../delivery/domain/entities/delivery_entities.dart';

class MockDeliveryData {
  static DeliveryKpiData getKpis() {
    return const DeliveryKpiData(
      activeDrivers: 3,
      inProgress: 2,
      delayedOrders: 1,
      avgEtaMinutes: 22,
    );
  }

  static List<DriverEntity> getDrivers() {
    return const [
      DriverEntity(
        id: 'd1',
        name: 'Sam Carter',
        status: DriverStatus.online,
        role: 'Self-managed',
        zone: 'Downtown',
        currentOrders: 2,
        maxCapacity: 3,
        avgTimeMinutes: 21,
        todayEarnings: 68.00,
        latitude: 40.7580,
        longitude: -73.9855,
      ),
      DriverEntity(
        id: 'd2',
        name: 'Mia Lopez',
        status: DriverStatus.busy,
        role: 'Self-managed',
        zone: 'Uptown',
        currentOrders: 3,
        maxCapacity: 3,
        avgTimeMinutes: 18,
        todayEarnings: 92.50,
        latitude: 40.7680,
        longitude: -73.9820,
      ),
      DriverEntity(
        id: 'd3',
        name: 'James Wilson',
        status: DriverStatus.online,
        role: 'Company',
        zone: 'Downtown',
        currentOrders: 1,
        maxCapacity: 4,
        avgTimeMinutes: 25,
        todayEarnings: 45.00,
        latitude: 40.7500,
        longitude: -73.9900,
      ),
    ];
  }

  static List<DeliveryOrderEntity> getOrders() {
    final now = DateTime.now();

    return [
      DeliveryOrderEntity(
        id: 'o1',
        orderNumber: '#1042',
        channel: OrderChannel.website,
        status: DeliveryOrderStatus.ready,
        customerName: 'Alex Brown',
        address: '221 King St, Newtown',
        items: ['2x Chicken Bowl', '1x Coke'],
        pickupEtaMinutes: 4,
        deliveryEtaMinutes: 22,
        pickupLatitude: 40.7589,
        pickupLongitude: -73.9851,
        deliveryLatitude: 40.7650,
        deliveryLongitude: -73.9800,
        createdAt: now.subtract(const Duration(minutes: 8)),
      ),
      DeliveryOrderEntity(
        id: 'o2',
        orderNumber: '#1043',
        channel: OrderChannel.uberEats,
        status: DeliveryOrderStatus.delayed,
        customerName: 'Priya S',
        address: '18 George St, CBD',
        items: ['3x Burger', '2x Fries', '1x Shake'],
        pickupEtaMinutes: 2,
        deliveryEtaMinutes: 35,
        assignedDriverId: 'd2',
        pickupLatitude: 40.7589,
        pickupLongitude: -73.9851,
        deliveryLatitude: 40.7700,
        deliveryLongitude: -73.9750,
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
      DeliveryOrderEntity(
        id: 'o3',
        orderNumber: '#1044',
        channel: OrderChannel.doorDash,
        status: DeliveryOrderStatus.inProgress,
        customerName: 'Michael Chen',
        address: '45 Main Ave, Newtown',
        items: ['1x Pizza', '1x Salad'],
        pickupEtaMinutes: 0,
        deliveryEtaMinutes: 12,
        assignedDriverId: 'd1',
        pickupLatitude: 40.7589,
        pickupLongitude: -73.9851,
        deliveryLatitude: 40.7620,
        deliveryLongitude: -73.9880,
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
      DeliveryOrderEntity(
        id: 'o4',
        orderNumber: '#1045',
        channel: OrderChannel.app,
        status: DeliveryOrderStatus.ready,
        customerName: 'Sarah Johnson',
        address: '92 Park St, Downtown',
        items: ['4x Tacos', '2x Drinks'],
        pickupEtaMinutes: 6,
        deliveryEtaMinutes: 18,
        pickupLatitude: 40.7589,
        pickupLongitude: -73.9851,
        deliveryLatitude: 40.7550,
        deliveryLongitude: -73.9920,
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
    ];
  }
}
