import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_bloc.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_printers.dart';
import '../../domain/usecases/add_printer.dart' as add_printer_usecase;
import '../../domain/repositories/printing_repository.dart';
import 'printing_event.dart';
import 'printing_state.dart';

/// Printing BLoC for managing printer CRUD operations
class PrintingBloc extends BaseBloc<PrintingEvent, PrintingState> {
  final GetPrinters getPrinters;
  final add_printer_usecase.AddPrinter addPrinter;
  final PrintingRepository printingRepository;

  PrintingBloc({
    required this.getPrinters,
    required this.addPrinter,
    required this.printingRepository,
  }) : super(PrintingInitial()) {
    on<LoadPrinters>(_onLoadPrinters);
    on<AddPrinter>(_onAddPrinter);
    on<UpdatePrinter>(_onUpdatePrinter);
    on<DeletePrinter>(_onDeletePrinter);
  }

  Future<void> _onLoadPrinters(
    LoadPrinters event,
    Emitter<PrintingState> emit,
  ) async {
    emit(PrintingLoading());
    final result = await getPrinters(const NoParams());
    result.fold(
      (failure) => emit(PrintingError(message: _mapFailureToMessage(failure))),
      (printers) {
        final defaultPrinter = printers.isNotEmpty
            ? printers.firstWhere(
                (p) => p.isDefault,
                orElse: () => printers.first,
              )
            : null;
        emit(PrintersLoaded(
          printers: printers,
          defaultPrinter: defaultPrinter,
        ));
      },
    );
  }

  Future<void> _onAddPrinter(
    AddPrinter event,
    Emitter<PrintingState> emit,
  ) async {
    emit(PrintingLoading());
    final result = await addPrinter(
        add_printer_usecase.AddPrinterParams(printer: event.printer));
    result.fold(
      (failure) => emit(PrintingError(message: _mapFailureToMessage(failure))),
      (_) => add(LoadPrinters()),
    );
  }

  Future<void> _onUpdatePrinter(
    UpdatePrinter event,
    Emitter<PrintingState> emit,
  ) async {
    emit(PrintingLoading());
    final result = await printingRepository.updatePrinter(event.printer);
    result.fold(
      (failure) => emit(PrintingError(message: _mapFailureToMessage(failure))),
      (_) => add(LoadPrinters()),
    );
  }

  Future<void> _onDeletePrinter(
    DeletePrinter event,
    Emitter<PrintingState> emit,
  ) async {
    emit(PrintingLoading());
    final result = await printingRepository.deletePrinter(event.printerId);
    result.fold(
      (failure) => emit(PrintingError(message: _mapFailureToMessage(failure))),
      (_) => add(LoadPrinters()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
        return 'Network error: ${failure.message}';
      default:
        return 'Unexpected error: ${failure.message}';
    }
  }
}
