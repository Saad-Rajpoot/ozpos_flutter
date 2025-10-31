import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/printing_entities.dart';
import '../bloc/printing_bloc.dart';
import '../bloc/printing_event.dart';
import 'printer_dialog_components.dart';

Future<void> showAddPrinterDialog(BuildContext context) async {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final portController = TextEditingController(text: '9100');
  PrinterType selectedType = PrinterType.receipt;
  PrinterConnection selectedConnection = PrinterConnection.network;
  bool fnReceipts = true;
  bool fnTickets = true;
  bool fnReports = false;
  int step = 0;

  String stepLabel(int idx) {
    switch (idx) {
      case 0:
        return 'Role';
      case 1:
        return 'Connection';
      case 2:
        return 'Details';
      case 3:
        return 'Functions';
      case 4:
        return 'Review';
      default:
        return '';
    }
  }

  Widget bullet(int idx, ThemeData theme) {
    final active = step >= idx;
    return CircleAvatar(
      radius: 16,
      backgroundColor: active ? theme.colorScheme.primary : Colors.grey[300],
      child: Text('${idx + 1}', style: TextStyle(color: active ? Colors.white : Colors.black87, fontWeight: FontWeight.w700)),
    );
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final theme = Theme.of(context);
        Widget content;
        switch (step) {
          case 0:
            content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final t in PrinterType.values)
                      SelectableTile(
                        selected: selectedType == t,
                        onTap: () => setState(() => selectedType = t),
                        icon: Icons.print,
                        title: _getPrinterTypeName(t),
                        subtitle: t == PrinterType.kitchen
                            ? 'Kitchen order tickets'
                            : t == PrinterType.receipt
                                ? 'Receipt and order printing'
                                : _getPrinterTypeName(t),
                      ),
                  ],
                )
              ],
            );
            break;
          case 1:
            content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final c in PrinterConnection.values)
                      SelectableTile(
                        selected: selectedConnection == c,
                        onTap: () => setState(() => selectedConnection = c),
                        icon: c == PrinterConnection.network
                            ? Icons.wifi
                            : c == PrinterConnection.usb
                                ? Icons.usb
                                : Icons.bluetooth,
                        title: _getConnectionName(c),
                        subtitle: c == PrinterConnection.network
                            ? 'Ethernet or WiFi'
                            : c == PrinterConnection.usb
                                ? 'Direct USB cable'
                                : 'Wireless pairing',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                      label: const Text('Detect Devices'),
                    ),
                  ],
                )
              ],
            );
            break;
          case 2:
            String addressLabel;
            String addressHint;
            switch (selectedConnection) {
              case PrinterConnection.usb:
                addressLabel = 'USB Port *';
                addressHint = 'USB001';
                break;
              case PrinterConnection.bluetooth:
                addressLabel = 'Bluetooth Address *';
                addressHint = 'e.g. 00:11:22:33:44:55';
                break;
              default:
                addressLabel = 'IP Address *';
                addressHint = '192.168.1.100';
            }
            content = Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Printer Name *', hintText: 'e.g., Main Kitchen Printer'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: addressLabel, hintText: addressHint),
                ),
                const SizedBox(height: 12),
                if (selectedConnection == PrinterConnection.network)
                  TextField(
                    controller: portController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Port', hintText: '9100'),
                  ),
                if (selectedConnection == PrinterConnection.network) const SizedBox(height: 4),
                if (selectedConnection == PrinterConnection.network)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Default: 9100 (ESC/POS printers)', style: theme.textTheme.bodySmall),
                  ),
              ],
            );
            break;
          case 3:
            content = Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                FunctionCard(title: 'Customer Receipts', subtitle: 'Print customer receipts', value: fnReceipts, onChanged: (v) => setState(() => fnReceipts = v)),
                FunctionCard(title: 'Order Tickets', subtitle: 'Print order tickets', value: fnTickets, onChanged: (v) => setState(() => fnTickets = v)),
                FunctionCard(title: 'Reports', subtitle: 'Print reports', value: fnReports, onChanged: (v) => setState(() => fnReports = v)),
              ],
            );
            break;
          default:
            content = ReviewCard(
              role: _getPrinterTypeName(selectedType),
              connection: _getConnectionName(selectedConnection),
              name: nameController.text,
              address: addressController.text,
              port: portController.text,
              functions: [if (fnReceipts) 'Receipts', if (fnTickets) 'Tickets', if (fnReports) 'Reports'],
            );
        }

        return AlertDialog(
          title: Row(
            children: const [Icon(Icons.print_outlined), SizedBox(width: 8), Text('Add New Printer')],
          ),
          content: SizedBox(
            width: 700,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (var i = 0; i < 5; i++) ...[
                      bullet(i, theme),
                      if (i != 4)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            height: 4,
                            decoration: BoxDecoration(
                              color: step > i ? theme.colorScheme.primary : Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(stepLabel(step), style: theme.textTheme.labelLarge),
                const SizedBox(height: 12),
                Flexible(child: SingleChildScrollView(child: content)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (step == 0) {
                  Navigator.pop(context);
                } else {
                  setState(() => step -= 1);
                }
              },
              child: Text(step == 0 ? 'Cancel' : 'Back'),
            ),
            ElevatedButton(
              onPressed: () {
                if (step < 4) {
                  if (step == 2 && nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter printer name')));
                    return;
                  }
                  setState(() => step += 1);
                } else {
                  final printer = PrinterEntity(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    type: selectedType,
                    connection: selectedConnection,
                    address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                    port: int.tryParse(portController.text.trim()),
                    isConnected: false,
                    isDefault: false,
                  );
                  Navigator.pop(context);
                  context.read<PrintingBloc>().add(AddPrinter(printer: printer));
                }
              },
              child: Text(step < 4 ? 'Next' : 'Add Printer'),
            ),
          ],
        );
      },
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
    case PrinterType.barista:
      return 'Barista';
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


