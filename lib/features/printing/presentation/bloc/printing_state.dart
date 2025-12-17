import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/printing_entities.dart';

/// Printing states
abstract class PrintingState extends BaseState {
  const PrintingState();
}

/// Initial state
class PrintingInitial extends PrintingState {
  @override
  List<Object?> get props => [];
}

/// Loading state
class PrintingLoading extends PrintingState {
  @override
  List<Object?> get props => [];
}

/// Printers loaded state
class PrintersLoaded extends PrintingState {
  final List<PrinterEntity> printers;
  final PrinterEntity? defaultPrinter;

  const PrintersLoaded({
    required this.printers,
    this.defaultPrinter,
  });

  PrintersLoaded copyWith({
    List<PrinterEntity>? printers,
    PrinterEntity? defaultPrinter,
  }) {
    return PrintersLoaded(
      printers: printers ?? this.printers,
      defaultPrinter: defaultPrinter ?? this.defaultPrinter,
    );
  }

  @override
  List<Object?> get props => [printers, defaultPrinter];
}

/// Discovering printers state
class DiscoveringPrinters extends PrintingState {
  final String type; // 'bluetooth' or 'network'

  const DiscoveringPrinters({required this.type});

  @override
  List<Object?> get props => [type];
}

/// Printers discovered state
class PrintersDiscovered extends PrintingState {
  final List<PrinterEntity> discoveredPrinters;
  final String discoveryType;

  const PrintersDiscovered({
    required this.discoveredPrinters,
    required this.discoveryType,
  });

  @override
  List<Object?> get props => [discoveredPrinters, discoveryType];
}

/// Printing state
class Printing extends PrintingState {
  final String printerId;
  final PrintJobStatus status;

  const Printing({
    required this.printerId,
    required this.status,
  });

  @override
  List<Object?> get props => [printerId, status];
}

/// Print job completed state
class PrintJobCompleted extends PrintingState {
  final PrintJobEntity printJob;

  const PrintJobCompleted({required this.printJob});

  @override
  List<Object?> get props => [printJob];
}

/// Print job history loaded state
class PrintJobHistoryLoaded extends PrintingState {
  final List<PrintJobEntity> printJobs;

  const PrintJobHistoryLoaded({required this.printJobs});

  @override
  List<Object?> get props => [printJobs];
}

/// Error state
class PrintingError extends PrintingState {
  final String message;

  const PrintingError({required this.message});

  @override
  List<Object?> get props => [message];
}
