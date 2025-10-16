import '../../domain/entities/combo_entity.dart';
import '../../domain/entities/combo_slot_entity.dart';
import '../../domain/entities/combo_availability_entity.dart';
import '../../domain/entities/combo_limits_entity.dart';
import '../../domain/entities/combo_option_entity.dart';
import '../../domain/entities/combo_pricing_entity.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
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
      final List<dynamic> data = response.data['data'];
      return data.map((json) => ComboModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch combos');
    }
  }

  @override
  Future<List<ComboSlotEntity>> getComboSlots() async {
    try {
      final response = await _apiClient.get(AppConstants.getComboSlotsEndpoint);
      final List<dynamic> data = response.data['data'];
      return data
          .map((json) => ComboSlotModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch combo slots');
    }
  }

  @override
  Future<List<ComboAvailabilityEntity>> getComboAvailability() async {
    try {
      final response = await _apiClient.get(
        AppConstants.getComboAvailabilityEndpoint,
      );
      final List<dynamic> data = response.data['data'];
      return data
          .map((json) => ComboAvailabilityModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch combo availability');
    }
  }

  @override
  Future<List<ComboLimitsEntity>> getComboLimits() async {
    try {
      final response = await _apiClient.get(
        AppConstants.getComboLimitsEndpoint,
      );
      final List<dynamic> data = response.data['data'];
      return data
          .map((json) => ComboLimitsModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch combo limits');
    }
  }

  @override
  Future<List<ComboOptionEntity>> getComboOptions() async {
    try {
      final response = await _apiClient.get(
        AppConstants.getComboOptionsEndpoint,
      );
      final List<dynamic> data = response.data['data'];
      return data
          .map((json) => ComboOptionModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch combo options');
    }
  }

  @override
  Future<List<ComboPricingEntity>> getComboPricing() async {
    try {
      final response = await _apiClient.get(
        AppConstants.getComboPricingEndpoint,
      );
      final List<dynamic> data = response.data['data'];
      return data
          .map((json) => ComboPricingModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch combo pricing');
    }
  }

  @override
  Future<ComboEntity> createCombo(ComboEntity combo) async {
    try {
      final response = await _apiClient.post(
        AppConstants.createComboEndpoint,
        data: ComboModel.fromEntity(combo).toJson(),
      );
      return ComboModel.fromJson(response.data['data']).toEntity();
    } catch (e) {
      throw ServerException(message: 'Failed to create combo');
    }
  }

  @override
  Future<ComboEntity> updateCombo(ComboEntity combo) async {
    try {
      final response = await _apiClient.put(
        '${AppConstants.updateComboEndpoint}/${combo.id}',
        data: ComboModel.fromEntity(combo).toJson(),
      );
      return ComboModel.fromJson(response.data['data']).toEntity();
    } catch (e) {
      throw ServerException(message: 'Failed to update combo');
    }
  }

  @override
  Future<void> deleteCombo(String comboId) async {
    try {
      await _apiClient.delete('${AppConstants.deleteComboEndpoint}/$comboId');
    } catch (e) {
      throw ServerException(message: 'Failed to delete combo');
    }
  }

  @override
  Future<ComboEntity> duplicateCombo(String comboId, {String? newName}) async {
    try {
      final response = await _apiClient.post(
        '${AppConstants.duplicateComboEndpoint}/$comboId',
        data: {'newName': newName},
      );
      return ComboModel.fromJson(response.data['data']).toEntity();
    } catch (e) {
      throw ServerException(message: 'Failed to duplicate combo');
    }
  }
}
