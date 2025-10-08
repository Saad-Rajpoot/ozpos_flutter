import '../../domain/entities/table_entity.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/table_model.dart';
import 'table_data_source.dart';
import 'package:sqflite/sqflite.dart';

class TableLocalDataSourceImpl implements TableDataSource {
  final Database database;

  TableLocalDataSourceImpl({required this.database});

  @override
  Future<List<TableEntity>> getTables() async {
    try {
      // Assuming a local table named 'tables'
      final List<Map<String, dynamic>> maps = await database.query('tables');
      return maps.map((json) => TableModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch tables from local database',
      );
    }
  }

  @override
  Future<List<TableEntity>> getMoveAvailableTables() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'move_tables',
      );
      return maps.map((json) => TableModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch move available tables from local database',
      );
    }
  }
}
