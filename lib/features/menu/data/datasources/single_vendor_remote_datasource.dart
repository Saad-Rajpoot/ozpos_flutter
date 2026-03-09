import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/exception_helper.dart';
import '../models/single_vendor_response_model.dart';

/// Remote data source for single-vendor API
/// GET single-vendor/{vendor_uuid}/{branch_uuid}
/// Token is added automatically by ApiClient interceptor
abstract class SingleVendorRemoteDataSource {
  Future<SingleVendorResponseModel> getSingleVendor({
    required String vendorUuid,
    required String branchUuid,
  });
}

class SingleVendorRemoteDataSourceImpl implements SingleVendorRemoteDataSource {
  final ApiClient apiClient;

  SingleVendorRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<SingleVendorResponseModel> getSingleVendor({
    required String vendorUuid,
    required String branchUuid,
  }) async {
    try {
      final path =
          '${AppConstants.singleVendorEndpoint}/$vendorUuid/$branchUuid';
      final response = await apiClient.get(path);

      final payload = ExceptionHelper.validateResponseData(
        response.data,
        'fetching single vendor',
      );
      if (payload is! Map<String, dynamic>) {
        throw ServerException(
          message:
              'Invalid response format: expected Map, got ${payload.runtimeType}',
        );
      }

      final success = response.data['success'] as bool? ?? false;
      if (!success) {
        final msg = response.data['message'] as String? ?? 'Failed to load vendor';
        throw ServerException(message: msg);
      }

      return SingleVendorResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'fetching single vendor');
    } on FormatException catch (e) {
      throw ServerException(
        message: 'Invalid menu data format: ${e.message}',
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Unexpected error fetching single vendor: $e',
      );
    }
  }
}
