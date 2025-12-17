import '../../../../core/base/base_bloc.dart';

abstract class TableManagementEvent extends BaseEvent {
  const TableManagementEvent();
}

/// Load all tables from JSON file
class LoadTablesEvent extends TableManagementEvent {
  const LoadTablesEvent();
}

/// Load all available tables for move operations
class LoadMoveAvailableTablesEvent extends TableManagementEvent {
  const LoadMoveAvailableTablesEvent();
}
