import '../../domain/entities/reports_entities.dart';
import '../models/reports_model.dart';
import 'reports_data_source.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';

/// Remote reports data source that loads from API
class ReportsRemoteDataSourceImpl implements ReportsDataSource {
  final ApiClient client;

  ReportsRemoteDataSourceImpl({required this.client});

  /// Load reports data from remote API
  @override
  Future<ReportsData> getReportsData() async {
    final endpoint = AppConstants.getReportsEndpoint;
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
