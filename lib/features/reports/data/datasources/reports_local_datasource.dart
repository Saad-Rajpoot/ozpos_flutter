import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/reports_entities.dart';
import '../models/reports_model.dart';
import 'reports_data_source.dart';

/// Local reports data source that loads from SharedPreferences
class ReportsLocalDataSourceImpl implements ReportsDataSource {
  /// Load reports data from local storage
  @override
  Future<ReportsData> getReportsData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('reports_data');

    if (cachedData != null) {
      final Map<String, dynamic> jsonData = json.decode(cachedData);
      final reportsModel = ReportsModel.fromJson(jsonData);
      return reportsModel.toEntity();
    } else {
      throw Exception('No cached reports data available');
    }
  }

  /// Cache reports data locally
  Future<void> cacheReportsData(ReportsData data) async {
    final prefs = await SharedPreferences.getInstance();
    final reportsModel = ReportsModel.fromEntity(data);
    final jsonData = json.encode(reportsModel.toJson());
    await prefs.setString('reports_data', jsonData);
  }
}
