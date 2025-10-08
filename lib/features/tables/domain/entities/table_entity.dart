import 'package:equatable/equatable.dart';

/// Table status enum
enum TableStatus { available, occupied, reserved, cleaning }

/// Table entity for restaurant floor management
class TableEntity extends Equatable {
  final String id;
  final String number; // "3", "5A", etc.
  final int seats; // Capacity
  final TableStatus status;
  final String? serverName; // Assigned server
  final String? orderId; // Current order if occupied
  final double? currentBill; // Current bill amount if occupied
  final int? floorX; // X position on floor view (0-10)
  final int? floorY; // Y position on floor view (0-10)

  const TableEntity({
    required this.id,
    required this.number,
    required this.seats,
    required this.status,
    this.serverName,
    this.orderId,
    this.currentBill,
    this.floorX,
    this.floorY,
  });

  @override
  List<Object?> get props => [
    id,
    number,
    seats,
    status,
    serverName,
    orderId,
    currentBill,
    floorX,
    floorY,
  ];
}
