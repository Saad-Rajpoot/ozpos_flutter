import 'package:equatable/equatable.dart';
import '../../domain/entities/docket_management_entities.dart';
import 'docket_item_model.dart';

/// Model class for Docket JSON serialization/deserialization
class DocketModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String status;
  final double totalAmount;
  final List<DocketItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String tableNumber;
  final String customerName;
  final String paymentMethod;

  const DocketModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    required this.tableNumber,
    required this.customerName,
    required this.paymentMethod,
  });

  /// Convert JSON to DocketModel
  factory DocketModel.fromJson(Map<String, dynamic> json) {
    return DocketModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) =>
                    DocketItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          <DocketItemModel>[],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tableNumber: json['tableNumber'] as String,
      customerName: json['customerName'] as String,
      paymentMethod: json['paymentMethod'] as String,
    );
  }

  /// Convert DocketModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tableNumber': tableNumber,
      'customerName': customerName,
      'paymentMethod': paymentMethod,
    };
  }

  /// Convert DocketModel to Docket entity
  DocketEntity toEntity() {
    return DocketEntity(
      id: id,
      name: name,
      description: description,
      status: _stringToDocketStatus(status),
      totalAmount: totalAmount,
      items: items.map((item) => item.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      tableNumber: tableNumber,
      customerName: customerName,
      paymentMethod: _stringToPaymentMethod(paymentMethod),
    );
  }

  /// Create DocketModel from Docket entity
  factory DocketModel.fromEntity(DocketEntity entity) {
    return DocketModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      status: _docketStatusToString(entity.status),
      totalAmount: entity.totalAmount,
      items: entity.items
          .map((item) => DocketItemModel.fromEntity(item))
          .toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      tableNumber: entity.tableNumber,
      customerName: entity.customerName,
      paymentMethod: _paymentMethodToString(entity.paymentMethod),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    status,
    totalAmount,
    items,
    createdAt,
    updatedAt,
    tableNumber,
    customerName,
    paymentMethod,
  ];
}

// Helper functions for enum conversion
DocketStatus _stringToDocketStatus(String status) {
  switch (status) {
    case 'pending':
      return DocketStatus.pending;
    case 'preparing':
      return DocketStatus.preparing;
    case 'ready':
      return DocketStatus.ready;
    case 'served':
      return DocketStatus.served;
    case 'cancelled':
      return DocketStatus.cancelled;
    default:
      return DocketStatus.pending;
  }
}

String _docketStatusToString(DocketStatus status) {
  switch (status) {
    case DocketStatus.pending:
      return 'pending';
    case DocketStatus.preparing:
      return 'preparing';
    case DocketStatus.ready:
      return 'ready';
    case DocketStatus.served:
      return 'served';
    case DocketStatus.cancelled:
      return 'cancelled';
  }
}

PaymentMethod _stringToPaymentMethod(String method) {
  switch (method) {
    case 'cash':
      return PaymentMethod.cash;
    case 'card':
      return PaymentMethod.card;
    case 'digital':
      return PaymentMethod.digital;
    default:
      return PaymentMethod.cash;
  }
}

String _paymentMethodToString(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return 'cash';
    case PaymentMethod.card:
      return 'card';
    case PaymentMethod.digital:
      return 'digital';
  }
}
