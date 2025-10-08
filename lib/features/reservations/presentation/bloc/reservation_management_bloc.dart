import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_usecase.dart';
import '../../domain/usecases/get_reservations.dart';
import 'reservation_management_event.dart';
import 'reservation_management_state.dart';

class ReservationManagementBloc
    extends Bloc<ReservationManagementEvent, ReservationManagementState> {
  final GetReservations _getReservations;

  ReservationManagementBloc({required GetReservations getReservations})
    : _getReservations = getReservations,
      super(const ReservationManagementInitial()) {
    on<LoadReservationsEvent>(_onLoadReservations);
  }

  Future<void> _onLoadReservations(
    LoadReservationsEvent event,
    Emitter<ReservationManagementState> emit,
  ) async {
    emit(const ReservationManagementLoading());

    final result = await _getReservations(const NoParams());

    result.fold(
      (failure) => emit(
        ReservationManagementError(
          'Failed to load reservations: ${failure.message}',
        ),
      ),
      (reservations) =>
          emit(ReservationManagementLoaded(reservations: reservations)),
    );
  }
}
