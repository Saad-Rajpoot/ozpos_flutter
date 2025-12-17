import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/combo_entity.dart';

/// State for debug combo button
class DebugComboButtonState {
  const DebugComboButtonState({
    required this.isHovering,
    this.savedCombo,
  });

  final bool isHovering;
  final ComboEntity? savedCombo;

  DebugComboButtonState copyWith({
    bool? isHovering,
    ComboEntity? savedCombo,
    bool shouldUpdateSavedCombo = false,
  }) {
    return DebugComboButtonState(
      isHovering: isHovering ?? this.isHovering,
      savedCombo: shouldUpdateSavedCombo ? savedCombo : this.savedCombo,
    );
  }
}

/// Cubit for managing debug combo button state
class DebugComboButtonCubit extends Cubit<DebugComboButtonState> {
  DebugComboButtonCubit()
      : super(const DebugComboButtonState(isHovering: false));

  void setHovering(bool value) {
    emit(state.copyWith(isHovering: value));
  }

  void updateSavedCombo(ComboEntity? combo) {
    emit(
      state.copyWith(
        savedCombo: combo,
        shouldUpdateSavedCombo: true,
      ),
    );
  }
}

/// State for debug dialog
class DebugDialogState {
  const DebugDialogState({this.savedCombo});

  final ComboEntity? savedCombo;

  DebugDialogState copyWith({
    ComboEntity? savedCombo,
    bool shouldUpdateSavedCombo = false,
  }) {
    return DebugDialogState(
      savedCombo: shouldUpdateSavedCombo ? savedCombo : this.savedCombo,
    );
  }
}

/// Cubit for managing debug dialog state
class DebugDialogCubit extends Cubit<DebugDialogState> {
  DebugDialogCubit(ComboEntity? initialSavedCombo)
      : super(DebugDialogState(savedCombo: initialSavedCombo));

  void updateSavedCombo(ComboEntity? combo) {
    emit(
      state.copyWith(
        savedCombo: combo,
        shouldUpdateSavedCombo: true,
      ),
    );
  }
}
