import 'package:equatable/equatable.dart';

abstract class ReservationManagementEvent extends Equatable {
  const ReservationManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadReservationsEvent extends ReservationManagementEvent {
  const LoadReservationsEvent();
}
