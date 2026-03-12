import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:presentation_displays/secondary_display.dart';

import 'screens/customer_display_screen.dart';
import 'bloc/customer_display_presentation_cubit.dart';

class CustomerDisplayPresentationApp extends StatefulWidget {
  const CustomerDisplayPresentationApp({super.key});

  @override
  State<CustomerDisplayPresentationApp> createState() =>
      _CustomerDisplayPresentationAppState();
}

class _CustomerDisplayPresentationAppState
    extends State<CustomerDisplayPresentationApp> {
  late final CustomerDisplayPresentationCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = CustomerDisplayPresentationCubit();

    // Ensure debug paint overlays are disabled on the presentation engine too.
    debugPaintBaselinesEnabled = false;
    debugPaintSizeEnabled = false;
    debugPaintPointersEnabled = false;
    debugRepaintRainbowEnabled = false;

    if (kDebugMode) {
      debugPrint('CustomerDisplayPresentationApp: initState');
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      // Re-apply in case the Flutter inspector re-enabled it.
      debugPaintBaselinesEnabled = false;
      debugPaintSizeEnabled = false;
      debugPaintPointersEnabled = false;
      debugRepaintRainbowEnabled = false;
      return true;
    }());
    return BlocProvider.value(
      value: _cubit,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Customer Display',
        // Use a light, opaque theme to match the demo/mock screenshots and
        // avoid any chance of transparent surfaces showing underlying content.
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          canvasColor: Colors.white,
        ),
        builder: (context, child) {
          // If the yellow lines are actual text decorations (not debug paint),
          // force-disable underlines globally for the customer display.
          return DefaultTextStyle.merge(
            style: const TextStyle(decoration: TextDecoration.none),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: SecondaryDisplay(
          callback: (data) {
            _cubit.applyPayload(data);
          },
          child: const ColoredBox(
            color: Colors.white,
            child: CustomerDisplayScreen(),
          ),
        ),
      ),
    );
  }
}

