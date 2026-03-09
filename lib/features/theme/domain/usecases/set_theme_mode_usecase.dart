import '../entities/theme_mode_entity.dart';
import '../repositories/theme_repository.dart';

/// Use case to persist the selected theme mode.
class SetThemeModeUsecase {
  final ThemeRepository repository;

  SetThemeModeUsecase(this.repository);

  Future<void> call(AppThemeMode mode) => repository.setThemeMode(mode);
}
