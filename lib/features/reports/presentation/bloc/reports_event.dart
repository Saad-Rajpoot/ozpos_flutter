import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all reports data from JSON file
class LoadReportsDataEvent extends ReportsEvent {
  const LoadReportsDataEvent();
}
