import '../../../../core/base/base_bloc.dart';

abstract class SettingsEvent extends BaseEvent {
  const SettingsEvent();
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}
