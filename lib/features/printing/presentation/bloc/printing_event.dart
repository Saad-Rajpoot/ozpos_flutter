import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/printing_entities.dart';

/// Printing events - Simple CRUD operations
abstract class PrintingEvent extends BaseEvent {
  const PrintingEvent();
}

/// Load all printers
class LoadPrinters extends PrintingEvent {
  @override
  List<Object?> get props => [];
}

/// Add printer
class AddPrinter extends PrintingEvent {
  final PrinterEntity printer;

  const AddPrinter({required this.printer});

  @override
  List<Object?> get props => [printer];
}

/// Update printer
class UpdatePrinter extends PrintingEvent {
  final PrinterEntity printer;

  const UpdatePrinter({required this.printer});

  @override
  List<Object?> get props => [printer];
}

/// Delete printer
class DeletePrinter extends PrintingEvent {
  final String printerId;

  const DeletePrinter({required this.printerId});

  @override
  List<Object?> get props => [printerId];
}
