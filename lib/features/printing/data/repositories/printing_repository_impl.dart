import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/repository_error_handler.dart';
import '../../domain/entities/printing_entities.dart';
import '../../domain/repositories/printing_repository.dart';
import '../datasources/printing_data_source.dart';
import '../models/printer_model.dart';

/// Printing repository implementation - Simple CRUD operations
class PrintingRepositoryImpl implements PrintingRepository {
  final PrintingDataSource printingDataSource;
  final NetworkInfo networkInfo;

  PrintingRepositoryImpl({
    required this.printingDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<PrinterEntity>>> getPrinters() async {
    // Printing operations may work offline (local printer discovery)
    // So we skip network check
    return RepositoryErrorHandler.handleOperation<List<PrinterEntity>>(
      operation: () async {
        final printers = await printingDataSource.getPrinters();
        return printers.map((p) => p.toEntity()).toList();
      },
      networkInfo: networkInfo,
      operationName: 'loading printers',
      skipNetworkCheck: true,
    );
  }

  @override
  Future<Either<Failure, PrinterEntity>> getPrinterById(
      String printerId) async {
    return RepositoryErrorHandler.handleOperation<PrinterEntity>(
      operation: () async {
        final printer = await printingDataSource.getPrinterById(printerId);
        return printer.toEntity();
      },
      networkInfo: networkInfo,
      operationName: 'loading printer',
      skipNetworkCheck: true,
    );
  }

  @override
  Future<Either<Failure, PrinterEntity>> addPrinter(
    PrinterEntity printer,
  ) async {
    return RepositoryErrorHandler.handleOperation<PrinterEntity>(
      operation: () async {
        final printerModel = PrinterModel.fromEntity(printer);
        final added = await printingDataSource.addPrinter(printerModel);
        return added.toEntity();
      },
      networkInfo: networkInfo,
      operationName: 'adding printer',
      skipNetworkCheck: true,
    );
  }

  @override
  Future<Either<Failure, PrinterEntity>> updatePrinter(
    PrinterEntity printer,
  ) async {
    return RepositoryErrorHandler.handleOperation<PrinterEntity>(
      operation: () async {
        final printerModel = PrinterModel.fromEntity(printer);
        final updated = await printingDataSource.updatePrinter(printerModel);
        return updated.toEntity();
      },
      networkInfo: networkInfo,
      operationName: 'updating printer',
      skipNetworkCheck: true,
    );
  }

  @override
  Future<Either<Failure, void>> deletePrinter(String printerId) async {
    return RepositoryErrorHandler.handleOperation<void>(
      operation: () async => await printingDataSource.deletePrinter(printerId),
      networkInfo: networkInfo,
      operationName: 'deleting printer',
      skipNetworkCheck: true,
    );
  }
}
