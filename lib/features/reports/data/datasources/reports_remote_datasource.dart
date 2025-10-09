import '../../domain/entities/reports_entities.dart';
import '../models/reports_model.dart';
import 'reports_data_source.dart';
import '../../../../core/network/api_client.dart';

/// Remote reports data source that loads from API
class ReportsRemoteDataSourceImpl implements ReportsDataSource {
  final ApiClient client;
  final String baseUrl;

  ReportsRemoteDataSourceImpl({required this.client, required this.baseUrl});

  /// Load reports data from remote API
  @override
  Future<ReportsData> getReportsData() async {
    final endpoint = '$baseUrl/reports';
    final response = await client.get(endpoint);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = response.data;
      final reportsModel = ReportsModel.fromJson(jsonData);
      return reportsModel.toEntity();
    } else {
      throw Exception('Failed to load reports data: ${response.statusCode}');
    }
  }
}
