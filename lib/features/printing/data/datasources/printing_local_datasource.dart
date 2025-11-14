import 'package:sqflite/sqflite.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import '../models/printer_model.dart';
import 'printing_data_source.dart';

/// Local data source implementation using SQLite database
/// Similar to ReservationsLocalDataSourceImpl pattern
class PrintingLocalDataSourceImpl implements PrintingDataSource {
  final Database database;

  PrintingLocalDataSourceImpl({required this.database});

  @override
  Future<List<PrinterModel>> getPrinters() async {
    try {
      // Query printers table from SQLite database
      final List<Map<String, dynamic>> maps = await database.query(
        'printers',
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => _mapToPrinterModel(map)).toList();
    } catch (e) {
      throw ServerException(
        message:
            'Failed to fetch printers from local database: ${e.toString()}',
      );
    }
  }

  @override
  Future<PrinterModel> getPrinterById(String printerId) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'printers',
        where: 'id = ?',
        whereArgs: [printerId],
        limit: 1,
      );

      if (maps.isEmpty) {
        throw Exception('Printer not found');
      }

      return _mapToPrinterModel(maps.first);
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch printer from local database: ${e.toString()}',
      );
    }
  }

  @override
  Future<PrinterModel> addPrinter(PrinterModel printer) async {
    try {
      final now = DateTime.now().toIso8601String();
      final map = _printerModelToMap(printer, createdAt: now, updatedAt: now);

      await database.insert(
        'printers',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return printer;
    } catch (e) {
      throw ServerException(
        message: 'Failed to add printer to local database: ${e.toString()}',
      );
    }
  }

  @override
  Future<PrinterModel> updatePrinter(PrinterModel printer) async {
    try {
      final updatedAt = DateTime.now().toIso8601String();
      final map = _printerModelToMap(printer, updatedAt: updatedAt);

      // Remove id and created_at from update map (they shouldn't be updated)
      map.remove('created_at');

      final count = await database.update(
        'printers',
        map,
        where: 'id = ?',
        whereArgs: [printer.id],
      );

      if (count == 0) {
        throw Exception('Printer not found');
      }

      return printer;
    } catch (e) {
      throw ServerException(
        message: 'Failed to update printer in local database: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deletePrinter(String printerId) async {
    try {
      final count = await database.delete(
        'printers',
        where: 'id = ?',
        whereArgs: [printerId],
      );

      if (count == 0) {
        throw Exception('Printer not found');
      }
    } catch (e) {
      throw ServerException(
        message:
            'Failed to delete printer from local database: ${e.toString()}',
      );
    }
  }

  /// Convert database map to PrinterModel
  PrinterModel _mapToPrinterModel(Map<String, dynamic> map) {
    return PrinterModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      connection: map['connection'] as String,
      address: map['address'] as String?,
      port: map['port'] as int?,
      isConnected: (map['is_connected'] as int) == 1,
      isDefault: (map['is_default'] as int) == 1,
      lastUsedAt: map['last_used_at'] as String?,
    );
  }

  /// Convert PrinterModel to database map
  Map<String, dynamic> _printerModelToMap(
    PrinterModel printer, {
    String? createdAt,
    String? updatedAt,
  }) {
    return {
      'id': printer.id,
      'name': printer.name,
      'type': printer.type,
      'connection': printer.connection,
      'address': printer.address,
      'port': printer.port,
      'is_connected': printer.isConnected ? 1 : 0,
      'is_default': printer.isDefault ? 1 : 0,
      'last_used_at': printer.lastUsedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null)       'updated_at': updatedAt,
    };
  }

  @override
  Future<PaginatedResponse<PrinterModel>> getPrintersPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final allMaps = await database.query(
        'printers',
        orderBy: 'created_at DESC',
      );
      final allItems = allMaps.map((map) => _mapToPrinterModel(map)).toList();
      
      final totalItems = allItems.length;
      final totalPages = (totalItems / params.limit).ceil();
      final startIndex = (params.page - 1) * params.limit;
      final endIndex = (startIndex + params.limit).clamp(0, totalItems);
      final paginatedItems = allItems.sublist(
        startIndex.clamp(0, totalItems),
        endIndex,
      );

      return PaginatedResponse<PrinterModel>(
        data: paginatedItems,
        currentPage: params.page,
        totalPages: totalPages,
        totalItems: totalItems,
        perPage: params.limit,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch printers from local database: ${e.toString()}',
      );
    }
  }
}
