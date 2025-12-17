import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/base/base_bloc.dart';
import '../../../domain/entities/combo_entity.dart';
import '../crud/combo_crud_bloc.dart';
import '../crud/combo_crud_state.dart';
import 'combo_filter_event.dart';
import 'combo_filter_state.dart';

class ComboFilterBloc
    extends BaseBloc<ComboFilterEvent, ComboFilterState> {
  final ComboCrudBloc _crudBloc;
  late final StreamSubscription<ComboCrudState> _crudSubscription;

  ComboFilterBloc({required ComboCrudBloc crudBloc})
      : _crudBloc = crudBloc,
        super(const ComboFilterState()) {
    on<ComboFilterCombosSynced>(_onCombosSynced);
    on<ComboFilterSearchChanged>(_onSearchChanged);
    on<ComboFilterStatusChanged>(_onStatusChanged);
    on<ComboFilterCategoryChanged>(_onCategoryChanged);
    on<ComboFilterCleared>(_onFiltersCleared);

    _crudSubscription = _crudBloc.stream.listen((state) {
      add(ComboFilterCombosSynced(combos: state.combos));
    });

    add(ComboFilterCombosSynced(combos: _crudBloc.state.combos));
  }

  void _onCombosSynced(
    ComboFilterCombosSynced event,
    Emitter<ComboFilterState> emit,
  ) {
    final filtered = _applyFilters(
      event.combos,
      searchQuery: state.searchQuery,
      statusFilter: state.statusFilter,
      categoryFilter: state.categoryFilter,
    );

    emit(state.copyWith(
      allCombos: event.combos,
      filteredCombos: filtered,
    ));
  }

  void _onSearchChanged(
    ComboFilterSearchChanged event,
    Emitter<ComboFilterState> emit,
  ) {
    final filtered = _applyFilters(
      state.allCombos,
      searchQuery: event.query,
      statusFilter: state.statusFilter,
      categoryFilter: state.categoryFilter,
    );

    emit(state.copyWith(
      searchQuery: event.query,
      filteredCombos: filtered,
    ));
  }

  void _onStatusChanged(
    ComboFilterStatusChanged event,
    Emitter<ComboFilterState> emit,
  ) {
    final filtered = _applyFilters(
      state.allCombos,
      searchQuery: state.searchQuery,
      statusFilter: event.status,
      categoryFilter: state.categoryFilter,
    );

    emit(state.copyWith(
      statusFilter: event.status,
      filteredCombos: filtered,
    ));
  }

  void _onCategoryChanged(
    ComboFilterCategoryChanged event,
    Emitter<ComboFilterState> emit,
  ) {
    final filtered = _applyFilters(
      state.allCombos,
      searchQuery: state.searchQuery,
      statusFilter: state.statusFilter,
      categoryFilter: event.categoryTag,
    );

    emit(state.copyWith(
      categoryFilter: event.categoryTag,
      filteredCombos: filtered,
    ));
  }

  void _onFiltersCleared(
    ComboFilterCleared event,
    Emitter<ComboFilterState> emit,
  ) {
    final filtered = _applyFilters(state.allCombos);
    emit(state.clearFilters().copyWith(filteredCombos: filtered));
  }

  List<ComboEntity> _applyFilters(
    List<ComboEntity> combos, {
    String? searchQuery,
    ComboStatus? statusFilter,
    String? categoryFilter,
  }) {
    final query = searchQuery ?? '';
    final status = statusFilter;
    final category = categoryFilter;

    var filtered = combos.where((combo) {
      if (query.isNotEmpty) {
        final searchLower = query.toLowerCase();
        if (!combo.name.toLowerCase().contains(searchLower) &&
            !combo.description.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      if (status != null && combo.status != status) {
        return false;
      }

      if (category != null && combo.categoryTag != category) {
        return false;
      }

      return true;
    }).toList();

    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return filtered;
  }

  @override
  Future<void> close() async {
    await _crudSubscription.cancel();
    await super.close();
  }
}


