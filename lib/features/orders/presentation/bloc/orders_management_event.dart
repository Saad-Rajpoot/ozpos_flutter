import '../../../../core/base/base_bloc.dart';

abstract class OrdersManagementEvent extends BaseEvent {
  const OrdersManagementEvent();
}

/// Load all orders from data source
class LoadOrdersEvent extends OrdersManagementEvent {
  const LoadOrdersEvent();
}

/// Refresh orders without showing a loading spinner.
/// Used for background updates (e.g. Firebase triggers).
class RefreshOrdersSilentlyEvent extends OrdersManagementEvent {
  const RefreshOrdersSilentlyEvent();
}
