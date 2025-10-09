import '../../domain/entities/docket_management_entities.dart';

/// Remote data source interface for dockets
abstract class DocketDataSource {
  /// Get all dockets
  Future<List<DocketEntity>> getDockets();
}
