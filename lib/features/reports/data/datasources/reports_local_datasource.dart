import 'dart:io';

import 'package:sqflite/sqflite.dart';

import '../../domain/entities/reports_entities.dart';
import '../models/reports_model.dart';
import 'reports_data_source.dart';
import 'reports_pdf_generator.dart';

/// Local reports data source that loads from SQLite
class ReportsLocalDataSourceImpl implements ReportsDataSource {
  final Database database;
  final ReportsPdfGenerator _pdfGenerator = ReportsPdfGenerator();

  ReportsLocalDataSourceImpl({required this.database});

  /// Load reports data from local storage
  @override
  Future<ReportsData> getReportsData() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query('reports');
      return maps.map((json) => ReportsModel.fromJson(json).toEntity()).first;
    } catch (e) {
      throw Exception('Failed to fetch reports data from local database');
    }
  }

  @override
  Future<File> generateReportPdf(ReportsData report) {
    return _pdfGenerator.generate(report);
  }
}
