import 'package:equatable/equatable.dart';
import 'order_item_entity.dart';
import 'payment_details_entity.dart';
import 'tender_entity.dart';
import 'voucher_entity.dart';
import 'order_status.dart';
import 'order_type.dart';

class OrderEntity extends Equatable {
  final String id;
  final String orderId;
  final String customerName;
  final String? tableNumber;
  final OrderType orderType;
  final List<OrderItemEntity> items;
  final PaymentDetailsEntity payment;
  final List<TenderEntity> tenders;
  final List<VoucherEntity> vouchers;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String staffId;
  final String staffName;

  const OrderEntity({
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
}
