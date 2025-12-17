import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/base/base_bloc.dart';
import 'addon_management_event.dart';
import 'addon_management_state.dart';
import '../../domain/usecases/get_addon_categories.dart';

class AddonManagementBloc
    extends BaseBloc<AddonManagementEvent, AddonManagementState> {
  final GetAddonCategories _getAddonCategories;

  AddonManagementBloc({required GetAddonCategories getAddonCategories})
    : _getAddonCategories = getAddonCategories,
      super(const AddonManagementInitial()) {
    on<LoadAddonCategoriesEvent>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(
    LoadAddonCategoriesEvent event,
    Emitter<AddonManagementState> emit,
  ) async {
    emit(const AddonManagementLoading());

    final result = await _getAddonCategories(const NoParams());

    result.fold(
      (failure) => emit(
        AddonManagementError('Failed to load categories: ${failure.message}'),
      ),
      (categories) => emit(AddonManagementLoaded(categories: categories)),
    );
  }
}
