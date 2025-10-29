import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
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
    try {
      final printers = await printingDataSource.getPrinters();
      return Right(printers.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PrinterEntity>> getPrinterById(
      String printerId) async {
    try {
      final printer = await printingDataSource.getPrinterById(printerId);
      return Right(printer.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get printer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PrinterEntity>> addPrinter(
    PrinterEntity printer,
  ) async {
    try {
      final printerModel = PrinterModel.fromEntity(printer);
      final added = await printingDataSource.addPrinter(printerModel);
      return Right(added.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to add printer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PrinterEntity>> updatePrinter(
    PrinterEntity printer,
  ) async {
    try {
      final printerModel = PrinterModel.fromEntity(printer);
      final updated = await printingDataSource.updatePrinter(printerModel);
      return Right(updated.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to update printer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePrinter(String printerId) async {
    try {
      await printingDataSource.deletePrinter(printerId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to delete printer: ${e.toString()}'));
    }
  }
}
