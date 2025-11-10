import '../../../../../core/base/base_bloc.dart';
import '../../../domain/entities/combo_entity.dart';

enum ComboEditMode { none, create, edit }

class ComboEditorState extends BaseState {
  final ComboEditMode mode;
  final ComboEntity? draft;
  final bool isBuilderOpen;
  final String selectedTab;
  final List<String> validationErrors;
  final int unsavedChangesCount;
  final bool isAwaitingSave;
  final String? saveError;

  const ComboEditorState({
    this.mode = ComboEditMode.none,
    this.draft,
    this.isBuilderOpen = false,
    this.selectedTab = 'details',
    this.validationErrors = const [],
    this.unsavedChangesCount = 0,
    this.isAwaitingSave = false,
    this.saveError,
  });

  bool get isEditing => mode != ComboEditMode.none;
  bool get isCreating => mode == ComboEditMode.create;
  bool get canSave => draft != null && validationErrors.isEmpty && !isAwaitingSave;
  bool get hasUnsavedChanges => unsavedChangesCount > 0;

  ComboEditorState copyWith({
    ComboEditMode? mode,
    ComboEntity? draft,
    bool? isBuilderOpen,
    String? selectedTab,
    List<String>? validationErrors,
    int? unsavedChangesCount,
    bool? isAwaitingSave,
    String? saveError,
  }) {
    return ComboEditorState(
      mode: mode ?? this.mode,
      draft: draft ?? this.draft,
      isBuilderOpen: isBuilderOpen ?? this.isBuilderOpen,
      selectedTab: selectedTab ?? this.selectedTab,
      validationErrors: validationErrors ?? this.validationErrors,
      unsavedChangesCount: unsavedChangesCount ?? this.unsavedChangesCount,
      isAwaitingSave: isAwaitingSave ?? this.isAwaitingSave,
      saveError: saveError ?? this.saveError,
    );
  }

  ComboEditorState exitEditMode() {
    return const ComboEditorState();
  }

  @override
  List<Object?> get props => [
        mode,
        draft,
        isBuilderOpen,
        selectedTab,
        validationErrors,
        unsavedChangesCount,
        isAwaitingSave,
        saveError,
      ];
}


