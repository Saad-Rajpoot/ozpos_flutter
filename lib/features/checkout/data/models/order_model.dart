import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'order_item.dart';
import 'payment_details.dart';
import 'tender_model.dart';
import 'voucher_model.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_type.dart';

OrderModel orderModelFromJson(String str) =>
    OrderModel.fromJson(json.decode(str));

String orderModelToJson(OrderModel data) => json.encode(data.toJson());

// Order model matching the JSON structure
class OrderModel extends Equatable {
  final String id;
  final String orderId;
  final String customerName;
  final String? tableNumber;
  final OrderType orderType;
  final List<OrderItem> items;
  final PaymentDetails payment;
  final List<TenderModel> tenders;
  final List<VoucherModel> vouchers;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String staffId;
  final String staffName;

  const OrderModel({
    required this.id,
    required this.orderId,
    required this.customerName,
    this.tableNumber,
    required this.orderType,
    required this.items,
    required this.payment,
    required this.tenders,
    required this.vouchers,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.staffId,
    required this.staffName,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      customerName: json['customerName'] as String,
      tableNumber: json['tableNumber'] as String?,
      orderType: OrderType.fromString(json['orderType'] as String),
      items: List<OrderItem>.from(
        json['items'].map((x) => OrderItem.fromJson(x)),
      ),
      payment: PaymentDetails.fromJson(json['payment']),
      tenders: List<TenderModel>.from(
        json['tenders'].map((x) => TenderModel.fromJson(x)),
      ),
      vouchers: List<VoucherModel>.from(
        json['vouchers'].map((x) => VoucherModel.fromJson(x)),
      ),
      status: OrderStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'customerName': customerName,
      'tableNumber': tableNumber,
      'orderType': orderType.value,
      'items': List<dynamic>.from(items.map((x) => x.toJson())),
      'payment': payment.toJson(),
      'tenders': List<dynamic>.from(tenders.map((x) => x.toJson())),
      'vouchers': List<dynamic>.from(vouchers.map((x) => x.toJson())),
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'staffId': staffId,
      'staffName': staffName,
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        customerName,
        tableNumber,
        orderType,
        items,
        payment,
        tenders,
        vouchers,
        status,
        createdAt,
        completedAt,
        staffId,
        staffName,
      ];

  // Convert to domain entity
  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      orderId: orderId,
      customerName: customerName,
      tableNumber: tableNumber,
      orderType: orderType,
      items: items.map((item) => item.toEntity()).toList(),
      payment: payment.toEntity(),
      tenders: tenders.map((tender) => tender.toEntity()).toList(),
      vouchers: vouchers.map((voucher) => voucher.toEntity()).toList(),
      status: status,
      createdAt: createdAt,
      completedAt: completedAt,
      staffId: staffId,
      staffName: staffName,
    );
  }

  // Create from domain entity
  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      orderId: entity.orderId,
      customerName: entity.customerName,
      tableNumber: entity.tableNumber,
      orderType: entity.orderType,
      items: entity.items.map((item) => OrderItem.fromEntity(item)).toList(),
      payment: PaymentDetails.fromEntity(entity.payment),
      tenders: entity.tenders
          .map((tender) => TenderModel.fromEntity(tender))
          .toList(),
      vouchers: entity.vouchers
          .map((voucher) => VoucherModel.fromEntity(voucher))
          .toList(),
      status: entity.status,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
      staffId: entity.staffId,
      staffName: entity.staffName,
    );
  }
}
