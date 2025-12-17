import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/printing_entities.dart';

/// Printing repository interface - Simple CRUD operations
abstract class PrintingRepository {
  /// Get all printers
  Future<Either<Failure, List<PrinterEntity>>> getPrinters();

  /// Get printer by ID
  Future<Either<Failure, PrinterEntity>> getPrinterById(String printerId);

  /// Add a new printer
  Future<Either<Failure, PrinterEntity>> addPrinter(PrinterEntity printer);

  /// Update printer
  Future<Either<Failure, PrinterEntity>> updatePrinter(PrinterEntity printer);

  /// Delete printer
  Future<Either<Failure, void>> deletePrinter(String printerId);
}
