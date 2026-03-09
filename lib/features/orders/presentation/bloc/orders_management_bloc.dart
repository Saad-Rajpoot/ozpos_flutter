import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/base/base_bloc.dart';
import 'orders_management_event.dart';
import 'orders_management_state.dart';
import '../../domain/usecases/get_orders.dart';

class OrdersManagementBloc
    extends BaseBloc<OrdersManagementEvent, OrdersManagementState> {
  final GetOrders _getOrders;

  OrdersManagementBloc({required GetOrders getOrders})
    : _getOrders = getOrders,
      super(const OrdersManagementInitial()) {
    on<LoadOrdersEvent>(_onLoadOrders);
    on<RefreshOrdersSilentlyEvent>(_onRefreshOrdersSilently);
  }

  Future<void> _onLoadOrders(
    LoadOrdersEvent event,
    Emitter<OrdersManagementState> emit,
  ) async {
    emit(const OrdersManagementLoading());

    final result = await _getOrders(const NoParams());

    result.fold(
      (failure) => emit(
        OrdersManagementError('Failed to load orders: ${failure.message}'),
      ),
      (orders) => emit(OrdersManagementLoaded(orders: orders)),
    );
  }

  Future<void> _onRefreshOrdersSilently(
    RefreshOrdersSilentlyEvent event,
    Emitter<OrdersManagementState> emit,
  ) async {
    final previousState = state;

    final result = await _getOrders(const NoParams());

    result.fold(
      (failure) {
        // Keep previous state on failure to avoid jarring UI changes.
        if (previousState is OrdersManagementLoaded) {
          emit(previousState);
        } else {
          emit(
            OrdersManagementError(
              'Failed to refresh orders: ${failure.message}',
            ),
          );
        }
      },
      (orders) => emit(OrdersManagementLoaded(orders: orders)),
    );
  }
}
