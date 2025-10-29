import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/printing_entities.dart';
import '../repositories/printing_repository.dart';

/// Use case to add a new printer
class AddPrinter implements UseCase<PrinterEntity, AddPrinterParams> {
  final PrintingRepository repository;

  AddPrinter({required this.repository});

  @override
  Future<Either<Failure, PrinterEntity>> call(AddPrinterParams params) async {
    return await repository.addPrinter(params.printer);
  }
}

/// Parameters for adding a printer
class AddPrinterParams extends Equatable {
  final PrinterEntity printer;

  const AddPrinterParams({required this.printer});

  @override
  List<Object?> get props => [printer];
}
