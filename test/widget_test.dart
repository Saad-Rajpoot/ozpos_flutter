// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ozpos_flutter/core/di/injection_container.dart' as di;
import 'package:ozpos_flutter/core/auth/auth_cubit.dart';
import 'package:ozpos_flutter/features/theme/domain/usecases/get_theme_mode_usecase.dart';
import 'package:ozpos_flutter/features/theme/domain/usecases/set_theme_mode_usecase.dart';
import 'package:ozpos_flutter/features/theme/presentation/bloc/theme_bloc.dart';
import 'package:ozpos_flutter/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await di.init();
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final authCubit = di.sl<AuthCubit>();
    final getThemeMode = di.sl<GetThemeModeUsecase>();
    final initialThemeMode = await getThemeMode();
    final themeBloc = ThemeBloc(
      getThemeMode: getThemeMode,
      setThemeMode: di.sl<SetThemeModeUsecase>(),
      initialMode: initialThemeMode,
    );

    await tester.pumpWidget(
      OzposApp(
        authCubit: authCubit,
        themeBloc: themeBloc,
      ),
    );
    await tester.pump();

    // Verify that the app builds and shows a MaterialApp.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
