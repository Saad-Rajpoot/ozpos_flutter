import 'package:equatable/equatable.dart';
import '../../domain/entities/reservation_entity.dart';

abstract class ReservationManagementState extends Equatable {
  const ReservationManagementState();

  @override
  List<Object?> get props => [];
}

class ReservationManagementInitial extends ReservationManagementState {
  const ReservationManagementInitial();
}

class ReservationManagementLoading extends ReservationManagementState {
  const ReservationManagementLoading();
}

class ReservationManagementLoaded extends ReservationManagementState {
  final List<ReservationEntity> reservations;

  const ReservationManagementLoaded({required this.reservations});

  @override
  List<Object?> get props => [reservations];
}

class ReservationManagementError extends ReservationManagementState {
  final String message;

  const ReservationManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
