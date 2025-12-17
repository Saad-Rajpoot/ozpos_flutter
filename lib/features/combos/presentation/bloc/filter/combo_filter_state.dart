import '../../../../../core/base/base_bloc.dart';
import '../../../domain/entities/combo_entity.dart';

class ComboFilterState extends BaseState {
  final List<ComboEntity> allCombos;
  final List<ComboEntity> filteredCombos;
  final String searchQuery;
  final ComboStatus? statusFilter;
  final String? categoryFilter;

  const ComboFilterState({
    this.allCombos = const [],
    this.filteredCombos = const [],
    this.searchQuery = '',
    this.statusFilter,
    this.categoryFilter,
  });

  bool get isEmpty => filteredCombos.isEmpty && allCombos.isNotEmpty;

  List<String> get availableCategories {
    final categories = allCombos
        .where((combo) => combo.categoryTag != null)
        .map((combo) => combo.categoryTag!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  ComboFilterState copyWith({
    List<ComboEntity>? allCombos,
    List<ComboEntity>? filteredCombos,
    String? searchQuery,
    ComboStatus? statusFilter,
    String? categoryFilter,
  }) {
    return ComboFilterState(
      allCombos: allCombos ?? this.allCombos,
      filteredCombos: filteredCombos ?? this.filteredCombos,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
    );
  }

  ComboFilterState clearFilters() {
    return copyWith(
      searchQuery: '',
      statusFilter: null,
      categoryFilter: null,
    );
  }

  @override
  List<Object?> get props => [
        allCombos,
        filteredCombos,
        searchQuery,
        statusFilter,
        categoryFilter,
      ];
}


