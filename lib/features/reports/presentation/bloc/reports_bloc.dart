import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/base/base_bloc.dart';
import '../../domain/usecases/get_reports_data.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends BaseBloc<ReportsEvent, ReportsState> {
  final GetReportsData _getReportsData;

  ReportsBloc({required GetReportsData getReportsData})
    : _getReportsData = getReportsData,
      super(const ReportsInitial()) {
    on<LoadReportsDataEvent>(_onLoadReports);
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
}
