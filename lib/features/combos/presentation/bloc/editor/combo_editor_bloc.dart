import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/base/base_bloc.dart';
import '../../../domain/entities/combo_entity.dart';
import '../../../domain/entities/combo_pricing_entity.dart';
import '../../../domain/entities/combo_availability_entity.dart';
import '../../../domain/entities/combo_limits_entity.dart';
import '../../../domain/entities/combo_slot_entity.dart';
import '../../../domain/usecases/calculate_pricing.dart';
import '../../../domain/usecases/validate_combo.dart';
import '../crud/combo_crud_bloc.dart';
import '../crud/combo_crud_event.dart';
import '../crud/combo_crud_state.dart';
import 'combo_editor_event.dart';
import 'combo_editor_state.dart';

class ComboEditorBloc extends BaseBloc<ComboEditorEvent, ComboEditorState> {
  final Uuid _uuid;
  final ValidateCombo _validateCombo;
  final CalculatePricing _calculatePricing;
  final ComboCrudBloc _crudBloc;

  List<ComboEntity> _allCombos = const [];
  late final StreamSubscription<ComboCrudState> _crudSubscription;

  ComboEditorBloc({
    required Uuid uuid,
    required ValidateCombo validateCombo,
    required CalculatePricing calculatePricing,
    required ComboCrudBloc crudBloc,
  })  : _uuid = uuid,
        _validateCombo = validateCombo,
        _calculatePricing = calculatePricing,
        _crudBloc = crudBloc,
        super(const ComboEditorState()) {
    on<ComboEditorCombosSynced>(_onCombosSynced);
    on<ComboEditingStarted>(_onEditingStarted);
    on<ComboEditingCancelled>(_onEditingCancelled);
    on<ComboSaveRequested>(_onSaveRequested);
    on<ComboTabSelected>(_onTabSelected);
    on<ComboNameChanged>(_onNameChanged);
    on<ComboDescriptionChanged>(_onDescriptionChanged);
    on<ComboImageChanged>(_onImageChanged);
    on<ComboCategoryChanged>(_onCategoryChanged);
    on<ComboPointsRewardChanged>(_onPointsRewardChanged);
    on<ComboSlotAdded>(_onSlotAdded);
    on<ComboSlotUpdated>(_onSlotUpdated);
    on<ComboSlotRemoved>(_onSlotRemoved);
    on<ComboSlotsReordered>(_onSlotsReordered);
    on<ComboSlotDuplicated>(_onSlotDuplicated);
    on<ComboPricingChanged>(_onPricingChanged);
    on<ComboPricingRecalculated>(_onPricingRecalculated);
    on<ComboAvailabilityChanged>(_onAvailabilityChanged);
    on<ComboLimitsChanged>(_onLimitsChanged);
    on<ComboValidationRequested>(_onValidationRequested);
    on<ComboUnsavedMarked>(_onUnsavedMarked);
    on<ComboUnsavedResetRequested>(_onUnsavedReset);

    _crudSubscription = _crudBloc.stream.listen((crudState) {
      add(
        ComboEditorCombosSynced(
          combos: crudState.combos,
          lastSavedCombo: crudState.lastSavedCombo,
          saveError: crudState.saveError,
        ),
      );
    });

    add(
      ComboEditorCombosSynced(
        combos: _crudBloc.state.combos,
        lastSavedCombo: _crudBloc.state.lastSavedCombo,
        saveError: _crudBloc.state.saveError,
      ),
    );
  }

  void _onCombosSynced(
    ComboEditorCombosSynced event,
    Emitter<ComboEditorState> emit,
  ) {
    _allCombos = event.combos;

    ComboEditorState newState = state;

    if (event.saveError != null && state.isEditing) {
      newState = newState.copyWith(
        saveError: event.saveError,
        isAwaitingSave: false,
      );
    } else if (event.lastSavedCombo != null) {
      final matched = event.combos.firstWhere(
        (c) => c.id == event.lastSavedCombo!.id,
        orElse: () => event.lastSavedCombo!,
      );
      final updatedDraft =
          state.draft?.id == matched.id ? matched : state.draft;
      newState = newState.copyWith(
        draft: updatedDraft,
        validationErrors: updatedDraft?.validationErrors ?? const [],
        unsavedChangesCount: max(0, state.unsavedChangesCount - 1),
        isAwaitingSave: false,
        saveError: null,
      );
    }

    if (state.draft != null) {
      final updated = event.combos.firstWhere(
        (combo) => combo.id == state.draft!.id,
        orElse: () => state.draft!,
      );
      newState = newState.copyWith(
        draft: updated,
        validationErrors: updated.validationErrors,
      );
    }

    emit(newState);
  }

  void _onEditingStarted(
    ComboEditingStarted event,
    Emitter<ComboEditorState> emit,
  ) {
    if (event.comboId != null) {
      final combo = _allCombos.firstWhere(
        (c) => c.id == event.comboId,
        orElse: () => throw ArgumentError('Combo not found'),
      );

      emit(
        state.copyWith(
          mode: ComboEditMode.edit,
          draft: combo,
          isBuilderOpen: true,
          selectedTab: 'details',
          validationErrors: combo.validationErrors,
          saveError: null,
          isAwaitingSave: false,
        ),
      );
    } else {
      final newCombo = _createDefaultCombo();
      emit(
        state.copyWith(
          mode: ComboEditMode.create,
          draft: newCombo,
          isBuilderOpen: true,
          selectedTab: 'details',
          validationErrors: newCombo.validationErrors,
          saveError: null,
          isAwaitingSave: false,
        ),
      );
    }
  }

  void _onEditingCancelled(
    ComboEditingCancelled event,
    Emitter<ComboEditorState> emit,
  ) {
    emit(state.exitEditMode());
  }

  Future<void> _onSaveRequested(
    ComboSaveRequested event,
    Emitter<ComboEditorState> emit,
  ) async {
    final combo = state.draft;
    if (combo == null) return;

    final validationErrors = combo.validationErrors;
    if (validationErrors.isNotEmpty) {
      emit(
        state.copyWith(
          validationErrors: validationErrors,
          isAwaitingSave: false,
        ),
      );
      return;
    }

    final savedCombo = combo.copyWith(
      updatedAt: DateTime.now(),
      hasUnsavedChanges: false,
    );

    emit(
      state.copyWith(
        isAwaitingSave: true,
        saveError: null,
      ),
    );

    if (state.mode == ComboEditMode.create) {
      _crudBloc.add(ComboCreated(combo: savedCombo));
    } else {
      _crudBloc.add(ComboUpdated(combo: savedCombo));
    }

    if (event.exitAfterSave) {
      emit(state.exitEditMode());
    }
  }

  void _onTabSelected(
    ComboTabSelected event,
    Emitter<ComboEditorState> emit,
  ) {
    emit(state.copyWith(selectedTab: event.tabId));
  }

  void _onNameChanged(
    ComboNameChanged event,
    Emitter<ComboEditorState> emit,
  ) {
    final draft = state.draft;
    if (draft == null) return;

    final updated = draft.copyWith(
      name: event.name,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        draft: updated,
        validationErrors: updated.validationErrors,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  void _onDescriptionChanged(
    ComboDescriptionChanged event,
    Emitter<ComboEditorState> emit,
  ) {
    final draft = state.draft;
    if (draft == null) return;

    final updated = draft.copyWith(
      description: event.description,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        draft: updated,
        validationErrors: updated.validationErrors,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  void _onImageChanged(
    ComboImageChanged event,
    Emitter<ComboEditorState> emit,
  ) {
    final draft = state.draft;
    if (draft == null) return;

    final updated = draft.copyWith(
      image: event.imageUrl,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        draft: updated,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  void _onCategoryChanged(
    ComboCategoryChanged event,
    Emitter<ComboEditorState> emit,
  ) {
    final draft = state.draft;
    if (draft == null) return;

    final updated = draft.copyWith(
      categoryTag: event.categoryTag,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        draft: updated,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  void _onPointsRewardChanged(
    ComboPointsRewardChanged event,
    Emitter<ComboEditorState> emit,
  ) {
    final draft = state.draft;
    if (draft == null) return;

    final updated = draft.copyWith(
      pointsReward: event.pointsReward,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        draft: updated,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  void _onSlotAdded(
    ComboSlotAdded event,
    Emitter<ComboEditorState> emit,
  ) {
    final draft = state.draft;
    if (draft == null) return;

    final updated = draft.copyWith(
      slots: [...draft.slots, event.slot],
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        draft: updated,
        validationErrors: updated.validationErrors,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );

    add(const ComboPricingRecalculated());
  }

  void _onSlotUpdated(
    ComboSlotUpdated event,
    Emitter<ComboEditorState> emit,
  ) {
    final draft = state.draft;
    if (draft == null) return;

    final updatedSlots = draft.slots.map((slot) {
      return slot.id == event.slotId ? event.updatedSlot : slot;
    }).toList();

    final updated = draft.copyWith(
      slots: updatedSlots,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        draft: updated,
        validationErrors: updated.validationErrors,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );

    add(const ComboPricingRecalculated());
  }

  void _onSlotRemoved(
    ComboSlotRemoved event,
    Emitter<ComboEditorState> emit,
  ) {
    final draft = state.draft;
    if (draft == null) return;

    final updatedSlots =
        draft.slots.where((slot) => slot.id != event.slotId).toList();

    final updated = draft.copyWith(
      slots: updatedSlots,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        draft: updated,
        validationErrors: updated.validationErrors,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );

    add(const ComboPricingRecalculated());
  }

  void _onSlotsReordered(
    ComboSlotsReordered event,
    Emitter<ComboEditorState> emit,
  ) {
    final draft = state.draft;
    if (draft == null) return;

    final reorderedSlots = <ComboSlotEntity>[];
    for (int i = 0; i < event.slotIds.length; i++) {
      final slot = draft.slots.firstWhere((s) => s.id == event.slotIds[i]);
      reorderedSlots.add(slot.copyWith(sortOrder: i));
    }

    final updated = draft.copyWith(
      slots: reorderedSlots,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        draft: updated,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  void _onSlotDuplicated(
    ComboSlotDuplicated event,
    Emitter<ComboEditorState> emit,
  ) {
    final draft = state.draft;
    if (draft == null) return;

    final original = draft.slots.firstWhere((slot) => slot.id == event.slotId);
    final duplicated = original.copyWith(
      id: _uuid.v4(),
      name: original.name,
      sortOrder: draft.slots.length,
    );

    add(ComboSlotAdded(slot: duplicated));
  }

  void _onPricingChanged(
    ComboPricingChanged event,
    Emitter<ComboEditorState> emit,
  ) {
    final draft = state.draft;
    if (draft == null) return;

    final updated = draft.copyWith(
      pricing: event.pricing,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        draft: updated,
        validationErrors: updated.validationErrors,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  Future<void> _onPricingRecalculated(
    ComboPricingRecalculated event,
    Emitter<ComboEditorState> emit,
  ) async {
    final draft = state.draft;
    if (draft == null) return;

    final result =
        await _calculatePricing(CalculatePricingParams(combo: draft));

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            saveError: 'Failed to calculate pricing: ${failure.message}',
          ),
        );
      },
      (pricing) {
        final updated = draft.copyWith(
          pricing: pricing,
          hasUnsavedChanges: true,
        );

        emit(
          state.copyWith(
            draft: updated,
            validationErrors: updated.validationErrors,
            unsavedChangesCount: state.unsavedChangesCount + 1,
          ),
        );
      },
    );
  }

  void _onAvailabilityChanged(
    ComboAvailabilityChanged event,
    Emitter<ComboEditorState> emit,
  ) {
    final draft = state.draft;
    if (draft == null) return;

    final updated = draft.copyWith(
      availability: event.availability,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        draft: updated,
        validationErrors: updated.validationErrors,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  void _onLimitsChanged(
    ComboLimitsChanged event,
    Emitter<ComboEditorState> emit,
  ) {
    final draft = state.draft;
    if (draft == null) return;

    final updated = draft.copyWith(
      limits: event.limits,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        draft: updated,
        validationErrors: updated.validationErrors,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  Future<void> _onValidationRequested(
    ComboValidationRequested event,
    Emitter<ComboEditorState> emit,
  ) async {
    final draft = state.draft;
    if (draft == null) return;

    final result = await _validateCombo(ValidateComboParams(combo: draft));

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            validationErrors: ['Validation failed: ${failure.message}'],
          ),
        );
      },
      (errors) {
        emit(state.copyWith(validationErrors: errors));
      },
    );
  }

  void _onUnsavedMarked(
    ComboUnsavedMarked event,
    Emitter<ComboEditorState> emit,
  ) {
    emit(
      state.copyWith(
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  void _onUnsavedReset(
    ComboUnsavedResetRequested event,
    Emitter<ComboEditorState> emit,
  ) {
    emit(state.copyWith(unsavedChangesCount: 0));
  }

  ComboEntity _createDefaultCombo() {
    return ComboEntity(
      id: _uuid.v4(),
      name: '',
      description: '',
      status: ComboStatus.draft,
      slots: [],
      pricing: ComboPricingEntity.fixed(
        fixedPrice: 0.0,
        totalIfSeparate: 0.0,
      ),
      availability: const ComboAvailabilityEntity(),
      limits: ComboLimitsEntity.noLimits(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      hasUnsavedChanges: true,
    );
  }

  @override
  Future<void> close() async {
    await _crudSubscription.cancel();
    await super.close();
  }
}
