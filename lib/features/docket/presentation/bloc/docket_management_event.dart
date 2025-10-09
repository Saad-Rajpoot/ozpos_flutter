import 'package:equatable/equatable.dart';

abstract class DocketManagementEvent extends Equatable {
  const DocketManagementEvent();

  @override
  List<Object?> get props => [];
}

/// Load all dockets from data source
class LoadDocketsEvent extends DocketManagementEvent {
  const LoadDocketsEvent();
}
