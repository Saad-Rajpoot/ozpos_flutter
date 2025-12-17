import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ozpos_flutter/features/tables/domain/entities/table_entity.dart';
import '../../../checkout/presentation/bloc/cart_bloc.dart';
import '../../data/datasources/table_mock_datasource.dart';
import '../../data/datasources/table_data_source.dart';

enum TableViewMode { list, floor }

/// Table Selection Modal with List and Floor views
class TableSelectionModal extends StatefulWidget {
  const TableSelectionModal({super.key});

  @override
  State<TableSelectionModal> createState() => _TableSelectionModalState();
}

class _TableSelectionModalState extends State<TableSelectionModal> {
  late final TableSelectionViewCubit _viewCubit;

  @override
  void initState() {
    super.initState();
    _viewCubit = TableSelectionViewCubit(TableMockDataSourceImpl())
      ..loadTables();
  }

  @override
  void dispose() {
    _viewCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _viewCubit,
      child: BlocBuilder<TableSelectionViewCubit, TableSelectionViewState>(
        builder: (context, state) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 800,
              height: 700,
              padding: const EdgeInsets.all(24),
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? _buildErrorState(state.error!, context)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context, state),
                            const SizedBox(height: 20),
                            _buildSearchAndFilters(context, state),
                            const SizedBox(height: 16),
                            _buildStatusFilters(context, state),
                            const SizedBox(height: 20),
                            Expanded(
                              child: state.viewMode == TableViewMode.list
                                  ? _buildListView(context, state)
                                  : _buildFloorView(context, state),
                            ),
                            const SizedBox(height: 20),
                            _buildFooter(context, state),
                          ],
                        ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 56, color: Colors.red.shade400),
          const SizedBox(height: 12),
          Text(
            'Failed to load tables',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<TableSelectionViewCubit>().loadTables(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader(
    BuildContext context,
    TableSelectionViewState state,
  ) {
    return Row(
      children: [
        const Text(
          'Select Table',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const Spacer(),

        // View toggle
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _ViewToggleButton(
                icon: Icons.list,
                isSelected: state.viewMode == TableViewMode.list,
                onTap: () => context
                    .read<TableSelectionViewCubit>()
                    .setViewMode(TableViewMode.list),
              ),
              _ViewToggleButton(
                icon: Icons.grid_view,
                isSelected: state.viewMode == TableViewMode.floor,
                onTap: () => context
                    .read<TableSelectionViewCubit>()
                    .setViewMode(TableViewMode.floor),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Close button
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, size: 24),
          color: const Color(0xFF6B7280),
        ),
      ],
    );
  }

  // ==========================================================================
  // SEARCH AND FILTERS
  // ==========================================================================

  Widget _buildSearchAndFilters(
    BuildContext context,
    TableSelectionViewState state,
  ) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by table number or server...',
        prefixIcon: const Icon(Icons.search, size: 20),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
      ),
      onChanged: (value) =>
          context.read<TableSelectionViewCubit>().updateSearchQuery(value),
    );
  }

  Widget _buildStatusFilters(
    BuildContext context,
    TableSelectionViewState state,
  ) {
    return Wrap(
      spacing: 8,
      children: [
        _StatusChip(
          label: 'All',
          isSelected: state.filterStatus == null,
          onTap: () =>
              context.read<TableSelectionViewCubit>().setFilterStatus(null),
        ),
        _StatusChip(
          label: 'Available',
          color: const Color(0xFF10B981),
          isSelected: state.filterStatus == TableStatus.available,
          onTap: () => context
              .read<TableSelectionViewCubit>()
              .setFilterStatus(TableStatus.available),
        ),
        _StatusChip(
          label: 'Occupied',
          color: const Color(0xFFEF4444),
          isSelected: state.filterStatus == TableStatus.occupied,
          onTap: () => context
              .read<TableSelectionViewCubit>()
              .setFilterStatus(TableStatus.occupied),
        ),
        _StatusChip(
          label: 'Reserved',
          color: const Color(0xFF3B82F6),
          isSelected: state.filterStatus == TableStatus.reserved,
          onTap: () => context
              .read<TableSelectionViewCubit>()
              .setFilterStatus(TableStatus.reserved),
        ),
        _StatusChip(
          label: 'Cleaning',
          color: const Color(0xFFF59E0B),
          isSelected: state.filterStatus == TableStatus.cleaning,
          onTap: () => context
              .read<TableSelectionViewCubit>()
              .setFilterStatus(TableStatus.cleaning),
        ),
      ],
    );
  }

  // ==========================================================================
  // LIST VIEW
  // ==========================================================================

  Widget _buildListView(
    BuildContext context,
    TableSelectionViewState state,
  ) {
    final tables = state.filteredTables;

    if (tables.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      itemCount: tables.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final table = tables[index];
        return _TableListCard(
          table: table,
          isSelected: state.selectedTable?.id == table.id,
          onTap: () =>
              context.read<TableSelectionViewCubit>().selectTable(table),
        );
      },
    );
  }

  // ==========================================================================
  // FLOOR VIEW
  // ==========================================================================

  Widget _buildFloorView(
    BuildContext context,
    TableSelectionViewState state,
  ) {
    final tables = state.filteredTables;

    if (tables.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildLegend(),
        const SizedBox(height: 16),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: 100,
                itemBuilder: (context, index) {
                  final x = index % 10;
                  final y = index ~/ 10;

                  final table = tables.firstWhere(
                    (t) => t.floorX == x && t.floorY == y,
                    orElse: () => TableEntity(
                      id: '',
                      number: '',
                      seats: 0,
                      status: TableStatus.available,
                      floorX: null,
                      floorY: null,
                    ),
                  );

                  if (table.id.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return _FloorTableNode(
                    table: table,
                    isSelected: state.selectedTable?.id == table.id,
                    onTap: () =>
                        context.read<TableSelectionViewCubit>().selectTable(table),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: const Color(0xFF10B981), label: 'Available'),
        const SizedBox(width: 16),
        _LegendItem(color: const Color(0xFFEF4444), label: 'Occupied'),
        const SizedBox(width: 16),
        _LegendItem(color: const Color(0xFF3B82F6), label: 'Reserved'),
        const SizedBox(width: 16),
        _LegendItem(color: const Color(0xFFF59E0B), label: 'Cleaning'),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.table_bar, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No tables found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // FOOTER
  // ==========================================================================

  Widget _buildFooter(
    BuildContext context,
    TableSelectionViewState state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: state.selectedTable != null
              ? () {
                  context.read<CartBloc>().add(
                        SelectTable(table: state.selectedTable!),
                      );
                  Navigator.pop(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFE5E7EB),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Assign Table',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// VIEW TOGGLE BUTTON
// ============================================================================

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? const Color(0xFF111827) : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

// ============================================================================
// STATUS CHIP
// ============================================================================

class _StatusChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? const Color(0xFF111827))
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? const Color(0xFF111827))
                : const Color(0xFFD1D5DB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TABLE LIST CARD
// ============================================================================

class _TableListCard extends StatelessWidget {
  final TableEntity table;
  final bool isSelected;
  final VoidCallback onTap;

  const _TableListCard({
    required this.table,
    required this.isSelected,
    required this.onTap,
  });

  Color get _statusColor {
    switch (table.status) {
      case TableStatus.available:
        return const Color(0xFF10B981);
      case TableStatus.occupied:
        return const Color(0xFFEF4444);
      case TableStatus.reserved:
        return const Color(0xFF3B82F6);
      case TableStatus.cleaning:
        return const Color(0xFFF59E0B);
    }
  }

  String get _statusLabel {
    switch (table.status) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.cleaning:
        return 'Cleaning';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color:
                isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Table icon and number
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.table_bar, color: _statusColor, size: 24),
                  const SizedBox(height: 2),
                  Text(
                    table.number,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Table ${table.number}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${table.seats} seats',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  if (table.serverName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Server: ${table.serverName}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Radio button
            Radio<bool>(
              value: true,
              // ignore: deprecated_member_use
              groupValue: true,
              // ignore: deprecated_member_use
              onChanged: isSelected ? null : (_) => onTap(),
              activeColor: const Color(0xFF3B82F6),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// FLOOR TABLE NODE
// ============================================================================

class _FloorTableNode extends StatelessWidget {
  final TableEntity table;
  final bool isSelected;
  final VoidCallback onTap;

  const _FloorTableNode({
    required this.table,
    required this.isSelected,
    required this.onTap,
  });

  Color get _statusColor {
    switch (table.status) {
      case TableStatus.available:
        return const Color(0xFF10B981);
      case TableStatus.occupied:
        return const Color(0xFFEF4444);
      case TableStatus.reserved:
        return const Color(0xFF3B82F6);
      case TableStatus.cleaning:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? _statusColor : _statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: _statusColor, width: isSelected ? 3 : 2),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _statusColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              table.number,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : _statusColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LEGEND ITEM
// ============================================================================

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

class TableSelectionViewState extends Equatable {
  const TableSelectionViewState({
    this.viewMode = TableViewMode.list,
    this.filterStatus,
    this.searchQuery = '',
    this.selectedTable,
    this.tables = const [],
    this.isLoading = true,
    this.error,
  });

  final TableViewMode viewMode;
  final TableStatus? filterStatus;
  final String searchQuery;
  final TableEntity? selectedTable;
  final List<TableEntity> tables;
  final bool isLoading;
  final String? error;

  List<TableEntity> get filteredTables {
    return tables.where((table) {
      if (filterStatus != null && table.status != filterStatus) return false;

      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return table.number.toLowerCase().contains(query) ||
            (table.serverName?.toLowerCase().contains(query) ?? false) ||
            (table.orderId?.toLowerCase().contains(query) ?? false);
      }

      return true;
    }).toList();
  }

  TableSelectionViewState copyWith({
    TableViewMode? viewMode,
    TableStatus? filterStatus,
    bool setFilterStatusToNull = false,
    String? searchQuery,
    TableEntity? selectedTable,
    bool setSelectedTableToNull = false,
    List<TableEntity>? tables,
    bool? isLoading,
    String? error,
    bool setErrorToNull = false,
  }) {
    return TableSelectionViewState(
      viewMode: viewMode ?? this.viewMode,
      filterStatus:
          setFilterStatusToNull ? null : (filterStatus ?? this.filterStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTable: setSelectedTableToNull
          ? null
          : (selectedTable ?? this.selectedTable),
      tables: tables ?? this.tables,
      isLoading: isLoading ?? this.isLoading,
      error: setErrorToNull ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        viewMode,
        filterStatus,
        searchQuery,
        selectedTable,
        tables,
        isLoading,
        error,
      ];
}

class TableSelectionViewCubit extends Cubit<TableSelectionViewState> {
  TableSelectionViewCubit(this._dataSource)
      : super(const TableSelectionViewState());

  final TableDataSource _dataSource;

  Future<void> loadTables() async {
    emit(state.copyWith(isLoading: true, setErrorToNull: true));
    try {
      final tables = await _dataSource.getTables();
      emit(state.copyWith(
        tables: List.unmodifiable(tables),
        isLoading: false,
        setSelectedTableToNull: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        error: error.toString(),
      ));
    }
  }

  void setViewMode(TableViewMode mode) {
    emit(state.copyWith(viewMode: mode));
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setFilterStatus(TableStatus? status) {
    if (status == null) {
      emit(state.copyWith(setFilterStatusToNull: true));
    } else {
      emit(state.copyWith(filterStatus: status));
    }
  }

  void selectTable(TableEntity table) {
    emit(state.copyWith(selectedTable: table));
  }

  void clearSelectedTable() {
    emit(state.copyWith(setSelectedTableToNull: true));
  }
}
