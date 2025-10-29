import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/printing_entities.dart';
import '../repositories/printing_repository.dart';

/// Use case to get all printers
class GetPrinters implements UseCase<List<PrinterEntity>, NoParams> {
  final PrintingRepository repository;

  GetPrinters({required this.repository});

  @override
  Future<Either<Failure, List<PrinterEntity>>> call(NoParams params) async {
    return await repository.getPrinters();
  }
}
