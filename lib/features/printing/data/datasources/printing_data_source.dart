import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import '../models/printer_model.dart';

/// Printing data source interface - Simple CRUD operations
abstract class PrintingDataSource {
  /// Get all printers
  Future<List<PrinterModel>> getPrinters();

  /// Get all printers with pagination
  Future<PaginatedResponse<PrinterModel>> getPrintersPaginated({
    PaginationParams? pagination,
  });

  /// Get printer by ID
  Future<PrinterModel> getPrinterById(String printerId);

  /// Add/Create a new printer
  Future<PrinterModel> addPrinter(PrinterModel printer);

  /// Update printer
  Future<PrinterModel> updatePrinter(PrinterModel printer);

  /// Delete printer
  Future<void> deletePrinter(String printerId);
}
