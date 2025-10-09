import 'package:equatable/equatable.dart';
import '../../domain/entities/docket_management_entities.dart';

abstract class DocketManagementState extends Equatable {
  const DocketManagementState();

  @override
  List<Object?> get props => [];
}

class DocketManagementInitial extends DocketManagementState {
  const DocketManagementInitial();
}

class DocketManagementLoading extends DocketManagementState {
  const DocketManagementLoading();
}

class DocketManagementLoaded extends DocketManagementState {
  final List<DocketEntity> dockets;

  const DocketManagementLoaded({required this.dockets});

  DocketManagementLoaded copyWith({List<DocketEntity>? dockets}) {
    return DocketManagementLoaded(dockets: dockets ?? this.dockets);
  }

  @override
  List<Object?> get props => [dockets];
}

class DocketManagementError extends DocketManagementState {
  final String message;

  const DocketManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
