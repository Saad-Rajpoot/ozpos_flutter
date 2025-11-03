import 'package:equatable/equatable.dart';
import '../../domain/entities/combo_entity.dart';

enum ComboLoadingStatus { initial, loading, loaded, error }

enum ComboEditMode { none, create, edit }

class ComboManagementState extends Equatable {
  final ComboLoadingStatus status;
  final List<ComboEntity> combos;
  final List<ComboEntity> filteredCombos;
  final String? errorMessage;

  // Editing state
  final ComboEditMode editMode;
  final ComboEntity? editingCombo;
  final int unsavedChangesCount;

  // Filters and search
  final String searchQuery;
  final ComboStatus? statusFilter;
  final String? categoryFilter;

  // UI state
  final bool isBuilderOpen;
  final String?
      selectedTab; // "details", "items", "pricing", "availability", "advanced"
  final List<String> validationErrors;
  final bool isSaving;
  final String? saveError;
  final ComboEntity? lastSavedCombo;

  const ComboManagementState({
    this.status = ComboLoadingStatus.initial,
    this.combos = const [],
    this.filteredCombos = const [],
    this.errorMessage,
    this.editMode = ComboEditMode.none,
    this.editingCombo,
    this.unsavedChangesCount = 0,
    this.searchQuery = '',
    this.statusFilter,
    this.categoryFilter,
    this.isBuilderOpen = false,
    this.selectedTab = 'details',
    this.validationErrors = const [],
    this.isSaving = false,
    this.saveError,
    this.lastSavedCombo,
  });

  // Computed properties

  bool get isLoading => status == ComboLoadingStatus.loading;
  bool get hasError => status == ComboLoadingStatus.error || saveError != null;
  bool get hasData => status == ComboLoadingStatus.loaded;
  bool get isEmpty => hasData && filteredCombos.isEmpty;
  bool get hasUnsavedChanges => unsavedChangesCount > 0;
  bool get isEditing => editMode != ComboEditMode.none;
  bool get isCreating => editMode == ComboEditMode.create;
  bool get canSave =>
      isEditing && editingCombo != null && validationErrors.isEmpty;

  int get totalCombosCount => combos.length;
  int get activeCombosCount =>
      combos.where((c) => c.status == ComboStatus.active).length;
  int get hiddenCombosCount =>
      combos.where((c) => c.status == ComboStatus.hidden).length;
  int get draftCombosCount =>
      combos.where((c) => c.status == ComboStatus.draft).length;

  List<String> get availableCategories {
    final categories = combos
        .where((combo) => combo.categoryTag != null)
        .map((combo) => combo.categoryTag!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  String? get currentErrorMessage => errorMessage ?? saveError;

  ComboEntity? getComboById(String id) {
    try {
      return combos.firstWhere((combo) => combo.id == id);
    } catch (e) {
      return null;
    }
  }

  bool hasComboWithName(String name, {String? excludeId}) {
    return combos.any((combo) =>
        combo.name.toLowerCase() == name.toLowerCase() &&
        combo.id != excludeId);
  }

  ComboManagementState copyWith({
    ComboLoadingStatus? status,
    List<ComboEntity>? combos,
    List<ComboEntity>? filteredCombos,
    String? errorMessage,
    ComboEditMode? editMode,
    ComboEntity? editingCombo,
    int? unsavedChangesCount,
    String? searchQuery,
    ComboStatus? statusFilter,
    String? categoryFilter,
    bool? isBuilderOpen,
    String? selectedTab,
    List<String>? validationErrors,
    bool? isSaving,
    String? saveError,
    ComboEntity? lastSavedCombo,
    bool resetLastSavedCombo = false,
  }) {
    return ComboManagementState(
      status: status ?? this.status,
      combos: combos ?? this.combos,
      filteredCombos: filteredCombos ?? this.filteredCombos,
      errorMessage: errorMessage ?? this.errorMessage,
      editMode: editMode ?? this.editMode,
      editingCombo: editingCombo ?? this.editingCombo,
      unsavedChangesCount: unsavedChangesCount ?? this.unsavedChangesCount,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      isBuilderOpen: isBuilderOpen ?? this.isBuilderOpen,
      selectedTab: selectedTab ?? this.selectedTab,
      validationErrors: validationErrors ?? this.validationErrors,
      isSaving: isSaving ?? this.isSaving,
      saveError: saveError ?? this.saveError,
      lastSavedCombo:
          resetLastSavedCombo ? null : lastSavedCombo ?? this.lastSavedCombo,
    );
  }

  // Null-aware copyWith methods
  ComboManagementState clearError() {
    return copyWith(
      errorMessage: null,
      saveError: null,
    );
  }

  ComboManagementState clearFilters() {
    return copyWith(
      searchQuery: '',
      statusFilter: null,
      categoryFilter: null,
    );
  }

  ComboManagementState exitEditMode() {
    return copyWith(
      editMode: ComboEditMode.none,
      editingCombo: null,
      isBuilderOpen: false,
      selectedTab: 'details',
      validationErrors: [],
      saveError: null,
    );
  }

  ComboManagementState withUpdatedCombo(ComboEntity updatedCombo) {
    final updatedCombos = combos.map((combo) {
      return combo.id == updatedCombo.id ? updatedCombo : combo;
    }).toList();

    return copyWith(
      combos: updatedCombos,
      editingCombo:
          editingCombo?.id == updatedCombo.id ? updatedCombo : editingCombo,
    );
  }

  ComboManagementState withAddedCombo(ComboEntity newCombo) {
    return copyWith(
      combos: [...combos, newCombo],
    );
  }

  ComboManagementState withRemovedCombo(String comboId) {
    final updatedCombos = combos.where((combo) => combo.id != comboId).toList();
    return copyWith(
      combos: updatedCombos,
      editingCombo: editingCombo?.id == comboId ? null : editingCombo,
      editMode: editingCombo?.id == comboId ? ComboEditMode.none : editMode,
      isBuilderOpen: editingCombo?.id == comboId ? false : isBuilderOpen,
    );
  }

  @override
  List<Object?> get props => [
        status,
        combos,
        filteredCombos,
        errorMessage,
        editMode,
        editingCombo,
        unsavedChangesCount,
        searchQuery,
        statusFilter,
        categoryFilter,
        isBuilderOpen,
        selectedTab,
        validationErrors,
        isSaving,
        saveError,
        lastSavedCombo,
      ];
}
