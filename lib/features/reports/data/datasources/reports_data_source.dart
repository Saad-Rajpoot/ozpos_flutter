import 'dart:io';

import '../../domain/entities/reports_entities.dart';

/// Data source interface for reports
abstract class ReportsDataSource {
  /// Get all reports data
  Future<ReportsData> getReportsData();

  /// Generate and save report as PDF locally
  Future<File> generateReportPdf(ReportsData report);
}
