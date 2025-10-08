import '../../domain/entities/addon_management_entities.dart';

/// Remote data source interface for addons
abstract class AddonDataSource {
  /// Get all addon categories
  Future<List<AddonCategory>> getAddonCategories();
}
