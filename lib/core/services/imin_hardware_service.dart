import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

/// Thin wrapper around `imin_hardware_plugin` for iMin‑specific hardware.
///
/// - Safe to call on non‑Android platforms: methods no‑op and return `false`.
/// - Focuses on two main features for now:
///   - Secondary display control (turn on/off, brightness).
///   - Cash drawer control (open).
class IminHardwareService {
  IminHardwareService();

  bool get _isAndroid => Platform.isAndroid;

  /// Try to open the attached cash drawer (if supported by the device).
  Future<bool> openCashDrawer() async {
    if (!_isAndroid) return false;
    try {
      return await IminCashBox.open();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('IminHardwareService.openCashDrawer failed: $e');
      }
      return false;
    }
  }

  /// Turn on the built‑in secondary display, if the device has one.
  ///
  /// Depending on the plugin API, this might simply wake the display or
  /// switch it into customer‑facing mode.
  Future<bool> enableSecondaryDisplay() async {
    if (!_isAndroid) return false;
    try {
      final available = await IminDisplay.isAvailable();
      if (!available) return false;
      return await IminDisplay.enable();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('IminHardwareService.enableSecondaryDisplay failed: $e');
      }
      return false;
    }
  }

  /// Turn off or dim the secondary display.
  Future<bool> disableSecondaryDisplay() async {
    if (!_isAndroid) return false;
    try {
      await IminDisplay.disable();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('IminHardwareService.disableSecondaryDisplay failed: $e');
      }
      return false;
    }
  }

  /// Optionally adjust secondary display brightness if the plugin exposes it.
  Future<bool> setSecondaryDisplayBrightness(int level) async {
    if (!_isAndroid) return false;
    try {
      // The current plugin API does not expose a direct brightness setter
      // in the public docs. Keep this method as a placeholder in case
      // brightness control is added in future versions.
      if (kDebugMode) {
        debugPrint(
          'IminHardwareService.setSecondaryDisplayBrightness: not supported',
        );
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'IminHardwareService.setSecondaryDisplayBrightness failed: $e',
        );
      }
      return false;
    }
  }
}

