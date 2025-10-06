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

class ComboManagementBloc extends Bloc<ComboManagementEvent, ComboManagementState> {
  final _uuid = const Uuid();

  ComboManagementBloc() : super(const ComboManagementState()) {
    on<LoadCombos>(_onLoadCombos);
    on<RefreshCombos>(_onRefreshCombos);
    on<CreateCombo>(_onCreateCombo);
    on<UpdateCombo>(_onUpdateCombo);
    on<DeleteCombo>(_onDeleteCombo);
    on<DuplicateCombo>(_onDuplicateCombo);
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

  Future<void> _onLoadCombos(LoadCombos event, Emitter<ComboManagementState> emit) async {
    emit(state.copyWith(status: ComboLoadingStatus.loading));
    
    try {
      // TODO: Replace with actual repository call
      final combos = await _loadCombosFromRepository();
      final filteredCombos = _applyFilters(combos);
      
      emit(state.copyWith(
        status: ComboLoadingStatus.loaded,
        combos: combos,
        filteredCombos: filteredCombos,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ComboLoadingStatus.error,
        errorMessage: 'Failed to load combos: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRefreshCombos(RefreshCombos event, Emitter<ComboManagementState> emit) async {
    add(const LoadCombos());
  }

  Future<void> _onCreateCombo(CreateCombo event, Emitter<ComboManagementState> emit) async {
    emit(state.copyWith(isSaving: true, saveError: null));
    
    try {
      // TODO: Replace with actual repository call
      await _saveComboToRepository(event.combo);
      
      final newState = state.withAddedCombo(event.combo);
      final filteredCombos = _applyFilters(newState.combos);
      
      emit(newState.copyWith(
        filteredCombos: filteredCombos,
        isSaving: false,
        unsavedChangesCount: state.unsavedChangesCount - 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        saveError: 'Failed to create combo: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateCombo(UpdateCombo event, Emitter<ComboManagementState> emit) async {
    emit(state.copyWith(isSaving: true, saveError: null));
    
    try {
      // TODO: Replace with actual repository call
      await _saveComboToRepository(event.combo);
      
      final newState = state.withUpdatedCombo(event.combo);
      final filteredCombos = _applyFilters(newState.combos);
      
      emit(newState.copyWith(
        filteredCombos: filteredCombos,
        isSaving: false,
        unsavedChangesCount: state.unsavedChangesCount - 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        saveError: 'Failed to update combo: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteCombo(DeleteCombo event, Emitter<ComboManagementState> emit) async {
    try {
      // TODO: Replace with actual repository call
      await _deleteComboFromRepository(event.comboId);
      
      final newState = state.withRemovedCombo(event.comboId);
      final filteredCombos = _applyFilters(newState.combos);
      
      emit(newState.copyWith(filteredCombos: filteredCombos));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to delete combo: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDuplicateCombo(DuplicateCombo event, Emitter<ComboManagementState> emit) async {
    final originalCombo = state.getComboById(event.comboId);
    if (originalCombo == null) return;
    
    final newName = event.newName ?? '${originalCombo.name} (Copy)';
    final duplicatedCombo = originalCombo.copyWith(
      id: _uuid.v4(),
      name: newName,
      status: ComboStatus.draft,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      hasUnsavedChanges: true,
    );
    
    add(CreateCombo(combo: duplicatedCombo));
  }

  Future<void> _onToggleComboVisibility(ToggleComboVisibility event, Emitter<ComboManagementState> emit) async {
    final combo = state.getComboById(event.comboId);
    if (combo == null) return;
    
    final updatedCombo = combo.copyWith(
      status: event.newStatus,
      updatedAt: DateTime.now(),
      hasUnsavedChanges: true,
    );
    
    add(UpdateCombo(combo: updatedCombo));
  }

  void _onStartComboEdit(StartComboEdit event, Emitter<ComboManagementState> emit) {
    if (event.comboId != null) {
      // Edit existing combo
      final combo = state.getComboById(event.comboId!);
      if (combo == null) return;
      
      emit(state.copyWith(
        editMode: ComboEditMode.edit,
        editingCombo: combo,
        isBuilderOpen: true,
        selectedTab: 'details',
        validationErrors: combo.validationErrors,
        saveError: null,
      ));
    } else {
      // Create new combo
      final newCombo = _createDefaultCombo();
      emit(state.copyWith(
        editMode: ComboEditMode.create,
        editingCombo: newCombo,
        isBuilderOpen: true,
        selectedTab: 'details',
        validationErrors: newCombo.validationErrors,
        saveError: null,
      ));
    }
  }

  void _onCancelComboEdit(CancelComboEdit event, Emitter<ComboManagementState> emit) {
    emit(state.exitEditMode());
  }

  Future<void> _onSaveComboChanges(SaveComboChanges event, Emitter<ComboManagementState> emit) async {
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
      add(CreateCombo(combo: savedCombo));
    } else {
      add(UpdateCombo(combo: savedCombo));
    }
    
    if (event.exitAfterSave) {
      emit(state.exitEditMode());
    }
  }

  void _onSelectTab(SelectTab event, Emitter<ComboManagementState> emit) {
    emit(state.copyWith(selectedTab: event.tabId));
  }

  void _onUpdateComboName(UpdateComboName event, Emitter<ComboManagementState> emit) {
    final combo = state.editingCombo;
    if (combo == null) return;
    
    final updatedCombo = combo.copyWith(
      name: event.name,
      hasUnsavedChanges: true,
    );
    
    emit(state.copyWith(
      editingCombo: updatedCombo,
      validationErrors: updatedCombo.validationErrors,
      unsavedChangesCount: state.unsavedChangesCount + 1,
    ));
  }

  void _onUpdateComboDescription(UpdateComboDescription event, Emitter<ComboManagementState> emit) {
    final combo = state.editingCombo;
    if (combo == null) return;
    
    final updatedCombo = combo.copyWith(
      description: event.description,
      hasUnsavedChanges: true,
    );
    
    emit(state.copyWith(
      editingCombo: updatedCombo,
      validationErrors: updatedCombo.validationErrors,
      unsavedChangesCount: state.unsavedChangesCount + 1,
    ));
  }

  void _onUpdateComboImage(UpdateComboImage event, Emitter<ComboManagementState> emit) {
    final combo = state.editingCombo;
    if (combo == null) return;
    
    final updatedCombo = combo.copyWith(
      image: event.imageUrl,
      hasUnsavedChanges: true,
    );
    
    emit(state.copyWith(
      editingCombo: updatedCombo,
      unsavedChangesCount: state.unsavedChangesCount + 1,
    ));
  }

  void _onUpdateComboCategory(UpdateComboCategory event, Emitter<ComboManagementState> emit) {
    final combo = state.editingCombo;
    if (combo == null) return;
    
    final updatedCombo = combo.copyWith(
      categoryTag: event.categoryTag,
      hasUnsavedChanges: true,
    );
    
    emit(state.copyWith(
      editingCombo: updatedCombo,
      unsavedChangesCount: state.unsavedChangesCount + 1,
    ));
  }

  void _onUpdateComboPointsReward(UpdateComboPointsReward event, Emitter<ComboManagementState> emit) {
    final combo = state.editingCombo;
    if (combo == null) return;
    
    final updatedCombo = combo.copyWith(
      pointsReward: event.pointsReward,
      hasUnsavedChanges: true,
    );
    
    emit(state.copyWith(
      editingCombo: updatedCombo,
      unsavedChangesCount: state.unsavedChangesCount + 1,
    ));
  }

  void _onAddComboSlot(AddComboSlot event, Emitter<ComboManagementState> emit) {
    final combo = state.editingCombo;
    if (combo == null) return;
    
    final updatedSlots = [...combo.slots, event.slot];
    final updatedCombo = combo.copyWith(
      slots: updatedSlots,
      hasUnsavedChanges: true,
    );
    
    emit(state.copyWith(
      editingCombo: updatedCombo,
      validationErrors: updatedCombo.validationErrors,
      unsavedChangesCount: state.unsavedChangesCount + 1,
    ));
    
    // Recalculate pricing after slot changes
    add(const RecalculatePricing());
  }

  void _onUpdateComboSlot(UpdateComboSlot event, Emitter<ComboManagementState> emit) {
    final combo = state.editingCombo;
    if (combo == null) return;
    
    final updatedSlots = combo.slots.map((slot) {
      return slot.id == event.slotId ? event.updatedSlot : slot;
    }).toList();
    
    final updatedCombo = combo.copyWith(
      slots: updatedSlots,
      hasUnsavedChanges: true,
    );
    
    emit(state.copyWith(
      editingCombo: updatedCombo,
      validationErrors: updatedCombo.validationErrors,
      unsavedChangesCount: state.unsavedChangesCount + 1,
    ));
    
    // Recalculate pricing after slot changes
    add(const RecalculatePricing());
  }

  void _onRemoveComboSlot(RemoveComboSlot event, Emitter<ComboManagementState> emit) {
    final combo = state.editingCombo;
    if (combo == null) return;
    
    final updatedSlots = combo.slots.where((slot) => slot.id != event.slotId).toList();
    final updatedCombo = combo.copyWith(
      slots: updatedSlots,
      hasUnsavedChanges: true,
    );
    
    emit(state.copyWith(
      editingCombo: updatedCombo,
      validationErrors: updatedCombo.validationErrors,
      unsavedChangesCount: state.unsavedChangesCount + 1,
    ));
    
    // Recalculate pricing after slot changes
    add(const RecalculatePricing());
  }

  void _onReorderComboSlots(ReorderComboSlots event, Emitter<ComboManagementState> emit) {
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
    
    emit(state.copyWith(
      editingCombo: updatedCombo,
      unsavedChangesCount: state.unsavedChangesCount + 1,
    ));
  }

  void _onDuplicateComboSlot(DuplicateComboSlot event, Emitter<ComboManagementState> emit) {
    final combo = state.editingCombo;
    if (combo == null) return;
    
    final originalSlot = combo.slots.firstWhere((slot) => slot.id == event.slotId);
    final duplicatedSlot = originalSlot.copyWith(
      id: _uuid.v4(),
      name: '${originalSlot.name} (Copy)',
      sortOrder: combo.slots.length,
    );
    
    add(AddComboSlot(slot: duplicatedSlot));
  }

  void _onUpdateComboPricing(UpdateComboPricing event, Emitter<ComboManagementState> emit) {
    final combo = state.editingCombo;
    if (combo == null) return;
    
    final updatedCombo = combo.copyWith(
      pricing: event.pricing,
      hasUnsavedChanges: true,
    );
    
    emit(state.copyWith(
      editingCombo: updatedCombo,
      validationErrors: updatedCombo.validationErrors,
      unsavedChangesCount: state.unsavedChangesCount + 1,
    ));
  }

  void _onRecalculatePricing(RecalculatePricing event, Emitter<ComboManagementState> emit) {
    final combo = state.editingCombo;
    if (combo == null) return;
    
    // TODO: Implement pricing recalculation based on slots
    // This would involve calculating totalIfSeparate, finalPrice, and savings
    // based on the current slot configuration and pricing mode
  }

  void _onUpdateComboAvailability(UpdateComboAvailability event, Emitter<ComboManagementState> emit) {
    final combo = state.editingCombo;
    if (combo == null) return;
    
    final updatedCombo = combo.copyWith(
      availability: event.availability,
      hasUnsavedChanges: true,
    );
    
    emit(state.copyWith(
      editingCombo: updatedCombo,
      validationErrors: updatedCombo.validationErrors,
      unsavedChangesCount: state.unsavedChangesCount + 1,
    ));
  }

  void _onUpdateComboLimits(UpdateComboLimits event, Emitter<ComboManagementState> emit) {
    final combo = state.editingCombo;
    if (combo == null) return;
    
    final updatedCombo = combo.copyWith(
      limits: event.limits,
      hasUnsavedChanges: true,
    );
    
    emit(state.copyWith(
      editingCombo: updatedCombo,
      validationErrors: updatedCombo.validationErrors,
      unsavedChangesCount: state.unsavedChangesCount + 1,
    ));
  }

  void _onValidateCurrentCombo(ValidateCurrentCombo event, Emitter<ComboManagementState> emit) {
    final combo = state.editingCombo;
    if (combo == null) return;
    
    emit(state.copyWith(validationErrors: combo.validationErrors));
  }

  void _onMarkAsUnsaved(MarkAsUnsaved event, Emitter<ComboManagementState> emit) {
    emit(state.copyWith(unsavedChangesCount: state.unsavedChangesCount + 1));
  }

  Future<void> _onSaveAllCombos(SaveAllCombos event, Emitter<ComboManagementState> emit) async {
    // TODO: Implement save all functionality
    emit(state.copyWith(unsavedChangesCount: 0));
  }

  void _onDiscardAllUnsavedChanges(DiscardAllUnsavedChanges event, Emitter<ComboManagementState> emit) {
    // TODO: Implement discard all changes functionality
    emit(state.copyWith(unsavedChangesCount: 0));
  }

  void _onSearchCombos(SearchCombos event, Emitter<ComboManagementState> emit) {
    final filteredCombos = _applyFilters(state.combos, searchQuery: event.query);
    emit(state.copyWith(
      searchQuery: event.query,
      filteredCombos: filteredCombos,
    ));
  }

  void _onFilterCombosByStatus(FilterCombosByStatus event, Emitter<ComboManagementState> emit) {
    final filteredCombos = _applyFilters(state.combos, statusFilter: event.status);
    emit(state.copyWith(
      statusFilter: event.status,
      filteredCombos: filteredCombos,
    ));
  }

  void _onFilterCombosByCategory(FilterCombosByCategory event, Emitter<ComboManagementState> emit) {
    final filteredCombos = _applyFilters(state.combos, categoryFilter: event.categoryTag);
    emit(state.copyWith(
      categoryFilter: event.categoryTag,
      filteredCombos: filteredCombos,
    ));
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

  // TODO: Replace these with actual repository calls
  Future<List<ComboEntity>> _loadCombosFromRepository() async {
    // Simulate loading with sample data
    await Future.delayed(const Duration(milliseconds: 500));
    return _getSampleCombos();
  }

  Future<void> _saveComboToRepository(ComboEntity combo) async {
    // Simulate saving
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _deleteComboFromRepository(String comboId) async {
    // Simulate deletion
    await Future.delayed(const Duration(milliseconds: 300));
  }

  List<ComboEntity> _getSampleCombos() {
    final now = DateTime.now();
    return [
      ComboEntity(
        id: '1',
        name: 'Pizza + Chips + Drink Deal',
        description: 'Perfect lunch combo with your choice of pizza slice (Margherita, Pepperoni, or Hawaiian), crispy golden chips, and any cold drink. Available Monday-Friday 11AM-3PM. Great value for a complete meal!',
        categoryTag: 'Lunch Specials',
        pointsReward: 220,
        status: ComboStatus.active,
        slots: _createSampleSlots('pizza-combo'),
        pricing: ComboPricingEntity.fixed(fixedPrice: 22.00, totalIfSeparate: 28.50),
        availability: ComboAvailabilityEntity.lunchOnly(),
        limits: ComboLimitsEntity.onePerOrder(),
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      ComboEntity(
        id: '2',
        name: 'Burger Feast',
        description: 'Double the satisfaction! Two delicious beef burgers (Classic or BBQ), large portion of seasoned fries, and two drinks of your choice. Perfect for sharing or when you\'re extra hungry. Available all day.',
        categoryTag: 'Popular Combos',
        pointsReward: 300,
        status: ComboStatus.active,
        slots: _createSampleSlots('burger-combo'),
        pricing: ComboPricingEntity.fixed(fixedPrice: 29.98, totalIfSeparate: 38.96),
        availability: const ComboAvailabilityEntity(),
        limits: ComboLimitsEntity.noLimits(),
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      ComboEntity(
        id: '3',
        name: 'Weekend Wings Special',
        description: '🔥 WEEKEND ONLY! 12 pieces of our signature buffalo wings with choice of celery sticks or coleslaw, plus a cold beer or soft drink. Choose from Mild, Hot, or BBQ sauce. Limited to 50 orders per day - don\'t miss out!',
        categoryTag: 'Weekend Specials',
        pointsReward: 185,
        status: ComboStatus.active,
        slots: _createSampleSlots('wings-combo'),
        pricing: ComboPricingEntity.fixed(fixedPrice: 18.50, totalIfSeparate: 25.50),
        availability: ComboAvailabilityEntity.weekendSpecial(),
        limits: ComboLimitsEntity.limitedDaily(maxPerDay: 50, maxPerOrder: 2),
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
    ];
  }
  
  List<ComboSlotEntity> _createSampleSlots(String comboType) {
    switch (comboType) {
      case 'pizza-combo':
        return [
          ComboSlotEntity(
            id: '1',
            name: 'Pizza Slice',
            required: true,
            defaultIncluded: true,
            sortOrder: 0,
            sourceType: SlotSourceType.specific,
            specificItemIds: ['pizza1', 'pizza2', 'pizza3'],
            specificItemNames: ['Margherita', 'Pepperoni', 'Hawaiian'],
            defaultPrice: 12.50,
            maxQuantity: 1,
          ),
          ComboSlotEntity(
            id: '2',
            name: 'Chips',
            required: true,
            defaultIncluded: true,
            sortOrder: 1,
            sourceType: SlotSourceType.specific,
            specificItemIds: ['chips1'],
            specificItemNames: ['Regular Chips'],
            defaultPrice: 6.50,
            maxQuantity: 1,
          ),
          ComboSlotEntity(
            id: '3',
            name: 'Drink',
            required: true,
            defaultIncluded: true,
            sortOrder: 2,
            sourceType: SlotSourceType.category,
            categoryId: 'drinks',
            categoryName: 'Cold Drinks',
            defaultPrice: 4.50,
            maxQuantity: 1,
          ),
        ];
        
      case 'burger-combo':
        return [
          ComboSlotEntity(
            id: '4',
            name: 'Burgers (2)',
            required: true,
            defaultIncluded: true,
            sortOrder: 0,
            sourceType: SlotSourceType.specific,
            specificItemIds: ['burger1', 'burger2'],
            specificItemNames: ['Classic Beef Burger', 'BBQ Burger'],
            defaultPrice: 26.96,
            maxQuantity: 2,
          ),
          ComboSlotEntity(
            id: '5',
            name: 'Large Fries',
            required: true,
            defaultIncluded: true,
            sortOrder: 1,
            sourceType: SlotSourceType.specific,
            specificItemIds: ['fries1'],
            specificItemNames: ['Large Fries'],
            defaultPrice: 7.50,
            maxQuantity: 1,
          ),
          ComboSlotEntity(
            id: '6',
            name: 'Drinks (2)',
            required: true,
            defaultIncluded: true,
            sortOrder: 2,
            sourceType: SlotSourceType.category,
            categoryId: 'drinks',
            categoryName: 'Drinks',
            defaultPrice: 9.00,
            maxQuantity: 2,
          ),
        ];
        
      case 'wings-combo':
        return [
          ComboSlotEntity(
            id: '7',
            name: 'Buffalo Wings (12)',
            required: true,
            defaultIncluded: true,
            sortOrder: 0,
            sourceType: SlotSourceType.specific,
            specificItemIds: ['wings1'],
            specificItemNames: ['Buffalo Wings (12 pieces)'],
            defaultPrice: 16.50,
            maxQuantity: 1,
          ),
          ComboSlotEntity(
            id: '8',
            name: 'Side',
            required: true,
            defaultIncluded: true,
            sortOrder: 1,
            sourceType: SlotSourceType.specific,
            specificItemIds: ['celery1', 'coleslaw1'],
            specificItemNames: ['Celery Sticks', 'Coleslaw'],
            defaultPrice: 4.50,
            maxQuantity: 1,
          ),
          ComboSlotEntity(
            id: '9',
            name: 'Drink',
            required: true,
            defaultIncluded: true,
            sortOrder: 2,
            sourceType: SlotSourceType.category,
            categoryId: 'drinks',
            categoryName: 'Beverages',
            defaultPrice: 4.50,
            maxQuantity: 1,
          ),
        ];
        
      default:
        return [];
    }
  }
}
