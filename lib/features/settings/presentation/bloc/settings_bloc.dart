import 'package:dartz/dartz.dart';
import '../../domain/entities/settings_entities.dart';
import '../../domain/usecases/get_settings_categories.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/base/base_bloc.dart';
import '../../../../core/errors/failures.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends BaseBloc<SettingsEvent, SettingsState> {
  final GetSettingsCategories getSettingsCategories;

  SettingsBloc({required this.getSettingsCategories})
      : super(const SettingsInitial()) {
    on<LoadSettings>((event, emit) async {
      emit(const SettingsLoading());
      final Either<Failure, List<SettingsCategoryEntity>> result =
          await getSettingsCategories(const NoParams());
      result.fold(
        (failure) => emit(SettingsError(failure.message)),
        (categories) => emit(SettingsLoaded(categories)),
      );
    });
  }
}
