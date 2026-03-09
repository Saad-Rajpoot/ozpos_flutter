import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/base/base_usecase.dart';
import '../../../../core/base/base_bloc.dart';
import '../../domain/usecases/generate_report_pdf_usecase.dart';
import '../../domain/usecases/get_reports_data.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends BaseBloc<ReportsEvent, ReportsState> {
  final GetReportsData _getReportsData;
  final GenerateReportPdfUseCase _generateReportPdfUseCase;

  ReportsBloc({
    required GetReportsData getReportsData,
    required GenerateReportPdfUseCase generateReportPdfUseCase,
  })  : _getReportsData = getReportsData,
        _generateReportPdfUseCase = generateReportPdfUseCase,
        super(const ReportsInitial()) {
    on<LoadReportsDataEvent>(_onLoadReports);
    on<GenerateReportPdfEvent>(_onGenerateReportPdf);
  }

  Future<void> _onLoadReports(
    LoadReportsDataEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    final result = await _getReportsData(const NoParams());

    result.fold(
      (failure) {
        emit(ReportsError('Failed to load reports: ${failure.message}'));
      },
      (reportsData) {
        emit(ReportsLoaded(reportsData: reportsData));
      },
    );
  }

  Future<void> _onGenerateReportPdf(
    GenerateReportPdfEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportPdfGenerating(event.report));

    final result = await _generateReportPdfUseCase(event.report);

    result.fold(
      (failure) {
        emit(ReportPdfError(
          reportsData: event.report,
          message: failure.message,
        ));
      },
      (file) {
        emit(ReportPdfGenerated(
          reportsData: event.report,
          file: file,
        ));
      },
    );
  }
}
