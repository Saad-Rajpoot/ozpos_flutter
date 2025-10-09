import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_usecase.dart';
import 'delivery_event.dart';
import 'delivery_state.dart';
import '../../domain/usecases/get_delivery_data.dart';

class DeliveryBloc extends Bloc<DeliveryEvent, DeliveryState> {
  final GetDeliveryData _getDeliveryData;

  DeliveryBloc({required GetDeliveryData getDeliveryData})
    : _getDeliveryData = getDeliveryData,
      super(const DeliveryInitial()) {
    on<LoadDeliveryDataEvent>(_onLoadDeliveryData);
  }

  Future<void> _onLoadDeliveryData(
    LoadDeliveryDataEvent event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(const DeliveryLoading());

    final result = await _getDeliveryData(const NoParams());

    result.fold(
      (failure) => emit(
        DeliveryError('Failed to load delivery data: ${failure.message}'),
      ),
      (deliveryData) => emit(DeliveryLoaded(deliveryData: deliveryData)),
    );
  }
}
