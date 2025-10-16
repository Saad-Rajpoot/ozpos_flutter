import '../../domain/entities/combo_entity.dart';
import '../../domain/entities/combo_slot_entity.dart';
import '../../domain/entities/combo_availability_entity.dart';
import '../../domain/entities/combo_limits_entity.dart';
import '../../domain/entities/combo_option_entity.dart';
import '../../domain/entities/combo_pricing_entity.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/combo_model.dart';
import '../models/combo_slot_model.dart';
import '../models/combo_availability_model.dart';
import '../models/combo_limits_model.dart';
import '../models/combo_option_model.dart';
import '../models/combo_pricing_model.dart';
import 'combo_data_source.dart';
import 'package:sqflite/sqflite.dart';

class ComboLocalDataSourceImpl implements ComboDataSource {
  final Database database;

  ComboLocalDataSourceImpl({required this.database});

  @override
  Future<List<ComboEntity>> getCombos() async {
    try {
      // Assuming a local table named 'combos'
      final List<Map<String, dynamic>> maps = await database.query('combos');
      return maps.map((json) => ComboModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch combos from local database',
      );
    }
  }

  @override
  Future<List<ComboSlotEntity>> getComboSlots() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'combo_slots',
      );
      return maps
          .map((json) => ComboSlotModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch combo slots from local database',
      );
    }
  }

  @override
  Future<List<ComboAvailabilityEntity>> getComboAvailability() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'combo_availability',
      );
      return maps
          .map((json) => ComboAvailabilityModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch combo availability from local database',
      );
    }
  }

  @override
  Future<List<ComboLimitsEntity>> getComboLimits() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'combo_limits',
      );
      return maps
          .map((json) => ComboLimitsModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch combo limits from local database',
      );
    }
  }

  @override
  Future<List<ComboOptionEntity>> getComboOptions() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'combo_options',
      );
      return maps
          .map((json) => ComboOptionModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch combo options from local database',
      );
    }
  }

  @override
  Future<List<ComboPricingEntity>> getComboPricing() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'combo_pricing',
      );
      return maps
          .map((json) => ComboPricingModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch combo pricing from local database',
      );
    }
  }

  @override
  Future<ComboEntity> createCombo(ComboEntity combo) {
    return database
        .insert('combos', ComboModel.fromEntity(combo).toJson())
        .then((value) =>
            ComboModel.fromJson(value as Map<String, dynamic>).toEntity());
  }

  @override
  Future<ComboEntity> updateCombo(ComboEntity combo) {
    return database.update('combos', ComboModel.fromEntity(combo).toJson(),
        where: 'id = ?',
        whereArgs: [
          combo.id
        ]).then((value) =>
        ComboModel.fromJson(value as Map<String, dynamic>).toEntity());
  }

  @override
  Future<void> deleteCombo(String comboId) {
    return database.delete('combos', where: 'id = ?', whereArgs: [comboId]);
  }

  @override
  Future<ComboEntity> duplicateCombo(String comboId, {String? newName}) {
    return database
        .query('combos', where: 'id = ?', whereArgs: [comboId])
        .then((value) =>
            ComboModel.fromJson(value.first as Map<String, dynamic>).toEntity())
        .then((combo) => database
            .insert('combos', ComboModel.fromEntity(combo).toJson())
            .then((value) =>
                ComboModel.fromJson(value as Map<String, dynamic>).toEntity()));
  }
}
