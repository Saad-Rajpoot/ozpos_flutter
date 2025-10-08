import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class _MoveTableScreenState extends State<MoveTableScreen> {
  String _searchQuery = '';
  TableArea? _filterArea;
  TableData? _selectedDestination;
  List<TableData> _availableTables = [];

  List<TableData> get _filteredTables {
    return _availableTables.where((table) {
      // Don't show source table
      if (table.number == widget.sourceTable.number) return false;

      // Area filter
      if (_filterArea != null && table.area != _filterArea) return false;

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
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
    final canConfirm =
        _selectedDestination != null && _canSelectTable(_selectedDestination!);

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
          children: [
            const Icon(Icons.swap_horiz, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Move Table',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Moving From card
          Container(
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
          ),

          // Search and area filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
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
                          _filterArea == null
                              ? 'All Areas'
                              : _filterArea.toString().split('.').last,
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 16),
                      ],
                    ),
                  ),
                  onSelected: (area) => setState(() => _filterArea = area),
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
          ),

          // Instruction banner
          Container(
            color: const Color(0xFFFFF7ED),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFFF97316),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Select a destination table below. The entire order will be transferred including all items, guests, and payment status.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF78350F),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Destination grid
          Expanded(
            child: BlocBuilder<TableManagementBloc, TableManagementState>(
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
                  _availableTables = state.tables
                      .map((entity) => TableData.fromEntity(entity))
                      .toList();

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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: _filteredTables.length,
                    itemBuilder: (context, index) {
                      final table = _filteredTables[index];
                      return _buildDestinationCard(table);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Bottom action bar
          Container(
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
                  onPressed: canConfirm ? () => _confirmMove() : null,
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
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(TableData table) {
    final isSelected = _selectedDestination?.number == table.number;
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
          ? () => setState(() => _selectedDestination = table)
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: canSelect ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? cardColor : cardColor.withValues(alpha: 0.3),
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
                    color: cardColor.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmMove() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Moving Table ${widget.sourceTable.number} to Table ${_selectedDestination!.number}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }
}
