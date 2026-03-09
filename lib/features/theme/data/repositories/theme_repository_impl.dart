import '../../domain/entities/theme_mode_entity.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_datasource.dart';

/// Implementation of [ThemeRepository] using local storage.
class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource _localDataSource;

  ThemeRepositoryImpl({required ThemeLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<void> setThemeMode(AppThemeMode mode) =>
      _localDataSource.saveThemeMode(mode);

  @override
  Future<AppThemeMode> getThemeMode() => _localDataSource.getThemeMode();
}
