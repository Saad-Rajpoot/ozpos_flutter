import 'package:equatable/equatable.dart';
import '../../domain/entities/table_entity.dart';

/// Model class for Table JSON serialization/deserialization
class TableModel extends Equatable {
  final String id;
  final String number;
  final int seats;
  final TableStatus status;
  final String? serverName;
  final String? orderId;
  final double? currentBill;
  final int? floorX;
  final int? floorY;

  const TableModel({
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

  /// Convert JSON to TableModel
  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] as String? ?? 'table_${json['number']}',
      number: json['number'].toString(),
      seats: json['seats'] as int? ?? 4, // Default seats if not provided
      status: _parseStatus(json['status'] as String?),
      serverName: json['serverTag'] as String?,
      orderId: json['orderId'] as String?,
      currentBill: json['amount']?.toDouble(),
      floorX: json['floorX'] as int?,
      floorY: json['floorY'] as int?,
    );
  }

  /// Convert TableModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'seats': seats,
      'status': status.toString().split('.').last,
      'serverTag': serverName,
      'orderId': orderId,
      'amount': currentBill,
      'floorX': floorX,
      'floorY': floorY,
    };
  }

  /// Convert TableModel to TableEntity
  TableEntity toEntity() {
    return TableEntity(
      id: id,
      number: number,
      seats: seats,
      status: status,
      serverName: serverName,
      orderId: orderId,
      currentBill: currentBill,
      floorX: floorX,
      floorY: floorY,
    );
  }

  /// Create TableModel from TableEntity
  factory TableModel.fromEntity(TableEntity entity) {
    return TableModel(
      id: entity.id,
      number: entity.number,
      seats: entity.seats,
      status: entity.status,
      serverName: entity.serverName,
      orderId: entity.orderId,
      currentBill: entity.currentBill,
      floorX: entity.floorX,
      floorY: entity.floorY,
    );
  }

  static TableStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return TableStatus.available;
      case 'occupied':
        return TableStatus.occupied;
      case 'reserved':
        return TableStatus.reserved;
      case 'cleaning':
        return TableStatus.cleaning;
      default:
        return TableStatus.available;
    }
  }

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
