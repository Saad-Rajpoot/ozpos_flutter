import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/theme_mode_entity.dart';

abstract class ThemeEvent extends BaseEvent {
  const ThemeEvent();
}

/// Load persisted theme mode (e.g. on app startup).
class LoadThemeEvent extends ThemeEvent {
  const LoadThemeEvent();
}

/// Change theme and persist the selection.
class ChangeThemeEvent extends ThemeEvent {
  final AppThemeMode mode;

  const ChangeThemeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}
