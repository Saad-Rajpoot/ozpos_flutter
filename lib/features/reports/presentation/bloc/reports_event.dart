import '../../../../core/base/base_bloc.dart';

abstract class ReportsEvent extends BaseEvent {
  const ReportsEvent();
}

/// Load all reports data from JSON file
class LoadReportsDataEvent extends ReportsEvent {
  const LoadReportsDataEvent();
}
