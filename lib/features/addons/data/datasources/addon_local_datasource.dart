import '../../domain/entities/addon_management_entities.dart';
import '../../../../core/errors/exceptions.dart';
import '../model/addon_category_model.dart';
import 'addon_data_source.dart';
import 'package:sqflite/sqflite.dart';

class AddonLocalDataSourceImpl implements AddonDataSource {
  final Database database;

  AddonLocalDataSourceImpl({required this.database});

  @override
  Future<List<AddonCategory>> getAddonCategories() async {
    try {
      // Assuming a local table named 'addon_categories'
      final List<Map<String, dynamic>> maps = await database.query(
        'addon_categories',
      );
      return maps
          .map((json) => AddonCategoryModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch addon categories from local database',
      );
    }
  }
}
