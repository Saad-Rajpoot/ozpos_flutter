import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/printing_entities.dart';
import '../bloc/printing_bloc.dart';
import '../bloc/printing_event.dart';

class PrinterCard extends StatelessWidget {
  final PrinterEntity printer;
  final Color color;
  final void Function(PrinterEntity) onEdit;
  const PrinterCard(
      {super.key,
      required this.printer,
      required this.color,
      required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 270,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  printer.connection == PrinterConnection.bluetooth
                      ? Icons.bluetooth
                      : printer.connection == PrinterConnection.network
                          ? Icons.wifi
                          : Icons.usb,
                  color: printer.isConnected ? color : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          printer.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => onEdit(printer),
                        child: const Icon(Icons.edit_outlined, size: 16),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (dialogCtx) => AlertDialog(
                              title: const Text('Delete Printer'),
                              content: Text(
                                  'Are you sure you want to delete "${printer.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogCtx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogCtx, true),
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.red),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            // ignore: use_build_context_synchronously
                            context.read<PrintingBloc>().add(
                                  DeletePrinter(printerId: printer.id),
                                );
                          }
                        },
                        child: const Icon(Icons.delete_outline,
                            size: 16, color: Colors.redAccent),
                      ),
                      if (printer.isDefault)
                        Container(
                          margin: const EdgeInsets.only(left: 7),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Default',
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        )
                    ],
                  ),
                ),
                printer.isConnected
                    ? const Icon(Icons.check_circle,
                        color: Colors.green, size: 18)
                    : const Icon(Icons.cancel, color: Colors.red, size: 18),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(printer.isConnected ? Icons.circle : Icons.error,
                    color: printer.isConnected ? Colors.green : Colors.red,
                    size: 10),
                const SizedBox(width: 4),
                Text(
                  printer.isConnected ? 'Online' : 'Offline',
                  style: TextStyle(
                      color:
                          printer.isConnected ? Colors.green : Colors.red[700],
                      fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 7),
            if (printer.address != null)
              Text(
                (printer.connection == PrinterConnection.usb
                        ? 'USB Port: '
                        : 'IP Address: ') +
                    (printer.address ?? ''),
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            if (printer.port != null) const SizedBox(height: 2),
            if (printer.port != null)
              Text('Port: ${printer.port}',
                  style: const TextStyle(fontSize: 12, color: Colors.black87)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 5,
              children: [
                for (final tag in _assignableTags(printer))
                  Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 10)),
                    backgroundColor: Colors.grey.withOpacity(0.12),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 17, vertical: 10),
                  ),
                  child:
                      const Text('Test Print', style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: printer.isDefault ? null : () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(printer.isDefault ? 'Default' : 'Set Default',
                      style: const TextStyle(fontSize: 13)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  static List<String> _assignableTags(PrinterEntity printer) {
    final List<String> tags = [];
    if (printer.type == PrinterType.kitchen) tags.add('Orders');
    if (printer.type == PrinterType.kitchen ||
        printer.type == PrinterType.receipt) tags.add('Tickets');
    if (printer.type == PrinterType.receipt) tags.add('Receipts');
    return tags;
  }
}
