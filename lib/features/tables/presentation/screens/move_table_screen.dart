import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../bloc/table_management_bloc.dart';
import '../bloc/table_management_event.dart';
import '../bloc/table_management_state.dart';
import '../../domain/entities/table_types.dart';

class MoveTableScreen extends StatefulWidget {
  final TableData sourceTable;

  const MoveTableScreen({super.key, required this.sourceTable});

  @override
  State<MoveTableScreen> createState() => _MoveTableScreenState();
}

class _MoveTableScreenViewState extends Equatable {
  const _MoveTableScreenViewState({
    this.searchQuery = '',
    this.filterArea,
    this.selectedDestination,
    this.availableTables = const [],
  });

  final String searchQuery;
  final TableArea? filterArea;
  final TableData? selectedDestination;
  final List<TableData> availableTables;

  _MoveTableScreenViewState copyWith({
    String? searchQuery,
    TableArea? filterArea,
    bool clearFilterArea = false,
    TableData? selectedDestination,
    bool clearSelectedDestination = false,
    List<TableData>? availableTables,
  }) {
    return _MoveTableScreenViewState(
      searchQuery: searchQuery ?? this.searchQuery,
      filterArea: clearFilterArea ? null : (filterArea ?? this.filterArea),
      selectedDestination: clearSelectedDestination
          ? null
          : (selectedDestination ?? this.selectedDestination),
      availableTables:
          availableTables ?? List<TableData>.from(this.availableTables),
    );
  }

  @override
  List<Object?> get props => [
        searchQuery,
        filterArea,
        selectedDestination,
        availableTables,
      ];
}

class _MoveTableScreenState extends State<MoveTableScreen> {
  late final ValueNotifier<_MoveTableScreenViewState> _viewNotifier;

  @override
  void initState() {
    super.initState();
    _viewNotifier = ValueNotifier(const _MoveTableScreenViewState());
  }

  @override
  void dispose() {
    _viewNotifier.dispose();
    super.dispose();
  }

  _MoveTableScreenViewState get _viewState => _viewNotifier.value;

  void _updateViewState(_MoveTableScreenViewState newState) {
    _viewNotifier.value = newState;
  }

  List<TableData> get _filteredTables {
    return _viewState.availableTables.where((table) {
      // Don't show source table
      if (table.number == widget.sourceTable.number) return false;

      // Area filter
      if (_viewState.filterArea != null &&
          table.area != _viewState.filterArea) {
        return false;
      }

      // Search filter
      if (_viewState.searchQuery.isNotEmpty) {
        final query = _viewState.searchQuery.toLowerCase();
        return table.number.toString().contains(query) ||
            (table.serverTag?.toLowerCase().contains(query) ?? false);
      }

      return true;
    }).toList();
  }

  bool _canSelectTable(TableData table) {
    return table.status == TableStatus.available;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_MoveTableScreenViewState>(
      valueListenable: _viewNotifier,
      builder: (context, viewState, _) {
        final canConfirm = viewState.selectedDestination != null &&
            _canSelectTable(viewState.selectedDestination!);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F7),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: const [
                Icon(Icons.swap_horiz, size: 20),
                SizedBox(width: 8),
                Text(
                  'Move Table',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              _buildSourceTableCard(),
              _buildFiltersRow(viewState),
              _buildInstructionBanner(),
              Expanded(child: _buildDestinationGrid(viewState)),
              _buildBottomActions(viewState, canConfirm),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourceTableCard() {
    return Container(
      color: const Color(0xFFEFF6FF),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Moving From:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3B82F6)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Table ${widget.sourceTable.number}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.sourceTable.area
                                .toString()
                                .split('.')
                                .last
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.sourceTable.guests} guests',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${widget.sourceTable.amount?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    Text(
                      'Order ${widget.sourceTable.orderId}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    Text(
                      widget.sourceTable.elapsedTime != null
                          ? '${widget.sourceTable.elapsedTime!.inMinutes.toString().padLeft(2, '0')}:${(widget.sourceTable.elapsedTime!.inSeconds % 60).toString().padLeft(2, '0')}'
                          : '00:00',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow(_MoveTableScreenViewState viewState) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => _updateViewState(
                viewState.copyWith(searchQuery: value),
              ),
              decoration: InputDecoration(
                hintText: 'Search by table number...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<TableArea?>(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    viewState.filterArea == null
                        ? 'All Areas'
                        : viewState.filterArea!.toString().split('.').last,
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
            ),
            onSelected: (area) => _updateViewState(
              viewState.copyWith(filterArea: area),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All Areas')),
              ...TableArea.values.map(
                (area) => PopupMenuItem(
                  value: area,
                  child: Text(area.toString().split('.').last),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionBanner() {
    return Container(
      color: const Color(0xFFFFF7ED),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: const [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Color(0xFFF97316),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Select a destination table below. The entire order will be transferred including all items, guests, and payment status.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF78350F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationGrid(_MoveTableScreenViewState viewState) {
    return BlocBuilder<TableManagementBloc, TableManagementState>(
      builder: (context, state) {
        if (state is TableManagementLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TableManagementError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.message}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<TableManagementBloc>().add(
                          const LoadMoveAvailableTablesEvent(),
                        );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is TableManagementLoaded) {
          final mappedTables = state.tables
              .map((entity) => TableData.fromEntity(entity))
              .toList();
          if (!listEquals(viewState.availableTables, mappedTables)) {
            _updateViewState(
              viewState.copyWith(availableTables: mappedTables),
            );
          }

          if (_filteredTables.isEmpty) {
            return const Center(
              child: Text(
                'No available tables found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _filteredTables.length,
            itemBuilder: (context, index) {
              final table = _filteredTables[index];
              return _buildDestinationCard(viewState, table);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomActions(
    _MoveTableScreenViewState viewState,
    bool canConfirm,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: canConfirm ? () => _confirmMove(viewState) : null,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Confirm Move'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              disabledBackgroundColor: const Color(0xFFE5E7EB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(
    _MoveTableScreenViewState viewState,
    TableData table,
  ) {
    final isSelected = viewState.selectedDestination?.number == table.number;
    final canSelect = _canSelectTable(table);
    Color cardColor;

    switch (table.status) {
      case TableStatus.available:
        cardColor = const Color(0xFF10B981);
        break;
      case TableStatus.occupied:
        cardColor = const Color(0xFFF97316);
        break;
      case TableStatus.reserved:
        cardColor = const Color(0xFF3B82F6);
        break;
      case TableStatus.cleaning:
        cardColor = const Color(0xFF9CA3AF);
        break;
    }

    return InkWell(
      onTap: canSelect
          ? () => _updateViewState(
                viewState.copyWith(selectedDestination: table),
              )
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: canSelect ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? cardColor : cardColor.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Table ${table.number}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cardColor,
                    ),
                  ),
                  const Spacer(),
                  if (canSelect)
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: cardColor,
                    )
                  else
                    Icon(Icons.block, size: 18, color: cardColor),
                ],
              ),
              const Spacer(),
              Text(
                table.status.toString().split('.').last.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cardColor,
                ),
              ),
              if (table.amount != null) ...[
                const SizedBox(height: 4),
                Text(
                  '\$${table.amount!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cardColor,
                  ),
                ),
              ],
              if (table.guests != null)
                Text(
                  '${table.guests} guests',
                  style: TextStyle(
                    fontSize: 11,
                    color: cardColor.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmMove(_MoveTableScreenViewState viewState) {
    final destination = viewState.selectedDestination;
    if (destination == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Moving Table ${widget.sourceTable.number} to Table ${destination.number}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }
}
