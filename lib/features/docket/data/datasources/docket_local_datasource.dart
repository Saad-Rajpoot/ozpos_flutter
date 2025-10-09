import '../../domain/entities/docket_management_entities.dart';
import 'docket_data_source.dart';
import 'package:sqflite/sqflite.dart';
import '../models/docket_model.dart';

/// Local data source implementation for dockets
/// This would typically use SharedPreferences or SQLite for persistence
class DocketLocalDataSourceImpl implements DocketDataSource {
  final Database database;

  DocketLocalDataSourceImpl({required this.database});

  @override
  Future<List<DocketEntity>> getDockets() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final data = await database.query('dockets');
      return data.map((json) => DocketModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to load dockets from local database');
    }
  }
}
