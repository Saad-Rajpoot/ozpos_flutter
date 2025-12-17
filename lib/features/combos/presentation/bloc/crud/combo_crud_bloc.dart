import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/base/base_bloc.dart';
import '../../../domain/entities/combo_entity.dart';
import '../../../domain/usecases/create_combo.dart';
import '../../../domain/usecases/delete_combo.dart';
import '../../../domain/usecases/get_combos.dart';
import '../../../domain/usecases/update_combo.dart';
import '../../../../../core/base/base_usecase.dart';
import 'combo_crud_event.dart';
import 'combo_crud_state.dart';

class ComboCrudBloc extends BaseBloc<ComboCrudEvent, ComboCrudState> {
  final Uuid _uuid;
  final GetCombos _getCombos;
  final CreateCombo _createCombo;
  final UpdateCombo _updateCombo;
  final DeleteCombo _deleteCombo;

  ComboCrudBloc({
    required Uuid uuid,
    required GetCombos getCombos,
    required CreateCombo createCombo,
    required UpdateCombo updateCombo,
    required DeleteCombo deleteCombo,
  })  : _uuid = uuid,
        _getCombos = getCombos,
        _createCombo = createCombo,
        _updateCombo = updateCombo,
        _deleteCombo = deleteCombo,
        super(const ComboCrudState()) {
    on<CombosRequested>(_onCombosRequested);
    on<CombosRefreshed>(_onCombosRefreshed);
    on<ComboCreated>(_onComboCreated);
    on<ComboUpdated>(_onComboUpdated);
    on<ComboDeleted>(_onComboDeleted);
    on<ComboDuplicated>(_onComboDuplicated);
    on<ComboVisibilityToggled>(_onComboVisibilityToggled);

    add(const CombosRequested());
  }

  Future<void> _onCombosRequested(
    CombosRequested event,
    Emitter<ComboCrudState> emit,
  ) async {
    emit(state.copyWith(
      status: ComboLoadingStatus.loading,
      errorMessage: null,
      saveError: null,
      resetLastSavedCombo: true,
    ));

    final result = await _getCombos(const NoParams());
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: ComboLoadingStatus.error,
          errorMessage: 'Failed to load combos: ${failure.message}',
        ));
      },
      (combos) {
        emit(state.copyWith(
          status: ComboLoadingStatus.loaded,
          combos: combos,
          errorMessage: null,
          resetLastSavedCombo: true,
        ));
      },
    );
  }

  Future<void> _onCombosRefreshed(
    CombosRefreshed event,
    Emitter<ComboCrudState> emit,
  ) async {
    add(const CombosRequested());
  }

  Future<void> _onComboCreated(
    ComboCreated event,
    Emitter<ComboCrudState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveError: null));

    final result = await _createCombo(CreateComboParams(combo: event.combo));
    result.fold(
      (failure) {
        emit(state.copyWith(
          isSaving: false,
          saveError: 'Failed to create combo: ${failure.message}',
          resetLastSavedCombo: true,
        ));
      },
      (createdCombo) {
        final updatedCombos = [...state.combos, createdCombo];
        emit(state.copyWith(
          combos: updatedCombos,
          isSaving: false,
          lastSavedCombo: createdCombo,
          status: ComboLoadingStatus.loaded,
        ));
      },
    );
  }

  Future<void> _onComboUpdated(
    ComboUpdated event,
    Emitter<ComboCrudState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveError: null));

    final result = await _updateCombo(UpdateComboParams(combo: event.combo));
    result.fold(
      (failure) {
        emit(state.copyWith(
          isSaving: false,
          saveError: 'Failed to update combo: ${failure.message}',
          resetLastSavedCombo: true,
        ));
      },
      (updatedCombo) {
        final updatedCombos = state.combos
            .map((combo) => combo.id == updatedCombo.id ? updatedCombo : combo)
            .toList();
        emit(state.copyWith(
          combos: updatedCombos,
          isSaving: false,
          lastSavedCombo: updatedCombo,
          status: ComboLoadingStatus.loaded,
        ));
      },
    );
  }

  Future<void> _onComboDeleted(
    ComboDeleted event,
    Emitter<ComboCrudState> emit,
  ) async {
    final result =
        await _deleteCombo(DeleteComboParams(comboId: event.comboId));

    result.fold(
      (failure) {
        emit(state.copyWith(
          errorMessage: 'Failed to delete combo: ${failure.message}',
        ));
      },
      (_) {
        final updatedCombos =
            state.combos.where((combo) => combo.id != event.comboId).toList();
        emit(state.copyWith(
          combos: updatedCombos,
          status: ComboLoadingStatus.loaded,
          resetLastSavedCombo: true,
        ));
      },
    );
  }

  Future<void> _onComboDuplicated(
    ComboDuplicated event,
    Emitter<ComboCrudState> emit,
  ) async {
    final originalCombo = state.getComboById(event.comboId);
    if (originalCombo == null) return;

    final duplicatedCombo = originalCombo.copyWith(
      id: _uuid.v4(),
      name: event.newName ?? originalCombo.name,
      status: ComboStatus.draft,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      hasUnsavedChanges: true,
    );

    add(ComboCreated(combo: duplicatedCombo));
  }

  Future<void> _onComboVisibilityToggled(
    ComboVisibilityToggled event,
    Emitter<ComboCrudState> emit,
  ) async {
    final combo = state.getComboById(event.comboId);
    if (combo == null) return;

    final updatedCombo = combo.copyWith(
      status: event.newStatus,
      updatedAt: DateTime.now(),
      hasUnsavedChanges: true,
    );

    add(ComboUpdated(combo: updatedCombo));
  }
}
