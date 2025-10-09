import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_usecase.dart';
import 'docket_management_event.dart';
import 'docket_management_state.dart';
import '../../domain/usecases/get_dockets.dart';

class DocketManagementBloc
    extends Bloc<DocketManagementEvent, DocketManagementState> {
  final GetDockets _getDockets;

  DocketManagementBloc({required GetDockets getDockets})
    : _getDockets = getDockets,
      super(const DocketManagementInitial()) {
    on<LoadDocketsEvent>(_onLoadDockets);
  }

  Future<void> _onLoadDockets(
    LoadDocketsEvent event,
    Emitter<DocketManagementState> emit,
  ) async {
    emit(const DocketManagementLoading());

    final result = await _getDockets(const NoParams());

    result.fold(
      (failure) => emit(
        DocketManagementError('Failed to load dockets: ${failure.message}'),
      ),
      (dockets) => emit(DocketManagementLoaded(dockets: dockets)),
    );
  }
}
