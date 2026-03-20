import 'dart:io';

import 'package:imin_printer/imin_printer.dart';
import 'package:imin_printer/enums.dart';
import 'package:imin_printer/imin_style.dart';

/// Service wrapper around the iMin built‑in printer.
///
/// This uses the `imin_printer` plugin to talk to the internal printer
/// on supported Android‑based iMin devices. All methods are safe to call
/// on non‑Android platforms – they will simply no‑op and return `false`.
class IminPrinterService {
  IminPrinterService();

  final IminPrinter _iminPrinter = IminPrinter();
  bool _initialized = false;

  /// Ensure printer is initialized on supported devices.
  Future<bool> _ensureInitialized() async {
    if (!Platform.isAndroid) {
      return false;
    }

    if (_initialized) {
      return true;
    }

    try {
      await _iminPrinter.initPrinter();
      _initialized = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Print a simple test receipt to verify the internal printer works.
  Future<bool> printTestReceipt({String printerName = 'iMin Printer'}) async {
    final ok = await _ensureInitialized();
    if (!ok) return false;

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    try {
      await _iminPrinter.printText(
        '=== TEST RECEIPT ===',
        style: IminTextStyle(
          align: IminPrintAlign.center,
          fontSize: 26,
        ),
      );
      await _iminPrinter.printText(
        'Printer: $printerName',
        style: IminTextStyle(align: IminPrintAlign.left),
      );
      await _iminPrinter.printText(
        'Date: $dateStr',
        style: IminTextStyle(align: IminPrintAlign.left),
      );
      await _iminPrinter.printText(
        'This is a test print from OZPOS.',
        style: IminTextStyle(align: IminPrintAlign.left),
      );
      await _iminPrinter.printAndFeedPaper(100);
      await _iminPrinter.sendRAWDataHexStr('0A');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Print a raw receipt text block (newline‑separated lines).
  Future<bool> printOrderReceipt(String receiptText) async {
    if (receiptText.trim().isEmpty) return false;

    final ok = await _ensureInitialized();
    if (!ok) return false;

    try {
      final lines = receiptText.split('\n');
      for (final line in lines) {
        final trimmed = line.trimRight();
        if (trimmed.isEmpty) {
          await _iminPrinter.printAndLineFeed();
        } else {
          await _iminPrinter.printText(
            trimmed,
            style: IminTextStyle(
              wordWrap: true,
              align: IminPrintAlign.left,
            ),
          );
        }
      }

      await _iminPrinter.printAndFeedPaper(100);
      await _iminPrinter.sendRAWDataHexStr('0A');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Open the connected cash drawer if supported.
  Future<bool> openCashDrawer() async {
    final ok = await _ensureInitialized();
    if (!ok) return false;
    try {
      await _iminPrinter.openCashBox();
      return true;
    } catch (_) {
      return false;
    }
  }
}
