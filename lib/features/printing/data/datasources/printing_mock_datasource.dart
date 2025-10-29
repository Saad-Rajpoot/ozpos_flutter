import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/printer_model.dart';
import 'printing_data_source.dart';

/// Mock printing data source that loads from JSON files
/// Similar to reservations_mock_datasource pattern
class PrintingMockDataSourceImpl implements PrintingDataSource {
  static const _successFile = 'assets/printing_data/printers.json';
  static const _errorFile = 'assets/printing_data/printers_error.json';

  @override
  Future<List<PrinterModel>> getPrinters() async {
    // Simulate network delay for realistic testing
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(_successFile);
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((printerData) {
        return PrinterModel.fromJson(printerData as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(_errorFile);
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(errorData['message'] ?? 'Failed to load printers');
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load printers: ${e.toString()}');
      }
    }
  }

  @override
  Future<PrinterModel> getPrinterById(String printerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final printers = await getPrinters();
    return printers.firstWhere(
      (p) => p.id == printerId,
      orElse: () => throw Exception('Printer not found'),
    );
  }

  @override
  Future<PrinterModel> addPrinter(PrinterModel printer) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In mock, we just return the printer (no actual storage)
    return printer;
  }

  @override
  Future<PrinterModel> updatePrinter(PrinterModel printer) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In mock, we just return the printer (no actual storage)
    return printer;
  }

  @override
  Future<void> deletePrinter(String printerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In mock, we just return (no actual deletion)
  }
}
