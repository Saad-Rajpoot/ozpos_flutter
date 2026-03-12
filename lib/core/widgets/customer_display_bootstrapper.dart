import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../di/injection_container.dart' as di;
import '../services/customer_display_service.dart';

class CustomerDisplayBootstrapper extends StatefulWidget {
  const CustomerDisplayBootstrapper({super.key, required this.child});

  final Widget child;

  @override
  State<CustomerDisplayBootstrapper> createState() =>
      _CustomerDisplayBootstrapperState();
}

class _CustomerDisplayBootstrapperState extends State<CustomerDisplayBootstrapper> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (kDebugMode) {
      debugPrint('CustomerDisplayBootstrapper: didChangeDependencies -> start()');
    }

    // Fire-and-forget; never block UI.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (!di.sl.isRegistered<CustomerDisplayService>()) {
          if (kDebugMode) {
            debugPrint(
              'CustomerDisplayBootstrapper: CustomerDisplayService NOT registered in GetIt',
            );
          }
          return;
        }
        await di.sl<CustomerDisplayService>().start();
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('CustomerDisplayBootstrapper: start() threw: $e');
          debugPrint('$st');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

