import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/printing_bloc.dart';
import '../bloc/printing_event.dart';
import '../bloc/printing_state.dart';
import '../../domain/entities/printing_entities.dart';

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
            return _buildPrintersList(context, state.printers);
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
          _showAddPrinterDialog(context);
        },
        child: const Icon(Icons.add),
      ),
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: printers.length,
      itemBuilder: (context, index) {
        final printer = printers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              printer.connection == PrinterConnection.bluetooth
                  ? Icons.bluetooth
                  : printer.connection == PrinterConnection.network
                      ? Icons.wifi
                      : Icons.usb,
              color: printer.isConnected ? Colors.green : Colors.grey,
            ),
            title: Text(printer.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${_getPrinterTypeName(printer.type)}'),
                Text('Connection: ${_getConnectionName(printer.connection)}'),
                if (printer.address != null)
                  Text('Address: ${printer.address}'),
                if (printer.isDefault)
                  const Text('Default Printer',
                      style: TextStyle(color: Colors.blue)),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context); // Close popup menu first
                    _showEditPrinterDialog(context, printer);
                  },
                ),
                PopupMenuItem(
                  child: const Text('Delete'),
                  onTap: () {
                    Navigator.pop(context); // Close popup menu first
                    _showDeleteDialog(context, printer);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddPrinterDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final portController = TextEditingController(text: '9100');
    PrinterType selectedType = PrinterType.receipt;
    PrinterConnection selectedConnection = PrinterConnection.network;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Printer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Printer Name',
                    hintText: 'e.g., Kitchen Printer',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PrinterType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: PrinterType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getPrinterTypeName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PrinterConnection>(
                  value: selectedConnection,
                  decoration: const InputDecoration(labelText: 'Connection'),
                  items: PrinterConnection.values.map((connection) {
                    return DropdownMenuItem(
                      value: connection,
                      child: Text(_getConnectionName(connection)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedConnection = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'IP Address or MAC Address',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: portController,
                  decoration: const InputDecoration(
                    labelText: 'Port',
                    hintText: '9100',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter printer name')),
                  );
                  return;
                }

                final printer = PrinterEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  type: selectedType,
                  connection: selectedConnection,
                  address: addressController.text.isEmpty
                      ? null
                      : addressController.text,
                  port: portController.text.isEmpty
                      ? null
                      : int.tryParse(portController.text),
                  isConnected: false,
                  isDefault: false,
                );

                Navigator.pop(context);
                context.read<PrintingBloc>().add(AddPrinter(printer: printer));
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPrinterDialog(BuildContext context, PrinterEntity printer) {
    final nameController = TextEditingController(text: printer.name);
    final addressController =
        TextEditingController(text: printer.address ?? '');
    final portController =
        TextEditingController(text: printer.port?.toString() ?? '9100');
    PrinterType selectedType = printer.type;
    PrinterConnection selectedConnection = printer.connection;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Printer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Printer Name'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PrinterType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: PrinterType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getPrinterTypeName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PrinterConnection>(
                  value: selectedConnection,
                  decoration: const InputDecoration(labelText: 'Connection'),
                  items: PrinterConnection.values.map((connection) {
                    return DropdownMenuItem(
                      value: connection,
                      child: Text(_getConnectionName(connection)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedConnection = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: portController,
                  decoration: const InputDecoration(labelText: 'Port'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedPrinter = printer.copyWith(
                  name: nameController.text,
                  type: selectedType,
                  connection: selectedConnection,
                  address: addressController.text.isEmpty
                      ? null
                      : addressController.text,
                  port: portController.text.isEmpty
                      ? null
                      : int.tryParse(portController.text),
                );

                Navigator.pop(context);
                context
                    .read<PrintingBloc>()
                    .add(UpdatePrinter(printer: updatedPrinter));
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PrinterEntity printer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Printer'),
        content: Text('Are you sure you want to delete ${printer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PrintingBloc>().add(
                    DeletePrinter(printerId: printer.id),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getPrinterTypeName(PrinterType type) {
    switch (type) {
      case PrinterType.receipt:
        return 'Receipt';
      case PrinterType.kitchen:
        return 'Kitchen';
      case PrinterType.label:
        return 'Label';
      case PrinterType.invoice:
        return 'Invoice';
    }
  }

  String _getConnectionName(PrinterConnection connection) {
    switch (connection) {
      case PrinterConnection.bluetooth:
        return 'Bluetooth';
      case PrinterConnection.network:
        return 'Network';
      case PrinterConnection.usb:
        return 'USB';
    }
  }
}
