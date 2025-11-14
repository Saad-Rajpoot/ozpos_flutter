import 'package:dio/dio.dart';
import '../../domain/entities/combo_entity.dart';
import '../../domain/entities/combo_slot_entity.dart';
import '../../domain/entities/combo_availability_entity.dart';
import '../../domain/entities/combo_limits_entity.dart';
import '../../domain/entities/combo_option_entity.dart';
import '../../domain/entities/combo_pricing_entity.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/exception_helper.dart';
import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import '../models/combo_model.dart';
import '../models/combo_slot_model.dart';
import '../models/combo_availability_model.dart';
import '../models/combo_limits_model.dart';
import '../models/combo_option_model.dart';
import '../models/combo_pricing_model.dart';
import 'combo_data_source.dart';
import '../../../../core/constants/app_constants.dart';

class ComboRemoteDataSourceImpl implements ComboDataSource {
  final ApiClient _apiClient;

  ComboRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<ComboEntity>> getCombos() async {
    try {
      final response = await _apiClient.get(AppConstants.getCombosEndpoint);
      final data = ExceptionHelper.validateListResponse(
        response.data,
        'fetching combos',
      );
      return data.map((json) => ComboModel.fromJson(json).toEntity()).toList();
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'fetching combos');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching combos: $e',
      );
    }
  }

  @override
  Future<PaginatedResponse<ComboEntity>> getCombosPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final response = await _apiClient.get(
        AppConstants.getCombosEndpoint,
        queryParameters: params.toQueryParams(),
      );
      return ExceptionHelper.validatePaginatedResponse<ComboEntity>(
        response.data,
        (json) => ComboModel.fromJson(json).toEntity(),
        'fetching combos',
      );
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'fetching combos');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching combos: $e',
      );
    }
  }

  @override
  Future<List<ComboSlotEntity>> getComboSlots() async {
    try {
      final response = await _apiClient.get(AppConstants.getComboSlotsEndpoint);
      final data = ExceptionHelper.validateListResponse(
        response.data,
        'fetching combo slots',
      );
      return data
          .map((json) => ComboSlotModel.fromJson(json).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'fetching combo slots');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching combo slots: $e',
      );
    }
  }

  @override
  Future<PaginatedResponse<ComboSlotEntity>> getComboSlotsPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final response = await _apiClient.get(
        AppConstants.getComboSlotsEndpoint,
        queryParameters: params.toQueryParams(),
      );
      return ExceptionHelper.validatePaginatedResponse<ComboSlotEntity>(
        response.data,
        (json) => ComboSlotModel.fromJson(json).toEntity(),
        'fetching combo slots',
      );
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'fetching combo slots');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching combo slots: $e',
      );
    }
  }

  @override
  Future<List<ComboAvailabilityEntity>> getComboAvailability() async {
    try {
      final response = await _apiClient.get(
        AppConstants.getComboAvailabilityEndpoint,
      );
      final data = ExceptionHelper.validateListResponse(
        response.data,
        'fetching combo availability',
      );
      return data
          .map((json) => ComboAvailabilityModel.fromJson(json).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(
        e,
        'fetching combo availability',
      );
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching combo availability: $e',
      );
    }
  }

  @override
  Future<PaginatedResponse<ComboAvailabilityEntity>> getComboAvailabilityPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final response = await _apiClient.get(
        AppConstants.getComboAvailabilityEndpoint,
        queryParameters: params.toQueryParams(),
      );
      return ExceptionHelper.validatePaginatedResponse<ComboAvailabilityEntity>(
        response.data,
        (json) => ComboAvailabilityModel.fromJson(json).toEntity(),
        'fetching combo availability',
      );
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(
        e,
        'fetching combo availability',
      );
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching combo availability: $e',
      );
    }
  }

  @override
  Future<List<ComboLimitsEntity>> getComboLimits() async {
    try {
      final response = await _apiClient.get(
        AppConstants.getComboLimitsEndpoint,
      );
      final data = ExceptionHelper.validateListResponse(
        response.data,
        'fetching combo limits',
      );
      return data
          .map((json) => ComboLimitsModel.fromJson(json).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'fetching combo limits');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching combo limits: $e',
      );
    }
  }

  @override
  Future<PaginatedResponse<ComboLimitsEntity>> getComboLimitsPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final response = await _apiClient.get(
        AppConstants.getComboLimitsEndpoint,
        queryParameters: params.toQueryParams(),
      );
      return ExceptionHelper.validatePaginatedResponse<ComboLimitsEntity>(
        response.data,
        (json) => ComboLimitsModel.fromJson(json).toEntity(),
        'fetching combo limits',
      );
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'fetching combo limits');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching combo limits: $e',
      );
    }
  }

  @override
  Future<List<ComboOptionEntity>> getComboOptions() async {
    try {
      final response = await _apiClient.get(
        AppConstants.getComboOptionsEndpoint,
      );
      final data = ExceptionHelper.validateListResponse(
        response.data,
        'fetching combo options',
      );
      return data
          .map((json) => ComboOptionModel.fromJson(json).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'fetching combo options');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching combo options: $e',
      );
    }
  }

  @override
  Future<PaginatedResponse<ComboOptionEntity>> getComboOptionsPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final response = await _apiClient.get(
        AppConstants.getComboOptionsEndpoint,
        queryParameters: params.toQueryParams(),
      );
      return ExceptionHelper.validatePaginatedResponse<ComboOptionEntity>(
        response.data,
        (json) => ComboOptionModel.fromJson(json).toEntity(),
        'fetching combo options',
      );
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'fetching combo options');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching combo options: $e',
      );
    }
  }

  @override
  Future<List<ComboPricingEntity>> getComboPricing() async {
    try {
      final response = await _apiClient.get(
        AppConstants.getComboPricingEndpoint,
      );
      final data = ExceptionHelper.validateListResponse(
        response.data,
        'fetching combo pricing',
      );
      return data
          .map((json) => ComboPricingModel.fromJson(json).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'fetching combo pricing');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching combo pricing: $e',
      );
    }
  }

  @override
  Future<PaginatedResponse<ComboPricingEntity>> getComboPricingPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final response = await _apiClient.get(
        AppConstants.getComboPricingEndpoint,
        queryParameters: params.toQueryParams(),
      );
      return ExceptionHelper.validatePaginatedResponse<ComboPricingEntity>(
        response.data,
        (json) => ComboPricingModel.fromJson(json).toEntity(),
        'fetching combo pricing',
      );
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'fetching combo pricing');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error fetching combo pricing: $e',
      );
    }
  }

  @override
  Future<ComboEntity> createCombo(ComboEntity combo) async {
    try {
      final response = await _apiClient.post(
        AppConstants.createComboEndpoint,
        data: ComboModel.fromEntity(combo).toJson(),
      );
      final data = ExceptionHelper.validateResponseData(
        response.data,
        'creating combo',
      );
      return ComboModel.fromJson(data).toEntity();
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'creating combo');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error creating combo: $e',
      );
    }
  }

  @override
  Future<ComboEntity> updateCombo(ComboEntity combo) async {
    try {
      final response = await _apiClient.put(
        '${AppConstants.updateComboEndpoint}/${combo.id}',
        data: ComboModel.fromEntity(combo).toJson(),
      );
      final data = ExceptionHelper.validateResponseData(
        response.data,
        'updating combo',
      );
      return ComboModel.fromJson(data).toEntity();
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'updating combo');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error updating combo: $e',
      );
    }
  }

  @override
  Future<void> deleteCombo(String comboId) async {
    try {
      await _apiClient.delete('${AppConstants.deleteComboEndpoint}/$comboId');
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'deleting combo');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error deleting combo: $e',
      );
    }
  }

  @override
  Future<ComboEntity> duplicateCombo(String comboId, {String? newName}) async {
    try {
      final response = await _apiClient.post(
        '${AppConstants.duplicateComboEndpoint}/$comboId',
        data: {'newName': newName},
      );
      final data = ExceptionHelper.validateResponseData(
        response.data,
        'duplicating combo',
      );
      return ComboModel.fromJson(data).toEntity();
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'duplicating combo');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'Unexpected error duplicating combo: $e',
      );
    }
  }
}
