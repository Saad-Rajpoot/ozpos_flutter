import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/customer_display_entity.dart';
import '../models/customer_display_model.dart';
import 'customer_display_data_source.dart';

class CustomerDisplayLocalDataSourceImpl implements CustomerDisplayDataSource {
  final Database database;

  CustomerDisplayLocalDataSourceImpl({required this.database});

  @override
  Future<CustomerDisplayEntity> getContent() async {
    try {
      final result = await database.query(
        'customer_display',
        orderBy: 'updated_at DESC',
        limit: 1,
      );

      if (result.isEmpty) {
        throw CacheException(
          message: 'No cached customer display content available',
        );
      }

      final Map<String, dynamic> row = result.first;
      final payload = row['payload'];

      late final Map<String, dynamic> data;
      if (payload is String) {
        data = json.decode(payload) as Map<String, dynamic>;
      } else if (payload is Map<String, dynamic>) {
        data = payload;
      } else {
        data = Map<String, dynamic>.from(row);
      }

      final model = CustomerDisplayModel.fromJson(data);
      return model.toEntity();
    } catch (e) {
      if (e is CacheException) {
        rethrow;
      }
      throw CacheException(
        message: 'Failed to load customer display content from cache',
      );
    }
  }
}
