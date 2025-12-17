import 'package:flutter/material.dart';
import '../../domain/entities/printing_entities.dart';
import 'printer_card.dart';

class PrinterSection extends StatelessWidget {
  final PrinterType type;
  final List<PrinterEntity> printers;
  final void Function(BuildContext, PrinterEntity) onEdit;
  const PrinterSection(
      {super.key,
      required this.type,
      required this.printers,
      required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final onlineCount = printers.where((p) => p.isConnected).length;
    final icon = _sectionIcon(type);
    final color = _sectionColor(type);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 8),
            Text(
              _sectionTitle(type),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                '$onlineCount online',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: color),
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final printer in printers)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: PrinterCard(
                    printer: printer,
                    color: color,
                    onEdit: (p) => onEdit(context, p),
                  ),
                )
            ],
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  static IconData _sectionIcon(PrinterType type) {
    switch (type) {
      case PrinterType.receipt:
        return Icons.receipt_long;
      case PrinterType.kitchen:
        return Icons.kitchen;
      case PrinterType.barista:
        return Icons.coffee;
      case PrinterType.label:
        return Icons.label;
      case PrinterType.invoice:
        return Icons.request_page;
    }
  }

  static String _sectionTitle(PrinterType type) {
    switch (type) {
      case PrinterType.receipt:
        return 'POS Printers';
      case PrinterType.kitchen:
        return 'Kitchen Printers';
      case PrinterType.barista:
        return 'Barista Printers';
      case PrinterType.label:
        return 'Label Printers';
      case PrinterType.invoice:
        return 'Invoice Printers';
    }
  }

  static Color _sectionColor(PrinterType type) {
    switch (type) {
      case PrinterType.receipt:
        return const Color(0xFF2563EB);
      case PrinterType.kitchen:
        return const Color(0xFFF59E0B);
      case PrinterType.barista:
        return const Color(0xFF8B5CF6);
      case PrinterType.label:
        return Colors.teal;
      case PrinterType.invoice:
        return Colors.green;
    }
  }
}
