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
}
