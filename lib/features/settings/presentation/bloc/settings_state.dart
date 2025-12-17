import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/settings_entities.dart';

abstract class SettingsState extends BaseState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final List<SettingsCategoryEntity> categories;
  
  const SettingsLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class SettingsError extends SettingsState {
  final String message;
  
  const SettingsError(this.message);

  @override
  List<Object> get props => [message];
}
