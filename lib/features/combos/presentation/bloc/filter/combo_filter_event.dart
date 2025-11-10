import '../../../../../core/base/base_bloc.dart';
import '../../../domain/entities/combo_entity.dart';

abstract class ComboFilterEvent extends BaseEvent {
  const ComboFilterEvent();
}

class ComboFilterCombosSynced extends ComboFilterEvent {
  final List<ComboEntity> combos;

  const ComboFilterCombosSynced({required this.combos});

  @override
  List<Object?> get props => [combos];
}

class ComboFilterSearchChanged extends ComboFilterEvent {
  final String query;

  const ComboFilterSearchChanged({required this.query});

  @override
  List<Object?> get props => [query];
}

class ComboFilterStatusChanged extends ComboFilterEvent {
  final ComboStatus? status;

  const ComboFilterStatusChanged({this.status});

  @override
  List<Object?> get props => [status];
}

class ComboFilterCategoryChanged extends ComboFilterEvent {
  final String? categoryTag;

  const ComboFilterCategoryChanged({this.categoryTag});

  @override
  List<Object?> get props => [categoryTag];
}

class ComboFilterCleared extends ComboFilterEvent {
  const ComboFilterCleared();
}
