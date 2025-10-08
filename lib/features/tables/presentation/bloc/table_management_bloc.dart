import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_usecase.dart';
import 'table_management_event.dart';
import 'table_management_state.dart';
import '../../domain/usecases/get_tables.dart';
import '../../domain/usecases/get_available_tables.dart';

class TableManagementBloc
    extends Bloc<TableManagementEvent, TableManagementState> {
  final GetTables _getTables;
  final GetMoveAvailableTables _getMoveAvailableTables;

  TableManagementBloc({
    required GetTables getTables,
    required GetMoveAvailableTables getMoveAvailableTables,
  }) : _getTables = getTables,
       _getMoveAvailableTables = getMoveAvailableTables,
       super(const TableManagementInitial()) {
    on<LoadTablesEvent>(_onLoadTables);
    on<LoadMoveAvailableTablesEvent>(_onLoadAvailableTables);
  }

  Future<void> _onLoadTables(
    LoadTablesEvent event,
    Emitter<TableManagementState> emit,
  ) async {
    emit(const TableManagementLoading());

    final result = await _getTables(const NoParams());

    result.fold(
      (failure) => emit(
        TableManagementError('Failed to load tables: ${failure.message}'),
      ),
      (tables) => emit(TableManagementLoaded(tables: tables)),
    );
  }

  Future<void> _onLoadAvailableTables(
    LoadMoveAvailableTablesEvent event,
    Emitter<TableManagementState> emit,
  ) async {
    emit(const TableManagementLoading());

    final result = await _getMoveAvailableTables(const NoParams());

    result.fold(
      (failure) => emit(
        TableManagementError(
          'Failed to load available tables: ${failure.message}',
        ),
      ),
      (tables) => emit(TableManagementLoaded(tables: tables)),
    );
  }
}
