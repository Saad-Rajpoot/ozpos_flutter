import 'package:equatable/equatable.dart';

abstract class TableManagementEvent extends Equatable {
  const TableManagementEvent();

  @override
  List<Object?> get props => [];
}

/// Load all tables from JSON file
class LoadTablesEvent extends TableManagementEvent {
  const LoadTablesEvent();
}

/// Load all available tables for move operations
class LoadMoveAvailableTablesEvent extends TableManagementEvent {
  const LoadMoveAvailableTablesEvent();
}
