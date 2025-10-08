import 'package:equatable/equatable.dart';
import '../../domain/entities/table_entity.dart';

abstract class TableManagementState extends Equatable {
  const TableManagementState();

  @override
  List<Object?> get props => [];
}

class TableManagementInitial extends TableManagementState {
  const TableManagementInitial();
}

class TableManagementLoading extends TableManagementState {
  const TableManagementLoading();
}

class TableManagementLoaded extends TableManagementState {
  final List<TableEntity> tables;

  const TableManagementLoaded({required this.tables});

  TableManagementLoaded copyWith({List<TableEntity>? tables}) {
    return TableManagementLoaded(tables: tables ?? this.tables);
  }

  @override
  List<Object?> get props => [tables];
}

class TableManagementError extends TableManagementState {
  final String message;

  const TableManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
