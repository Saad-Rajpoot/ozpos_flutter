import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ozpos_flutter/features/tables/domain/entities/table_entity.dart';
import 'package:ozpos_flutter/features/menu/data/seed_data.dart';
import '../../../checkout/presentation/bloc/cart_bloc.dart';

enum TableViewMode { list, floor }

/// Table Selection Modal with List and Floor views
class TableSelectionModal extends StatefulWidget {
  const TableSelectionModal({super.key});

  @override
  State<TableSelectionModal> createState() => _TableSelectionModalState();
}

class _TableSelectionModalState extends State<TableSelectionModal> {
  TableViewMode _viewMode = TableViewMode.list;
  TableStatus? _filterStatus;
  String _searchQuery = '';
  TableEntity? _selectedTable;

  List<TableEntity> get _filteredTables {
    List<TableEntity> tables = SeedData.tables;

    // Apply status filter
    if (_filterStatus != null) {
      tables = tables.where((t) => t.status == _filterStatus).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      tables = tables.where((t) {
        final String tableNumber = t.number;
        final String serverName = t.serverName ?? '';
        return tableNumber.contains(_searchQuery) ||
            serverName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return tables;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 20),

            // Search and filters
            _buildSearchAndFilters(),
            const SizedBox(height: 16),

            // Status filter chips
            _buildStatusFilters(),
            const SizedBox(height: 20),

            // Content (List or Floor view)
            Expanded(
              child: _viewMode == TableViewMode.list
                  ? _buildListView()
                  : _buildFloorView(),
            ),

            const SizedBox(height: 20),

            // Footer buttons
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader() {
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
                isSelected: _viewMode == TableViewMode.list,
                onTap: () => setState(() => _viewMode = TableViewMode.list),
              ),
              _ViewToggleButton(
                icon: Icons.grid_view,
                isSelected: _viewMode == TableViewMode.floor,
                onTap: () => setState(() => _viewMode = TableViewMode.floor),
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

  Widget _buildSearchAndFilters() {
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
      onChanged: (value) => setState(() => _searchQuery = value),
    );
  }

  Widget _buildStatusFilters() {
    return Wrap(
      spacing: 8,
      children: [
        _StatusChip(
          label: 'All',
          isSelected: _filterStatus == null,
          onTap: () => setState(() => _filterStatus = null),
        ),
        _StatusChip(
          label: 'Available',
          color: const Color(0xFF10B981),
          isSelected: _filterStatus == TableStatus.available,
          onTap: () => setState(() => _filterStatus = TableStatus.available),
        ),
        _StatusChip(
          label: 'Occupied',
          color: const Color(0xFFEF4444),
          isSelected: _filterStatus == TableStatus.occupied,
          onTap: () => setState(() => _filterStatus = TableStatus.occupied),
        ),
        _StatusChip(
          label: 'Reserved',
          color: const Color(0xFF3B82F6),
          isSelected: _filterStatus == TableStatus.reserved,
          onTap: () => setState(() => _filterStatus = TableStatus.reserved),
        ),
        _StatusChip(
          label: 'Cleaning',
          color: const Color(0xFFF59E0B),
          isSelected: _filterStatus == TableStatus.cleaning,
          onTap: () => setState(() => _filterStatus = TableStatus.cleaning),
        ),
      ],
    );
  }

  // ==========================================================================
  // LIST VIEW
  // ==========================================================================

  Widget _buildListView() {
    final tables = _filteredTables;

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
          isSelected: _selectedTable?.id == table.id,
          onTap: () => setState(() => _selectedTable = table),
        );
      },
    );
  }

  // ==========================================================================
  // FLOOR VIEW
  // ==========================================================================

  Widget _buildFloorView() {
    final tables = _filteredTables;

    if (tables.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Legend
        _buildLegend(),
        const SizedBox(height: 16),

        // Floor grid (10x10)
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

                  // Find table at this position
                  final table = tables.firstWhere(
                    (t) => t.floorX == x && t.floorY == y,
                    orElse: () => const TableEntity(
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
                    isSelected: _selectedTable?.id == table.id,
                    onTap: () => setState(() => _selectedTable = table),
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

  Widget _buildFooter(BuildContext context) {
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
          onPressed: _selectedTable != null
              ? () {
                  context.read<CartBloc>().add(
                    SelectTable(table: _selectedTable!),
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
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
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
                color: _statusColor.withValues(alpha: 0.1),
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
                          color: _statusColor.withValues(alpha: 0.1),
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
            color: isSelected
                ? _statusColor
                : _statusColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: _statusColor, width: isSelected ? 3 : 2),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _statusColor.withValues(alpha: 0.3),
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
