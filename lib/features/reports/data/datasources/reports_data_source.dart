import '../../domain/entities/reports_entities.dart';

/// Remote data source interface for reports
abstract class ReportsDataSource {
  /// Get all reports data
  Future<ReportsData> getReportsData();
}
