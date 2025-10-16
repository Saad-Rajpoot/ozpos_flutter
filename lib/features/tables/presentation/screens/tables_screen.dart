import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/widgets/sidebar_nav.dart';
import '../bloc/table_management_bloc.dart';
import '../bloc/table_management_event.dart';
import '../bloc/table_management_state.dart';
import '../../domain/entities/table_types.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  TableArea _selectedArea = TableArea.main;
  TableStatus? _filterStatus;
  String _searchQuery = '';
  TableData? _selectedTable;
  List<TableData> _tableDataList = [];

  @override
  void initState() {
    super.initState();
    context.read<TableManagementBloc>().add(const LoadTablesEvent());
  }

  List<TableData> get _filteredTables {
    return _tableDataList.where((table) {
      // Area filter
      if (table.area != _selectedArea) return false;

      // Status filter
      if (_filterStatus != null && table.status != _filterStatus) return false;

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return table.number.toString().contains(query) ||
            (table.serverTag?.toLowerCase().contains(query) ?? false) ||
            (table.orderId?.toLowerCase().contains(query) ?? false);
      }

      return true;
    }).toList();
  }

  int _getAreaTableCount(TableArea area) {
    return _tableDataList.where((t) => t.area == area).length;
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 1.0, maxScaleFactor: 1.1);
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final showDetailsPanel = isDesktop && _selectedTable != null;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scaler),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: Row(
          children: [
            // Sidebar navigation
            if (isDesktop) const SidebarNav(activeRoute: AppRouter.tables),

            // Main content
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Row(
                      children: [
                        // Left rail - Areas
                        _buildAreasRail(),

                        // Center - Table grid
                        Expanded(
                          flex: showDetailsPanel ? 2 : 3,
                          child: _buildTableGrid(),
                        ),

                        // Right - Details panel
                        if (showDetailsPanel)
                          SizedBox(width: 380, child: _buildDetailsPanel()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Table Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage tables, reservations, and seating',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.event, size: 16),
                label: const Text('Reservations'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Quick Reserve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAreasRail() {
    return Container(
      width: 180,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Text(
              'Levels',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          _buildAreaItem(
            TableArea.main,
            'Main',
            Icons.restaurant,
            _getAreaTableCount(TableArea.main),
          ),
          _buildAreaItem(
            TableArea.tens,
            '10s',
            Icons.deck,
            _getAreaTableCount(TableArea.tens),
          ),
          _buildAreaItem(
            TableArea.twenties,
            '20s',
            Icons.weekend,
            _getAreaTableCount(TableArea.twenties),
          ),
          _buildAreaItem(
            TableArea.patio,
            'Patio',
            Icons.outdoor_grill,
            _getAreaTableCount(TableArea.patio),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaItem(
    TableArea area,
    String label,
    IconData icon,
    int count,
  ) {
    final isActive = _selectedArea == area;

    return InkWell(
      onTap: () => setState(() {
        _selectedArea = area;
        _selectedTable = null;
      }),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3B82F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableGrid() {
    return Container(
      color: const Color(0xFFF5F5F7),
      child: Column(
        children: [
          // Search and filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search table...',
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFilterChip(
                      'All',
                      _filterStatus == null,
                      () => setState(() => _filterStatus = null),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Available',
                      _filterStatus == TableStatus.available,
                      () =>
                          setState(() => _filterStatus = TableStatus.available),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Occupied',
                      _filterStatus == TableStatus.occupied,
                      () =>
                          setState(() => _filterStatus = TableStatus.occupied),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Reserved',
                      _filterStatus == TableStatus.reserved,
                      () =>
                          setState(() => _filterStatus = TableStatus.reserved),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Table cards grid
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
                                  const LoadTablesEvent(),
                                );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is TableManagementLoaded) {
                  _tableDataList = state.tables
                      .map((entity) => TableData.fromEntity(entity))
                      .toList();

                  if (_filteredTables.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tables found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: _filteredTables.length,
                    itemBuilder: (context, index) {
                      final table = _filteredTables[index];
                      return _buildTableCard(table);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildTableCard(TableData table) {
    final isSelected = _selectedTable?.number == table.number;
    Color cardColor;

    switch (table.status) {
      case TableStatus.available:
        cardColor = const Color(0xFF10B981);
        break;
      case TableStatus.occupied:
        cardColor = const Color(0xFFEF4444);
        break;
      case TableStatus.reserved:
        cardColor = const Color(0xFF3B82F6);
        break;
      case TableStatus.cleaning:
        cardColor = const Color(0xFF9CA3AF);
        break;
    }

    return InkWell(
      onTap: () => setState(() => _selectedTable = table),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
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
            // Header
            Row(
              children: [
                Text(
                  'Table ${table.number}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cardColor,
                  ),
                ),
                if (table.serverTag != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      table.serverTag!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: cardColor,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Icon(Icons.remove_circle_outline, size: 16, color: cardColor),
              ],
            ),
            const Spacer(),

            // Details
            if (table.amount != null) ...[
              Text(
                'Amount:',
                style: TextStyle(
                  fontSize: 12,
                  color: cardColor.withOpacity(0.7),
                ),
              ),
              Text(
                '\$${table.amount!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cardColor,
                ),
              ),
              const SizedBox(height: 4),
            ],

            if (table.elapsedTime != null)
              Row(
                children: [
                  Text(
                    'Time:',
                    style: TextStyle(
                      fontSize: 12,
                      color: cardColor.withOpacity(0.7),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${table.elapsedTime!.inMinutes.toString().padLeft(2, '0')}:${(table.elapsedTime!.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cardColor,
                    ),
                  ),
                ],
              ),

            if (table.guests != null)
              Row(
                children: [
                  Text(
                    'Guests:',
                    style: TextStyle(
                      fontSize: 12,
                      color: cardColor.withOpacity(0.7),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${table.guests}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cardColor,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsPanel() {
    final table = _selectedTable!;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Table ${table.number} — Order ${table.orderId ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (table.status == TableStatus.occupied)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Alert',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Details grid
          _buildDetailRow(
            'Items',
            '${table.items ?? 0}',
            'Total',
            '\$${table.amount?.toStringAsFixed(2) ?? '0.00'}',
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Time',
            table.elapsedTime != null
                ? '${table.elapsedTime!.inMinutes.toString().padLeft(2, '0')}:${(table.elapsedTime!.inSeconds % 60).toString().padLeft(2, '0')}'
                : '--',
            'Waiter',
            table.waiter ?? '--',
          ),
          const SizedBox(height: 16),

          // Notes
          const Text(
            'Notes:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            table.notes ?? 'No notes',
            style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
          ),

          const SizedBox(height: 32),

          // Actions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionButton(
                'Move Table',
                Icons.swap_horiz,
                false,
                _onMoveTable,
              ),
              _buildActionButton(
                'Merge Tables',
                Icons.call_merge,
                false,
                _onMergeTables,
              ),
              _buildActionButton(
                'Split Bill',
                Icons.call_split,
                false,
                _onSplitBill,
              ),
              _buildActionButton(
                'Close Bill',
                Icons.check_circle,
                true,
                _onCloseBill,
              ),
              _buildActionButton('Edit Order', Icons.edit, false, _onEditOrder),
              _buildActionButton(
                'Clear Table',
                Icons.clear,
                false,
                _onClearTable,
                isDanger: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label1,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value1,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label2,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value2,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    bool isPrimary,
    VoidCallback onTap, {
    bool isDanger = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? const Color(0xFF3B82F6)
              : isDanger
                  ? Colors.white
                  : Colors.white,
          foregroundColor: isPrimary
              ? Colors.white
              : isDanger
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF111827),
          side: BorderSide(
            color: isPrimary
                ? const Color(0xFF3B82F6)
                : isDanger
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFE5E7EB),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
      ),
    );
  }

  // ========================================================================
  // ACTION METHODS
  // ========================================================================

  void _onMoveTable() async {
    if (_selectedTable == null) return;

    final result = await NavigationService.pushNamed(
      AppRouter.moveTable,
      arguments: {'sourceTable': _selectedTable!},
    );

    if (result != null && mounted) {
      NavigationService.showSuccess('Table moved successfully');
      setState(() => _selectedTable = null);
    }
  }

  void _onMergeTables() {
    if (_selectedTable == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Merge Tables'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Merge Table ${_selectedTable!.number} with another table?'),
            const SizedBox(height: 16),
            const Text(
              'This will combine both orders into a single bill.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Merge table ${_selectedTable!.number} - Feature coming soon',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: const Text('Select Table'),
          ),
        ],
      ),
    );
  }

  void _onSplitBill() {
    if (_selectedTable == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Split Bill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Split bill for Table ${_selectedTable!.number}'),
            const SizedBox(height: 16),
            const Text(
              'Choose how to split the bill:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Split by Guest'),
              subtitle: Text('${_selectedTable!.guests ?? 0} guests'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Split by guest - Feature coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Split by Item'),
              subtitle: Text('${_selectedTable!.items ?? 0} items'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Split by item - Feature coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Custom Split'),
              subtitle: const Text('Enter amounts manually'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Custom split - Feature coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _onCloseBill() {
    if (_selectedTable == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Bill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Table ${_selectedTable!.number}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Order ${_selectedTable!.orderId}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  '\$${_selectedTable!.amount?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Proceed to checkout to close this bill?',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(AppRouter.checkout);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: const Text('Go to Checkout'),
          ),
        ],
      ),
    );
  }

  void _onEditOrder() {
    if (_selectedTable == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit order for Table ${_selectedTable!.number} - Opening menu...',
        ),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Open',
          onPressed: () {
            Navigator.of(context).pushNamed(AppRouter.menu);
          },
        ),
      ),
    );
  }

  void _onClearTable() {
    if (_selectedTable == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Table'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clear Table ${_selectedTable!.number}?'),
            const SizedBox(height: 16),
            const Text(
              'This will remove all orders and reset the table status. This action cannot be undone.',
              style: TextStyle(fontSize: 13, color: Color(0xFFEF4444)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Table ${_selectedTable!.number} cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              setState(() => _selectedTable = null);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Clear Table'),
          ),
        ],
      ),
    );
  }
}
