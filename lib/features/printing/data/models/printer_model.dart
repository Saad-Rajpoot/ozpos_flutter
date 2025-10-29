import 'package:equatable/equatable.dart';
import '../../domain/entities/printing_entities.dart';

/// Printer model for JSON serialization
class PrinterModel extends Equatable {
  final String id;
  final String name;
  final String type; // 'receipt', 'kitchen', 'label', 'invoice'
  final String connection; // 'bluetooth', 'network', 'usb'
  final String? address;
  final int? port;
  final bool isConnected;
  final bool isDefault;
  final String? lastUsedAt;

  const PrinterModel({
    required this.id,
    required this.name,
    required this.type,
    required this.connection,
    this.address,
    this.port,
    this.isConnected = false,
    this.isDefault = false,
    this.lastUsedAt,
  });

  /// Convert JSON to PrinterModel
  factory PrinterModel.fromJson(Map<String, dynamic> json) {
    return PrinterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      connection: json['connection'] as String,
      address: json['address'] as String?,
      port: json['port'] as int?,
      isConnected: json['isConnected'] as bool? ?? false,
      isDefault: json['isDefault'] as bool? ?? false,
      lastUsedAt: json['lastUsedAt'] as String?,
    );
  }

  /// Convert PrinterModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'connection': connection,
      if (address != null) 'address': address,
      if (port != null) 'port': port,
      'isConnected': isConnected,
      'isDefault': isDefault,
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt,
    };
  }

  /// Convert PrinterModel to PrinterEntity
  PrinterEntity toEntity() {
    return PrinterEntity(
      id: id,
      name: name,
      type: _stringToPrinterType(type),
      connection: _stringToPrinterConnection(connection),
      address: address,
      port: port,
      isConnected: isConnected,
      isDefault: isDefault,
      lastUsedAt: lastUsedAt != null ? DateTime.parse(lastUsedAt!) : null,
    );
  }

  /// Create PrinterModel from PrinterEntity
  factory PrinterModel.fromEntity(PrinterEntity entity) {
    return PrinterModel(
      id: entity.id,
      name: entity.name,
      type: _printerTypeToString(entity.type),
      connection: _printerConnectionToString(entity.connection),
      address: entity.address,
      port: entity.port,
      isConnected: entity.isConnected,
      isDefault: entity.isDefault,
      lastUsedAt: entity.lastUsedAt?.toIso8601String(),
    );
  }

  /// Create a copy with updated fields
  PrinterModel copyWith({
    String? id,
    String? name,
    String? type,
    String? connection,
    String? address,
    int? port,
    bool? isConnected,
    bool? isDefault,
    String? lastUsedAt,
  }) {
    return PrinterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      connection: connection ?? this.connection,
      address: address ?? this.address,
      port: port ?? this.port,
      isConnected: isConnected ?? this.isConnected,
      isDefault: isDefault ?? this.isDefault,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        connection,
        address,
        port,
        isConnected,
        isDefault,
        lastUsedAt,
      ];
}

// Helper functions for enum conversion
PrinterType _stringToPrinterType(String type) {
  switch (type) {
    case 'receipt':
      return PrinterType.receipt;
    case 'kitchen':
      return PrinterType.kitchen;
    case 'label':
      return PrinterType.label;
    case 'invoice':
      return PrinterType.invoice;
    default:
      return PrinterType.receipt;
  }
}

String _printerTypeToString(PrinterType type) {
  switch (type) {
    case PrinterType.receipt:
      return 'receipt';
    case PrinterType.kitchen:
      return 'kitchen';
    case PrinterType.label:
      return 'label';
    case PrinterType.invoice:
      return 'invoice';
  }
}

PrinterConnection _stringToPrinterConnection(String connection) {
  switch (connection) {
    case 'bluetooth':
      return PrinterConnection.bluetooth;
    case 'network':
      return PrinterConnection.network;
    case 'usb':
      return PrinterConnection.usb;
    default:
      return PrinterConnection.bluetooth;
  }
}

String _printerConnectionToString(PrinterConnection connection) {
  switch (connection) {
    case PrinterConnection.bluetooth:
      return 'bluetooth';
    case PrinterConnection.network:
      return 'network';
    case PrinterConnection.usb:
      return 'usb';
  }
}
