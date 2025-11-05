import '../../../../core/base/base_bloc.dart';

abstract class ReservationManagementEvent extends BaseEvent {
  const ReservationManagementEvent();
}

class LoadReservationsEvent extends ReservationManagementEvent {
  const LoadReservationsEvent();
}
