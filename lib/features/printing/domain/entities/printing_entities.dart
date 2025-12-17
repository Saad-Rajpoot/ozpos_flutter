import 'package:equatable/equatable.dart';

/// Printer entity - represents a printer device
class PrinterEntity extends Equatable {
  final String id;
  final String name;
  final PrinterType type;
  final PrinterConnection connection;
  final String? address; // IP address or Bluetooth MAC address
  final int? port; // For network printers
  final bool isConnected;
  final bool isDefault;
  final DateTime? lastUsedAt;

  const PrinterEntity({
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

  PrinterEntity copyWith({
    String? id,
    String? name,
    PrinterType? type,
    PrinterConnection? connection,
    String? address,
    int? port,
    bool? isConnected,
    bool? isDefault,
    DateTime? lastUsedAt,
  }) {
    return PrinterEntity(
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

/// Print job entity - represents a print job
class PrintJobEntity extends Equatable {
  final String id;
  final String printerId;
  final String printerName;
  final PrintJobStatus status;
  final PrintJobType jobType;
  final String content; // Raw print content or receipt data
  final String? title;
  final int? copies;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;

  const PrintJobEntity({
    required this.id,
    required this.printerId,
    required this.printerName,
    required this.status,
    required this.jobType,
    required this.content,
    this.title,
    this.copies,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
  });

  PrintJobEntity copyWith({
    String? id,
    String? printerId,
    String? printerName,
    PrintJobStatus? status,
    PrintJobType? jobType,
    String? content,
    String? title,
    int? copies,
    DateTime? createdAt,
    DateTime? completedAt,
    String? errorMessage,
  }) {
    return PrintJobEntity(
      id: id ?? this.id,
      printerId: printerId ?? this.printerId,
      printerName: printerName ?? this.printerName,
      status: status ?? this.status,
      jobType: jobType ?? this.jobType,
      content: content ?? this.content,
      title: title ?? this.title,
      copies: copies ?? this.copies,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        printerId,
        printerName,
        status,
        jobType,
        content,
        title,
        copies,
        createdAt,
        completedAt,
        errorMessage,
      ];
}

/// Printer type enum
enum PrinterType {
  receipt,
  kitchen,
  label,
  invoice,
  barista,
}

/// Printer connection type enum
enum PrinterConnection {
  bluetooth,
  network,
  usb,
}

/// Print job status enum
enum PrintJobStatus {
  pending,
  printing,
  completed,
  failed,
  cancelled,
}

/// Print job type enum
enum PrintJobType {
  receipt,
  kitchen,
  label,
  invoice,
  barista,
}
