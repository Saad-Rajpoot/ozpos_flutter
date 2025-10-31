import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/printing_bloc.dart';
import '../bloc/printing_event.dart';
import '../bloc/printing_state.dart';
import '../../domain/entities/printing_entities.dart';
import '../widgets/printer_section.dart';
import '../widgets/add_printer_dialog.dart';
import '../widgets/edit_printer_dialog.dart';

/// Printing Management Screen
/// Simple CRUD operations for managing printers
class PrintingManagementScreen extends StatelessWidget {
  const PrintingManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            return _buildScreenWithHeader(context, state.printers);
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
      BuildContext context, List<PrinterEntity> printers) {
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
        _buildPrintersList(context, printers),
      ],
    );
  }

  Widget _buildPrintersList(
      BuildContext context, List<PrinterEntity> printers) {
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
          ),
      ],
    );
  }

  // dialog moved to ../widgets/add_printer_dialog.dart

  // dialog moved to ../widgets/edit_printer_dialog.dart
}

// Section widget
// Section and Card moved to widgets/printer_section.dart and widgets/printer_card.dart

// moved tiles/cards to ../widgets/printer_dialog_components.dart
