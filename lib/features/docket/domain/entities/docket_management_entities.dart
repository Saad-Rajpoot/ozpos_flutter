import 'package:equatable/equatable.dart';

/// Docket entity that represents an order or receipt
class DocketEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final DocketStatus status;
  final double totalAmount;
  final List<DocketItemEntity> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String tableNumber;
  final String customerName;
  final PaymentMethod paymentMethod;

  const DocketEntity({
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

  DocketEntity copyWith({
    String? id,
    String? name,
    String? description,
    DocketStatus? status,
    double? totalAmount,
    List<DocketItemEntity>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? tableNumber,
    String? customerName,
    PaymentMethod? paymentMethod,
  }) {
    return DocketEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tableNumber: tableNumber ?? this.tableNumber,
      customerName: customerName ?? this.customerName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
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

/// Docket item entity
class DocketItemEntity extends Equatable {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const DocketItemEntity({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [id, name, quantity, unitPrice, totalPrice];
}

/// Docket status enum
enum DocketStatus { pending, preparing, ready, served, cancelled }

/// Payment method enum
enum PaymentMethod { cash, card, digital }
