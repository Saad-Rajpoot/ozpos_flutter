import '../../../../core/base/base_bloc.dart';

abstract class OrdersManagementEvent extends BaseEvent {
  const OrdersManagementEvent();
}

/// Load all orders from data source
class LoadOrdersEvent extends OrdersManagementEvent {
  const LoadOrdersEvent();
}
