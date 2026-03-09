import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/theme_mode_entity.dart';
import '../../domain/usecases/get_theme_mode_usecase.dart';
import '../../domain/usecases/set_theme_mode_usecase.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends BaseBloc<ThemeEvent, ThemeState> {
  final GetThemeModeUsecase _getThemeMode;
  final SetThemeModeUsecase _setThemeMode;

  ThemeBloc({
    required GetThemeModeUsecase getThemeMode,
    required SetThemeModeUsecase setThemeMode,
    AppThemeMode? initialMode,
  })  : _getThemeMode = getThemeMode,
        _setThemeMode = setThemeMode,
        super(initialMode != null ? ThemeLoaded(initialMode) : const ThemeInitial()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ChangeThemeEvent>(_onChangeTheme);
  }

  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final mode = await _getThemeMode();
    emit(ThemeLoaded(mode));
  }

  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await _setThemeMode(event.mode);
    emit(ThemeLoaded(event.mode));
  }
}
