import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/reports_entities.dart';
import '../repositories/reports_repository.dart';

/// Use case to generate and save report as PDF locally
class GenerateReportPdfUseCase {
  final ReportsRepository repository;

  GenerateReportPdfUseCase(this.repository);

  /// Generates a PDF from the given report and saves it locally.
  /// Returns the saved File on success, or Failure on error.
  Future<Either<Failure, File>> call(ReportsData report) async {
    try {
      final file = await repository.generateReportPdf(report);
      return Right(file);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
