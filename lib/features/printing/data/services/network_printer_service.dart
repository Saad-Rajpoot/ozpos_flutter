import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import '../../domain/entities/printing_entities.dart';

/// Network printer service for ESC/POS thermal network printers.
/// Connects via TCP (default port 9100) and prints test receipts or custom content.
class NetworkPrinterService {
  /// Connects to a network printer, prints a test receipt, and disconnects.
  /// Use this from Printing Management to verify the printer works.
  ///
  /// [ipAddress] - Printer IP (e.g. 192.168.1.100)
  /// [port] - Raw port, usually 9100 for ESC/POS
  /// [printerName] - Shown on the test receipt
  /// [timeout] - Connection timeout
  /// Returns true if print succeeded; throws on connection/print failure.
  Future<bool> printTestReceipt({
    required String ipAddress,
    int port = 9100,
    String printerName = 'Printer',
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(PaperSize.mm80, profile);

    final result = await printer.connect(
      ipAddress,
      port: port,
      timeout: timeout,
    );

    if (result != PosPrintResult.success) {
      throw Exception(result.msg);
    }

    try {
      _printTestReceiptContent(printer, printerName);
      // Allow time for data to be sent before closing the socket
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return true;
    } finally {
      printer.disconnect(delayMs: 500);
    }
  }

  void _printTestReceiptContent(NetworkPrinter printer, String printerName) {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    printer.reset();
    printer.hr(ch: '=', linesAfter: 1);
    printer.text(
      '   TEST RECEIPT   ',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );
    printer.hr(ch: '=', linesAfter: 1);
    printer.text('Printer: $printerName', linesAfter: 1);
    printer.text('Date: $dateStr', linesAfter: 1);
    printer.hr(ch: '-', linesAfter: 1);
    printer.text(
      'This is a test print from OZPOS.',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );
    printer.text(
      'If you can read this, your',
      styles: const PosStyles(align: PosAlign.center),
    );
    printer.text(
      'network thermal printer is',
      styles: const PosStyles(align: PosAlign.center),
    );
    printer.text(
      'working correctly.',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );
    printer.hr(ch: '=', linesAfter: 1);
    printer.feed(2);
    printer.cut();
  }

  /// Connect to a network printer (for reuse in multiple print calls).
  /// Returns a map containing the printer instance; pass to [printContent] or [printTestPage].
  Future<Map<String, dynamic>> connectToPrinter({
    required String ipAddress,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(PaperSize.mm80, profile);

    final result = await printer.connect(
      ipAddress,
      port: port,
      timeout: timeout,
    );

    if (result != PosPrintResult.success) {
      throw Exception(result.msg);
    }

    return {
      'success': true,
      'printer': printer,
      'ipAddress': ipAddress,
      'port': port,
    };
  }

  /// Print raw text content to an already-connected printer.
  Future<bool> printContent({
    required Map<String, dynamic> printerInfo,
    required String content,
    PrinterType printerType = PrinterType.receipt,
    int copies = 1,
  }) async {
    final printer = printerInfo['printer'] as NetworkPrinter;

    for (var i = 0; i < copies; i++) {
      printer.reset();
      printer.text(
        content,
        styles: const PosStyles(align: PosAlign.left),
        linesAfter: 1,
      );
      printer.feed(2);
      printer.cut();
    }
    return true;
  }

  /// Print a test page to an already-connected printer.
  Future<bool> printTestPage({
    required Map<String, dynamic> printerInfo,
    String printerId = 'UNKNOWN',
  }) async {
    final printer = printerInfo['printer'] as NetworkPrinter;
    _printTestReceiptContent(printer, printerId);
    return true;
  }

  /// Prints an order receipt (e.g. after Pay Now) to a network thermal printer.
  /// Connects, sends [receiptText] (plain text, use newlines for line breaks), then disconnects.
  Future<bool> printOrderReceipt({
    required String ipAddress,
    int port = 9100,
    required String receiptText,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(PaperSize.mm80, profile);

    final result = await printer.connect(
      ipAddress,
      port: port,
      timeout: timeout,
    );

    if (result != PosPrintResult.success) {
      throw Exception(result.msg);
    }

    try {
      printer.reset();
      printer.hr(ch: '=', linesAfter: 1);
      final lines = receiptText.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) {
          printer.feed(1);
        } else {
          printer.text(trimmed, linesAfter: 1);
        }
      }
      printer.feed(2);
      printer.cut();
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return true;
    } finally {
      printer.disconnect(delayMs: 500);
    }
  }

  /// Disconnect and release the connection.
  void disconnect(Map<String, dynamic> printerInfo) {
    final printer = printerInfo['printer'] as NetworkPrinter?;
    if (printer != null) {
      printer.disconnect(delayMs: 300);
    }
  }
}
