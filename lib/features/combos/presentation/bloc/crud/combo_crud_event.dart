import '../../../../../core/base/base_bloc.dart';
import '../../../domain/entities/combo_entity.dart';

abstract class ComboCrudEvent extends BaseEvent {
  const ComboCrudEvent();
}

class CombosRequested extends ComboCrudEvent {
  const CombosRequested();
}

class CombosRefreshed extends ComboCrudEvent {
  const CombosRefreshed();
}

class ComboCreated extends ComboCrudEvent {
  final ComboEntity combo;

  const ComboCreated({required this.combo});

  @override
  List<Object?> get props => [combo];
}

class ComboUpdated extends ComboCrudEvent {
  final ComboEntity combo;

  const ComboUpdated({required this.combo});

  @override
  List<Object?> get props => [combo];
}

class ComboDeleted extends ComboCrudEvent {
  final String comboId;

  const ComboDeleted({required this.comboId});

  @override
  List<Object?> get props => [comboId];
}

class ComboDuplicated extends ComboCrudEvent {
  final String comboId;
  final String? newName;

  const ComboDuplicated({required this.comboId, this.newName});

  @override
  List<Object?> get props => [comboId, newName];
}

class ComboVisibilityToggled extends ComboCrudEvent {
  final String comboId;
  final ComboStatus newStatus;

  const ComboVisibilityToggled({
    required this.comboId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [comboId, newStatus];
}


