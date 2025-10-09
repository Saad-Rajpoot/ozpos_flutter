import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrdersManagementState extends Equatable {
  const OrdersManagementState();

  @override
  List<Object?> get props => [];
}

class OrdersManagementInitial extends OrdersManagementState {
  const OrdersManagementInitial();
}

class OrdersManagementLoading extends OrdersManagementState {
  const OrdersManagementLoading();
}

class OrdersManagementLoaded extends OrdersManagementState {
  final List<OrderEntity> orders;

  const OrdersManagementLoaded({required this.orders});

  OrdersManagementLoaded copyWith({List<OrderEntity>? orders}) {
    return OrdersManagementLoaded(orders: orders ?? this.orders);
  }

  @override
  List<Object?> get props => [orders];
}

class OrdersManagementError extends OrdersManagementState {
  final String message;

  const OrdersManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
