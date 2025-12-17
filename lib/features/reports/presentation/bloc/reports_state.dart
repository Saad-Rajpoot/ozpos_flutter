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
