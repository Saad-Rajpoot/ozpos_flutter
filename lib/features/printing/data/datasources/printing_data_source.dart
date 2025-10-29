import '../models/printer_model.dart';

/// Printing data source interface - Simple CRUD operations
abstract class PrintingDataSource {
  /// Get all printers
  Future<List<PrinterModel>> getPrinters();

  /// Get printer by ID
  Future<PrinterModel> getPrinterById(String printerId);

  /// Add/Create a new printer
  Future<PrinterModel> addPrinter(PrinterModel printer);

  /// Update printer
  Future<PrinterModel> updatePrinter(PrinterModel printer);

  /// Delete printer
  Future<void> deletePrinter(String printerId);
}
