import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/printing_entities.dart';
import '../bloc/printing_bloc.dart';
import '../bloc/printing_event.dart';
import '../bloc/printing_state.dart';
import '../../data/services/network_printer_service.dart';
import '../../data/services/imin_printer_service.dart';
import '../widgets/add_printer_dialog.dart';
import '../widgets/edit_printer_dialog.dart';
import '../widgets/printer_section.dart';

/// Printing Management Screen
/// CRUD for printers and test print for network thermal printers.
class PrintingManagementScreen extends StatelessWidget {
  const PrintingManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final networkPrinterService = sl<NetworkPrinterService>();
    final iminPrinterService = sl<IminPrinterService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printing Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PrintingBloc>().add(LoadPrinters());
            },
          ),
        ],
      ),
      body: BlocBuilder<PrintingBloc, PrintingState>(
        buildWhen: (previous, current) {
          // Always rebuild on state type changes
          if (previous.runtimeType != current.runtimeType) {
            return true;
          }

          // For PrintersLoaded state, only rebuild if printers or defaultPrinter changes
          if (previous is PrintersLoaded && current is PrintersLoaded) {
            return previous.printers != current.printers ||
                previous.defaultPrinter != current.defaultPrinter;
          }

          // For PrintingError state, only rebuild if error message changes
          if (previous is PrintingError && current is PrintingError) {
            return previous.message != current.message;
          }

          // For PrintersDiscovered state, only rebuild if discovered printers change
          if (previous is PrintersDiscovered && current is PrintersDiscovered) {
            return previous.discoveredPrinters != current.discoveredPrinters;
          }

          // For PrintJobHistoryLoaded state, only rebuild if print jobs change
          if (previous is PrintJobHistoryLoaded &&
              current is PrintJobHistoryLoaded) {
            return previous.printJobs != current.printJobs;
          }

          return false;
        },
        builder: (context, state) {
          if (state is PrintingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PrintingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PrintingBloc>().add(LoadPrinters());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PrintersLoaded) {
            return _buildScreenWithHeader(
              context,
              state.printers,
              networkPrinterService,
              iminPrinterService,
            );
          }

          return Center(
            child: ElevatedButton(
              onPressed: () {
                context.read<PrintingBloc>().add(LoadPrinters());
              },
              child: const Text('Load Printers'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddPrinterDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildScreenWithHeader(
    BuildContext context,
    List<PrinterEntity> printers,
    NetworkPrinterService networkPrinterService,
    IminPrinterService iminPrinterService,
  ) {
    final total = printers.length;
    final online = printers.where((p) => p.isConnected).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        // Header row (title + action buttons)
        Row(
          children: [
            Text(
              'Printer Settings',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('$online / $total Online',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            OutlinedButton.icon(
              icon: const Icon(Icons.description_outlined, size: 18),
              label: const Text('Docket Designer'),
              onPressed: () {
                // Navigate to Docket Designer route
                Navigator.of(context).pushNamed('/docket-designer');
              },
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.tune, size: 18),
              label: const Text('Advanced Settings'),
              onPressed: () {
                // Placeholder: advanced settings dialog
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text('Advanced Settings'),
                    content: Text('Coming soon...'),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Printer'),
              onPressed: () => showAddPrinterDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildIminPrinterCard(context, iminPrinterService),
        const SizedBox(height: 16),
        _buildPrintersList(context, printers, networkPrinterService),
      ],
    );
  }

  Widget _buildIminPrinterCard(
    BuildContext context,
    IminPrinterService iminPrinterService,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.print, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'iMin Built-in Printer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Test the internal printer on iMin POS devices',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.print, size: 18),
              label: const Text('Test Print'),
              onPressed: () => _handleTestIminPrint(context, iminPrinterService),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTestIminPrint(
    BuildContext context,
    IminPrinterService iminPrinterService,
  ) async {
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 24),
              Expanded(child: Text('Printing test receipt on iMin printer...')),
            ],
          ),
        ),
      );
    }

    try {
      final ok = await iminPrinterService.printTestReceipt();
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ok ? 'Test receipt sent to iMin printer' : 'iMin printer not available (not an iMin device?)',
            ),
            backgroundColor: ok ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Print failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPrintersList(
    BuildContext context,
    List<PrinterEntity> printers,
    NetworkPrinterService networkPrinterService,
  ) {
    if (printers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.print_disabled, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No printers found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add a printer to get started',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Group by type
    final Map<PrinterType, List<PrinterEntity>> grouped = {};
    for (final printer in printers) {
      grouped.putIfAbsent(printer.type, () => []).add(printer);
    }

    return Column(
      children: [
        for (final group in grouped.entries)
          PrinterSection(
            type: group.key,
            printers: group.value,
            onEdit: (ctx, p) => showEditPrinterDialog(ctx, p),
            onTestPrint: (printer) => _handleTestPrint(
              context,
              printer,
              networkPrinterService,
            ),
          ),
      ],
    );
  }

  Future<void> _handleTestPrint(
    BuildContext context,
    PrinterEntity printer,
    NetworkPrinterService networkPrinterService,
  ) async {
    if (printer.connection != PrinterConnection.network) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Test print is only available for network printers.',
            ),
          ),
        );
      }
      return;
    }
    final address = printer.address?.trim();
    if (address == null || address.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Printer has no IP address. Edit the printer.'),
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 24),
              Expanded(child: Text('Connecting and printing test receipt...')),
            ],
          ),
        ),
      );
    }

    try {
      await networkPrinterService.printTestReceipt(
        ipAddress: address,
        port: printer.port ?? 9100,
        printerName: printer.name,
      );
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test receipt sent to ${printer.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Print failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // dialog moved to ../widgets/add_printer_dialog.dart

  // dialog moved to ../widgets/edit_printer_dialog.dart
}

// Section widget
// Section and Card moved to widgets/printer_section.dart and widgets/printer_card.dart

// moved tiles/cards to ../widgets/printer_dialog_components.dart
