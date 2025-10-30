import '../../../../core/errors/exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'settings_data_source.dart';
import '../../domain/entities/settings_entities.dart';
import '../models/settings_category_model.dart';

class SettingsLocalDataSourceImpl implements SettingsDataSource {
  final Database database;

  SettingsLocalDataSourceImpl({required this.database});

  @override
  Future<List<SettingsCategoryEntity>> getCategories() async {
    try {
      final List<Map<String, dynamic>> maps =
          await database.query('settings_categories');
      return maps
          .map((json) => SettingsCategoryModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw CacheException(
          message:
              'Failed to fetch settings from local database: ${e.toString()}');
    }
  }
}
