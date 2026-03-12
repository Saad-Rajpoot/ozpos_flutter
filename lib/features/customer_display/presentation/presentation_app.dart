import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
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

    if (kDebugMode) {
      debugPrint('CustomerDisplayPresentationApp: initState');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Customer Display',
        theme: ThemeData.dark(useMaterial3: true),
        home: SecondaryDisplay(
          callback: (data) {
            _cubit.applyPayload(data);
          },
          child: const CustomerDisplayScreen(),
        ),
      ),
    );
  }
}

