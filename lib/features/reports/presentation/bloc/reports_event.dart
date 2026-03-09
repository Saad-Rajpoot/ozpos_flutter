import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/reports_entities.dart';

abstract class ReportsEvent extends BaseEvent {
  const ReportsEvent();
}

/// Load all reports data from JSON file
class LoadReportsDataEvent extends ReportsEvent {
  const LoadReportsDataEvent();
}

/// Generate PDF from current report and save locally
class GenerateReportPdfEvent extends ReportsEvent {
  final ReportsData report;

  const GenerateReportPdfEvent(this.report);

  @override
  List<Object?> get props => [report];
}
