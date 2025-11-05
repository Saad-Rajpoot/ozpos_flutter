import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/combo_entity.dart';
import '../../domain/entities/combo_slot_entity.dart';
import '../../domain/entities/combo_pricing_entity.dart';
import '../../domain/entities/combo_availability_entity.dart';
import '../../domain/entities/combo_limits_entity.dart';
import 'combo_management_event.dart';
import 'combo_management_state.dart';
import '../../domain/usecases/get_combos.dart';
import '../../domain/usecases/create_combo.dart';
import '../../domain/usecases/update_combo.dart';
import '../../domain/usecases/delete_combo.dart';
import '../../domain/usecases/validate_combo.dart';
import '../../domain/usecases/calculate_pricing.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/base/base_bloc.dart';

class ComboManagementBloc
    extends BaseBloc<ComboManagementEvent, ComboManagementState> {
  final Uuid _uuid;
  final GetCombos _getCombos;
  final CreateCombo _createCombo;
  final UpdateCombo _updateCombo;
  final DeleteCombo _deleteCombo;
  final ValidateCombo _validateCombo;
  final CalculatePricing _calculatePricing;

  ComboManagementBloc({
    required Uuid uuid,
    required GetCombos getCombos,
    required CreateCombo createCombo,
    required UpdateCombo updateCombo,
    required DeleteCombo deleteCombo,
    required ValidateCombo validateCombo,
    required CalculatePricing calculatePricing,
  })  : _uuid = uuid,
        _getCombos = getCombos,
        _createCombo = createCombo,
        _updateCombo = updateCombo,
        _deleteCombo = deleteCombo,
        _validateCombo = validateCombo,
        _calculatePricing = calculatePricing,
        super(const ComboManagementState()) {
    on<LoadCombos>(_onLoadCombos);
    on<RefreshCombos>(_onRefreshCombos);
    on<CreateComboEvent>(_onCreateCombo);
    on<UpdateComboEvent>(_onUpdateCombo);
    on<DeleteComboEvent>(_onDeleteCombo);
    on<DuplicateComboEvent>(_onDuplicateCombo);
    on<ToggleComboVisibility>(_onToggleComboVisibility);
    on<StartComboEdit>(_onStartComboEdit);
    on<CancelComboEdit>(_onCancelComboEdit);
    on<SaveComboChanges>(_onSaveComboChanges);
    on<SelectTab>(_onSelectTab);
    on<UpdateComboName>(_onUpdateComboName);
    on<UpdateComboDescription>(_onUpdateComboDescription);
    on<UpdateComboImage>(_onUpdateComboImage);
    on<UpdateComboCategory>(_onUpdateComboCategory);
    on<UpdateComboPointsReward>(_onUpdateComboPointsReward);
    on<AddComboSlot>(_onAddComboSlot);
    on<UpdateComboSlot>(_onUpdateComboSlot);
    on<RemoveComboSlot>(_onRemoveComboSlot);
    on<ReorderComboSlots>(_onReorderComboSlots);
    on<DuplicateComboSlot>(_onDuplicateComboSlot);
    on<UpdateComboPricing>(_onUpdateComboPricing);
    on<RecalculatePricing>(_onRecalculatePricing);
    on<UpdateComboAvailability>(_onUpdateComboAvailability);
    on<UpdateComboLimits>(_onUpdateComboLimits);
    on<ValidateCurrentCombo>(_onValidateCurrentCombo);
    on<MarkAsUnsaved>(_onMarkAsUnsaved);
    on<SaveAllCombos>(_onSaveAllCombos);
    on<DiscardAllUnsavedChanges>(_onDiscardAllUnsavedChanges);
    on<SearchCombos>(_onSearchCombos);
    on<FilterCombosByStatus>(_onFilterCombosByStatus);
    on<FilterCombosByCategory>(_onFilterCombosByCategory);
    on<ClearFilters>(_onClearFilters);

    // Auto-load combos on initialization
    add(const LoadCombos());
  }

  Future<void> _onLoadCombos(
    LoadCombos event,
    Emitter<ComboManagementState> emit,
  ) async {
    emit(state.copyWith(status: ComboLoadingStatus.loading));

    try {
      final combos = await _loadCombosFromRepository();
      final filteredCombos = _applyFilters(combos);

      emit(
        state.copyWith(
          status: ComboLoadingStatus.loaded,
          combos: combos,
          filteredCombos: filteredCombos,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ComboLoadingStatus.error,
          errorMessage: 'Failed to load combos: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRefreshCombos(
    RefreshCombos event,
    Emitter<ComboManagementState> emit,
  ) async {
    add(const LoadCombos());
  }

  Future<void> _onCreateCombo(
    CreateComboEvent event,
    Emitter<ComboManagementState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveError: null));

    final result = await _createCombo(CreateComboParams(combo: event.combo));

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            saveError: 'Failed to create combo: ${failure.message}',
          ),
        );
      },
      (createdCombo) {
        final newState = state.withAddedCombo(createdCombo);
        final filteredCombos = _applyFilters(newState.combos);

        emit(
          newState.copyWith(
            filteredCombos: filteredCombos,
            isSaving: false,
            unsavedChangesCount: state.unsavedChangesCount - 1,
            lastSavedCombo: createdCombo,
          ),
        );
      },
    );
  }

  Future<void> _onUpdateCombo(
    UpdateComboEvent event,
    Emitter<ComboManagementState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveError: null));

    final result = await _updateCombo(UpdateComboParams(combo: event.combo));

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            saveError: 'Failed to update combo: ${failure.message}',
          ),
        );
      },
      (updatedCombo) {
        final newState = state.withUpdatedCombo(updatedCombo);
        final filteredCombos = _applyFilters(newState.combos);

        emit(
          newState.copyWith(
            filteredCombos: filteredCombos,
            isSaving: false,
            unsavedChangesCount: state.unsavedChangesCount - 1,
            lastSavedCombo: updatedCombo,
          ),
        );
      },
    );
  }

  Future<void> _onDeleteCombo(
    DeleteComboEvent event,
    Emitter<ComboManagementState> emit,
  ) async {
    final result =
        await _deleteCombo(DeleteComboParams(comboId: event.comboId));

    result.fold(
      (failure) {
        emit(
          state.copyWith(
              errorMessage: 'Failed to delete combo: ${failure.message}'),
        );
      },
      (_) {
        final newState = state.withRemovedCombo(event.comboId);
        final filteredCombos = _applyFilters(newState.combos);

        emit(newState.copyWith(filteredCombos: filteredCombos));
      },
    );
  }

  Future<void> _onDuplicateCombo(
    DuplicateComboEvent event,
    Emitter<ComboManagementState> emit,
  ) async {
    final originalCombo = state.getComboById(event.comboId);
    if (originalCombo == null) return;

    final newName = event.newName ?? originalCombo.name;
    final duplicatedCombo = originalCombo.copyWith(
      id: _uuid.v4(),
      name: newName,
      status: ComboStatus.draft,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      hasUnsavedChanges: true,
    );

    add(CreateComboEvent(combo: duplicatedCombo));
  }

  Future<void> _onToggleComboVisibility(
    ToggleComboVisibility event,
    Emitter<ComboManagementState> emit,
  ) async {
    final combo = state.getComboById(event.comboId);
    if (combo == null) return;

    final updatedCombo = combo.copyWith(
      status: event.newStatus,
      updatedAt: DateTime.now(),
      hasUnsavedChanges: true,
    );

    add(UpdateComboEvent(combo: updatedCombo));
  }

  void _onStartComboEdit(
    StartComboEdit event,
    Emitter<ComboManagementState> emit,
  ) {
    if (event.comboId != null) {
      // Edit existing combo
      final combo = state.getComboById(event.comboId!);
      if (combo == null) return;

      emit(
        state.copyWith(
          editMode: ComboEditMode.edit,
          editingCombo: combo,
          isBuilderOpen: true,
          selectedTab: 'details',
          validationErrors: combo.validationErrors,
          saveError: null,
        ),
      );
    } else {
      // Create new combo
      final newCombo = _createDefaultCombo();
      emit(
        state.copyWith(
          editMode: ComboEditMode.create,
          editingCombo: newCombo,
          isBuilderOpen: true,
          selectedTab: 'details',
          validationErrors: newCombo.validationErrors,
          saveError: null,
        ),
      );
    }
  }

  void _onCancelComboEdit(
    CancelComboEdit event,
    Emitter<ComboManagementState> emit,
  ) {
    emit(state.exitEditMode());
  }

  Future<void> _onSaveComboChanges(
    SaveComboChanges event,
    Emitter<ComboManagementState> emit,
  ) async {
    final combo = state.editingCombo;
    if (combo == null) return;

    // Validate before saving
    final validationErrors = combo.validationErrors;
    if (validationErrors.isNotEmpty) {
      emit(state.copyWith(validationErrors: validationErrors));
      return;
    }

    final savedCombo = combo.copyWith(
      updatedAt: DateTime.now(),
      hasUnsavedChanges: false,
    );

    if (state.editMode == ComboEditMode.create) {
      add(CreateComboEvent(combo: savedCombo));
    } else {
      add(UpdateComboEvent(combo: savedCombo));
    }

    if (event.exitAfterSave) {
      emit(state.exitEditMode());
    }
  }

  void _onSelectTab(SelectTab event, Emitter<ComboManagementState> emit) {
    emit(state.copyWith(selectedTab: event.tabId));
  }

  void _onUpdateComboName(
    UpdateComboName event,
    Emitter<ComboManagementState> emit,
  ) {
    final combo = state.editingCombo;
    if (combo == null) return;

    final updatedCombo = combo.copyWith(
      name: event.name,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        editingCombo: updatedCombo,
        validationErrors: updatedCombo.validationErrors,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  void _onUpdateComboDescription(
    UpdateComboDescription event,
    Emitter<ComboManagementState> emit,
  ) {
    final combo = state.editingCombo;
    if (combo == null) return;

    final updatedCombo = combo.copyWith(
      description: event.description,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        editingCombo: updatedCombo,
        validationErrors: updatedCombo.validationErrors,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  void _onUpdateComboImage(
    UpdateComboImage event,
    Emitter<ComboManagementState> emit,
  ) {
    final combo = state.editingCombo;
    if (combo == null) return;

    final updatedCombo = combo.copyWith(
      image: event.imageUrl,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        editingCombo: updatedCombo,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  void _onUpdateComboCategory(
    UpdateComboCategory event,
    Emitter<ComboManagementState> emit,
  ) {
    final combo = state.editingCombo;
    if (combo == null) return;

    final updatedCombo = combo.copyWith(
      categoryTag: event.categoryTag,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        editingCombo: updatedCombo,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  void _onUpdateComboPointsReward(
    UpdateComboPointsReward event,
    Emitter<ComboManagementState> emit,
  ) {
    final combo = state.editingCombo;
    if (combo == null) return;

    final updatedCombo = combo.copyWith(
      pointsReward: event.pointsReward,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        editingCombo: updatedCombo,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  void _onAddComboSlot(AddComboSlot event, Emitter<ComboManagementState> emit) {
    final combo = state.editingCombo;
    if (combo == null) return;

    final updatedSlots = [...combo.slots, event.slot];
    final updatedCombo = combo.copyWith(
      slots: updatedSlots,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        editingCombo: updatedCombo,
        validationErrors: updatedCombo.validationErrors,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );

    // Recalculate pricing after slot changes
    add(const RecalculatePricing());
  }

  void _onUpdateComboSlot(
    UpdateComboSlot event,
    Emitter<ComboManagementState> emit,
  ) {
    final combo = state.editingCombo;
    if (combo == null) return;

    final updatedSlots = combo.slots.map((slot) {
      return slot.id == event.slotId ? event.updatedSlot : slot;
    }).toList();

    final updatedCombo = combo.copyWith(
      slots: updatedSlots,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        editingCombo: updatedCombo,
        validationErrors: updatedCombo.validationErrors,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );

    // Recalculate pricing after slot changes
    add(const RecalculatePricing());
  }

  void _onRemoveComboSlot(
    RemoveComboSlot event,
    Emitter<ComboManagementState> emit,
  ) {
    final combo = state.editingCombo;
    if (combo == null) return;

    final updatedSlots =
        combo.slots.where((slot) => slot.id != event.slotId).toList();
    final updatedCombo = combo.copyWith(
      slots: updatedSlots,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        editingCombo: updatedCombo,
        validationErrors: updatedCombo.validationErrors,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );

    // Recalculate pricing after slot changes
    add(const RecalculatePricing());
  }

  void _onReorderComboSlots(
    ReorderComboSlots event,
    Emitter<ComboManagementState> emit,
  ) {
    final combo = state.editingCombo;
    if (combo == null) return;

    final reorderedSlots = <ComboSlotEntity>[];
    for (int i = 0; i < event.slotIds.length; i++) {
      final slot = combo.slots.firstWhere((s) => s.id == event.slotIds[i]);
      reorderedSlots.add(slot.copyWith(sortOrder: i));
    }

    final updatedCombo = combo.copyWith(
      slots: reorderedSlots,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        editingCombo: updatedCombo,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  void _onDuplicateComboSlot(
    DuplicateComboSlot event,
    Emitter<ComboManagementState> emit,
  ) {
    final combo = state.editingCombo;
    if (combo == null) return;

    final originalSlot = combo.slots.firstWhere(
      (slot) => slot.id == event.slotId,
    );
    final duplicatedSlot = originalSlot.copyWith(
      id: _uuid.v4(),
      name: originalSlot.name,
      sortOrder: combo.slots.length,
    );

    add(AddComboSlot(slot: duplicatedSlot));
  }

  void _onUpdateComboPricing(
    UpdateComboPricing event,
    Emitter<ComboManagementState> emit,
  ) {
    final combo = state.editingCombo;
    if (combo == null) return;

    final updatedCombo = combo.copyWith(
      pricing: event.pricing,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        editingCombo: updatedCombo,
        validationErrors: updatedCombo.validationErrors,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  Future<void> _onRecalculatePricing(
    RecalculatePricing event,
    Emitter<ComboManagementState> emit,
  ) async {
    final combo = state.editingCombo;
    if (combo == null) return;

    final result =
        await _calculatePricing(CalculatePricingParams(combo: combo));

    result.fold(
      (failure) {
        emit(state.copyWith(
            errorMessage: 'Failed to calculate pricing: ${failure.message}'));
      },
      (calculatedPricing) {
        final updatedCombo = combo.copyWith(
          pricing: calculatedPricing,
          hasUnsavedChanges: true,
        );

        emit(
          state.copyWith(
            editingCombo: updatedCombo,
            validationErrors: updatedCombo.validationErrors,
            unsavedChangesCount: state.unsavedChangesCount + 1,
          ),
        );
      },
    );
  }

  void _onUpdateComboAvailability(
    UpdateComboAvailability event,
    Emitter<ComboManagementState> emit,
  ) {
    final combo = state.editingCombo;
    if (combo == null) return;

    final updatedCombo = combo.copyWith(
      availability: event.availability,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        editingCombo: updatedCombo,
        validationErrors: updatedCombo.validationErrors,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  void _onUpdateComboLimits(
    UpdateComboLimits event,
    Emitter<ComboManagementState> emit,
  ) {
    final combo = state.editingCombo;
    if (combo == null) return;

    final updatedCombo = combo.copyWith(
      limits: event.limits,
      hasUnsavedChanges: true,
    );

    emit(
      state.copyWith(
        editingCombo: updatedCombo,
        validationErrors: updatedCombo.validationErrors,
        unsavedChangesCount: state.unsavedChangesCount + 1,
      ),
    );
  }

  Future<void> _onValidateCurrentCombo(
    ValidateCurrentCombo event,
    Emitter<ComboManagementState> emit,
  ) async {
    final combo = state.editingCombo;
    if (combo == null) return;

    final result = await _validateCombo(ValidateComboParams(combo: combo));

    result.fold(
      (failure) {
        // Handle validation failure if needed
        emit(state.copyWith(
            validationErrors: ['Validation failed: ${failure.message}']));
      },
      (validationErrors) {
        emit(state.copyWith(validationErrors: validationErrors));
      },
    );
  }

  void _onMarkAsUnsaved(
    MarkAsUnsaved event,
    Emitter<ComboManagementState> emit,
  ) {
    emit(state.copyWith(unsavedChangesCount: state.unsavedChangesCount + 1));
  }

  Future<void> _onSaveAllCombos(
    SaveAllCombos event,
    Emitter<ComboManagementState> emit,
  ) async {
    emit(state.copyWith(unsavedChangesCount: 0));
  }

  void _onDiscardAllUnsavedChanges(
    DiscardAllUnsavedChanges event,
    Emitter<ComboManagementState> emit,
  ) {
    emit(state.copyWith(unsavedChangesCount: 0));
  }

  void _onSearchCombos(SearchCombos event, Emitter<ComboManagementState> emit) {
    final filteredCombos = _applyFilters(
      state.combos,
      searchQuery: event.query,
    );
    emit(
      state.copyWith(searchQuery: event.query, filteredCombos: filteredCombos),
    );
  }

  void _onFilterCombosByStatus(
    FilterCombosByStatus event,
    Emitter<ComboManagementState> emit,
  ) {
    final filteredCombos = _applyFilters(
      state.combos,
      statusFilter: event.status,
    );
    emit(
      state.copyWith(
        statusFilter: event.status,
        filteredCombos: filteredCombos,
      ),
    );
  }

  void _onFilterCombosByCategory(
    FilterCombosByCategory event,
    Emitter<ComboManagementState> emit,
  ) {
    final filteredCombos = _applyFilters(
      state.combos,
      categoryFilter: event.categoryTag,
    );
    emit(
      state.copyWith(
        categoryFilter: event.categoryTag,
        filteredCombos: filteredCombos,
      ),
    );
  }

  void _onClearFilters(ClearFilters event, Emitter<ComboManagementState> emit) {
    final filteredCombos = _applyFilters(state.combos);
    emit(state.clearFilters().copyWith(filteredCombos: filteredCombos));
  }

  // Helper methods

  ComboEntity _createDefaultCombo() {
    return ComboEntity(
      id: _uuid.v4(),
      name: '',
      description: '',
      status: ComboStatus.draft,
      slots: [],
      pricing: ComboPricingEntity.fixed(fixedPrice: 0.0, totalIfSeparate: 0.0),
      availability: const ComboAvailabilityEntity(),
      limits: ComboLimitsEntity.noLimits(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      hasUnsavedChanges: true,
    );
  }

  List<ComboEntity> _applyFilters(
    List<ComboEntity> combos, {
    String? searchQuery,
    ComboStatus? statusFilter,
    String? categoryFilter,
  }) {
    final query = searchQuery ?? state.searchQuery;
    final status = statusFilter ?? state.statusFilter;
    final category = categoryFilter ?? state.categoryFilter;

    var filtered = combos.where((combo) {
      // Search filter
      if (query.isNotEmpty) {
        final searchLower = query.toLowerCase();
        if (!combo.name.toLowerCase().contains(searchLower) &&
            !combo.description.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Status filter
      if (status != null && combo.status != status) {
        return false;
      }

      // Category filter
      if (category != null && combo.categoryTag != category) {
        return false;
      }

      return true;
    }).toList();

    // Sort by updated date (most recent first)
    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return filtered;
  }

  Future<List<ComboEntity>> _loadCombosFromRepository() async {
    // Simulate loading with sample data
    final result = await _getCombos(const NoParams());
    return result.fold((failure) => [], (combos) => combos);
  }
}
