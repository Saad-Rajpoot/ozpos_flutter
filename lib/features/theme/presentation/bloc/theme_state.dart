import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/theme_mode_entity.dart';

abstract class ThemeState extends BaseState {
  const ThemeState();
}

class ThemeInitial extends ThemeState {
  const ThemeInitial();
}

class ThemeLoaded extends ThemeState {
  final AppThemeMode mode;

  const ThemeLoaded(this.mode);

  @override
  List<Object?> get props => [mode];
}
