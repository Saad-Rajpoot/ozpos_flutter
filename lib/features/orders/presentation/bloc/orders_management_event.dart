import 'package:equatable/equatable.dart';

abstract class OrdersManagementEvent extends Equatable {
  const OrdersManagementEvent();

  @override
  List<Object?> get props => [];
}

/// Load all orders from data source
class LoadOrdersEvent extends OrdersManagementEvent {
  const LoadOrdersEvent();
}
