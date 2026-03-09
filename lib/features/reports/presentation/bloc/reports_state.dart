import 'dart:io';

import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/reports_entities.dart';

abstract class ReportsState extends BaseState {
  const ReportsState();
}

class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

class ReportsLoaded extends ReportsState {
  final ReportsData reportsData;

  const ReportsLoaded({required this.reportsData});

  ReportsLoaded copyWith({ReportsData? reportsData}) {
    return ReportsLoaded(reportsData: reportsData ?? this.reportsData);
  }

  @override
  List<Object?> get props => [reportsData];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportPdfGenerating extends ReportsState {
  final ReportsData reportsData;

  const ReportPdfGenerating(this.reportsData);

  @override
  List<Object?> get props => [reportsData];
}

class ReportPdfGenerated extends ReportsState {
  final ReportsData reportsData;
  final File file;

  const ReportPdfGenerated({
    required this.reportsData,
    required this.file,
  });

  @override
  List<Object?> get props => [reportsData, file];
}

class ReportPdfError extends ReportsState {
  final ReportsData reportsData;
  final String message;

  const ReportPdfError({
    required this.reportsData,
    required this.message,
  });

  @override
  List<Object?> get props => [reportsData, message];
}

/// Extension to get reportsData from any state that contains it
extension ReportsStateX on ReportsState {
  ReportsData? get reportsDataOrNull {
    return switch (this) {
      ReportsLoaded s => s.reportsData,
      ReportPdfGenerating s => s.reportsData,
      ReportPdfGenerated s => s.reportsData,
      ReportPdfError s => s.reportsData,
      _ => null,
    };
  }

  bool get isPdfGenerating => this is ReportPdfGenerating;
}
