import '../entities/theme_mode_entity.dart';
import '../repositories/theme_repository.dart';

/// Use case to retrieve the persisted theme mode.
class GetThemeModeUsecase {
  final ThemeRepository repository;

  GetThemeModeUsecase(this.repository);

  Future<AppThemeMode> call() => repository.getThemeMode();
}
