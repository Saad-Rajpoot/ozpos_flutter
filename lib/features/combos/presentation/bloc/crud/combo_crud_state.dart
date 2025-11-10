import '../../../../../core/base/base_bloc.dart';
import '../../../domain/entities/combo_entity.dart';

enum ComboLoadingStatus { initial, loading, loaded, error }

class ComboCrudState extends BaseState {
  final ComboLoadingStatus status;
  final List<ComboEntity> combos;
  final String? errorMessage;
  final bool isSaving;
  final String? saveError;
  final ComboEntity? lastSavedCombo;

  const ComboCrudState({
    this.status = ComboLoadingStatus.initial,
    this.combos = const [],
    this.errorMessage,
    this.isSaving = false,
    this.saveError,
    this.lastSavedCombo,
  });

  bool get isLoading => status == ComboLoadingStatus.loading;
  bool get hasError => status == ComboLoadingStatus.error || saveError != null;
  bool get hasData => status == ComboLoadingStatus.loaded;

  ComboCrudState copyWith({
    ComboLoadingStatus? status,
    List<ComboEntity>? combos,
    String? errorMessage,
    bool? isSaving,
    String? saveError,
    ComboEntity? lastSavedCombo,
    bool resetLastSavedCombo = false,
  }) {
    return ComboCrudState(
      status: status ?? this.status,
      combos: combos ?? this.combos,
      errorMessage: errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
      saveError: saveError ?? this.saveError,
      lastSavedCombo:
          resetLastSavedCombo ? null : lastSavedCombo ?? this.lastSavedCombo,
    );
  }

  ComboEntity? getComboById(String id) {
    try {
      return combos.firstWhere((combo) => combo.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        status,
        combos,
        errorMessage,
        isSaving,
        saveError,
        lastSavedCombo,
      ];
}


