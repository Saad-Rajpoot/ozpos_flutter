import 'package:equatable/equatable.dart';
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
  late final TablesViewCubit _viewCubit;

  @override
  void initState() {
    super.initState();
    _viewCubit = TablesViewCubit();
    context.read<TableManagementBloc>().add(const LoadTablesEvent());
  }

  @override
  void dispose() {
    _viewCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 1.0, maxScaleFactor: 1.1);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scaler),
      child: BlocProvider<TablesViewCubit>.value(
        value: _viewCubit,
        child: BlocListener<TableManagementBloc, TableManagementState>(
          listener: (context, state) {
            if (state is TableManagementLoaded) {
              _viewCubit.setTableData(
                state.tables
                    .map((entity) => TableData.fromEntity(entity))
                    .toList(),
              );
            }
          },
          child: BlocBuilder<TablesViewCubit, TablesViewState>(
            buildWhen: (previous, current) {
              // Only rebuild if relevant view state changes
              return previous.selectedArea != current.selectedArea ||
                  previous.filterStatus != current.filterStatus ||
                  previous.searchQuery != current.searchQuery ||
                  previous.selectedTable != current.selectedTable ||
                  previous.tableDataList != current.tableDataList;
            },
            builder: (context, viewState) {
              final isDesktop = MediaQuery.of(context).size.width >= 768;
              final showDetailsPanel =
                  isDesktop && viewState.selectedTable != null;

              return Scaffold(
                backgroundColor: const Color(0xFFF5F5F7),
                body: Row(
                  children: [
                    // Sidebar navigation
                    if (isDesktop)
                      const SidebarNav(activeRoute: AppRouter.tables),

                    // Main content
                    Expanded(
                      child: Column(
                        children: [
                          _buildHeader(),
                          Expanded(
                            child: Row(
                              children: [
                                // Left rail - Areas
                                _buildAreasRail(viewState),

                                // Center - Table grid
                                Expanded(
                                  flex: showDetailsPanel ? 2 : 3,
                                  child: _buildTableGrid(viewState),
                                ),

                                // Right - Details panel
                                if (showDetailsPanel)
                                  SizedBox(
                                    width: 380,
                                    child: _buildDetailsPanel(viewState),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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

  Widget _buildAreasRail(TablesViewState viewState) {
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
            viewState,
            TableArea.main,
            'Main',
            Icons.restaurant,
            viewState.areaTableCount(TableArea.main),
          ),
          _buildAreaItem(
            viewState,
            TableArea.tens,
            '10s',
            Icons.deck,
            viewState.areaTableCount(TableArea.tens),
          ),
          _buildAreaItem(
            viewState,
            TableArea.twenties,
            '20s',
            Icons.weekend,
            viewState.areaTableCount(TableArea.twenties),
          ),
          _buildAreaItem(
            viewState,
            TableArea.patio,
            'Patio',
            Icons.outdoor_grill,
            viewState.areaTableCount(TableArea.patio),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaItem(
    TablesViewState viewState,
    TableArea area,
    String label,
    IconData icon,
    int count,
  ) {
    final isActive = viewState.selectedArea == area;

    return InkWell(
      onTap: () => _viewCubit.selectArea(area),
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

  Widget _buildTableGrid(TablesViewState viewState) {
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
                  onChanged: _viewCubit.updateSearchQuery,
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
                      viewState.filterStatus == null,
                      () => _viewCubit.setFilterStatus(null),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Available',
                      viewState.filterStatus == TableStatus.available,
                      () => _viewCubit.setFilterStatus(TableStatus.available),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Occupied',
                      viewState.filterStatus == TableStatus.occupied,
                      () => _viewCubit.setFilterStatus(TableStatus.occupied),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Reserved',
                      viewState.filterStatus == TableStatus.reserved,
                      () => _viewCubit.setFilterStatus(TableStatus.reserved),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Table cards grid
          Expanded(
            child: BlocBuilder<TableManagementBloc, TableManagementState>(
              buildWhen: (previous, current) {
                // Always rebuild on state type changes
                if (previous.runtimeType != current.runtimeType) {
                  return true;
                }

                // For TableManagementLoaded state, only rebuild if tables change
                if (previous is TableManagementLoaded && current is TableManagementLoaded) {
                  return previous.tables != current.tables;
                }

                // For TableManagementError state, only rebuild if error message changes
                if (previous is TableManagementError && current is TableManagementError) {
                  return previous.message != current.message;
                }

                return false;
              },
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
                  final filteredTables = viewState.filteredTables;

                  if (filteredTables.isEmpty) {
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
                    itemCount: filteredTables.length,
                    itemBuilder: (context, index) {
                      final table = filteredTables[index];
                      return _buildTableCard(viewState, table);
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

  Widget _buildTableCard(TablesViewState viewState, TableData table) {
    final isSelected = viewState.selectedTable?.number == table.number;
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
      onTap: () => _viewCubit.selectTable(table),
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

  Widget _buildDetailsPanel(TablesViewState viewState) {
    final table = viewState.selectedTable!;

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
    final tablesCubit = _viewCubit;
    final selectedTable = tablesCubit.state.selectedTable;
    if (selectedTable == null) return;

    final result = await NavigationService.pushNamed(
      AppRouter.moveTable,
      arguments: {'sourceTable': selectedTable},
    );

    if (result != null && mounted) {
      NavigationService.showSuccess('Table moved successfully');
      tablesCubit.clearSelectedTable();
    }
  }

  void _onMergeTables() {
    final selectedTable = _viewCubit.state.selectedTable;
    if (selectedTable == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Merge Tables'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Merge Table ${selectedTable.number} with another table?'),
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
                    'Merge table ${selectedTable.number} - Feature coming soon',
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
    final selectedTable = _viewCubit.state.selectedTable;
    if (selectedTable == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Split Bill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Split bill for Table ${selectedTable.number}'),
            const SizedBox(height: 16),
            const Text(
              'Choose how to split the bill:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Split by Guest'),
              subtitle: Text('${selectedTable.guests ?? 0} guests'),
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
              subtitle: Text('${selectedTable.items ?? 0} items'),
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
    final selectedTable = _viewCubit.state.selectedTable;
    if (selectedTable == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Bill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Table ${selectedTable.number}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Order ${selectedTable.orderId}',
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
                  '\$${selectedTable.amount?.toStringAsFixed(2) ?? '0.00'}',
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
    final selectedTable = _viewCubit.state.selectedTable;
    if (selectedTable == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit order for Table ${selectedTable.number} - Opening menu...',
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
    final tablesCubit = _viewCubit;
    final selectedTable = tablesCubit.state.selectedTable;
    if (selectedTable == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Table'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clear Table ${selectedTable.number}?'),
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
                  content: Text('Table ${selectedTable.number} cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              tablesCubit.clearSelectedTable();
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

class TablesViewState extends Equatable {
  const TablesViewState({
    this.selectedArea = TableArea.main,
    this.filterStatus,
    this.searchQuery = '',
    this.selectedTable,
    this.tableDataList = const [],
  });

  final TableArea selectedArea;
  final TableStatus? filterStatus;
  final String searchQuery;
  final TableData? selectedTable;
  final List<TableData> tableDataList;

  List<TableData> get filteredTables {
    return tableDataList.where((table) {
      if (table.area != selectedArea) return false;
      if (filterStatus != null && table.status != filterStatus) return false;

      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return table.number.toLowerCase().contains(query) ||
            (table.serverTag?.toLowerCase().contains(query) ?? false) ||
            (table.orderId?.toLowerCase().contains(query) ?? false);
      }

      return true;
    }).toList();
  }

  int areaTableCount(TableArea area) {
    return tableDataList.where((table) => table.area == area).length;
  }

  TablesViewState copyWith({
    TableArea? selectedArea,
    TableStatus? filterStatus,
    bool setFilterStatusToNull = false,
    String? searchQuery,
    TableData? selectedTable,
    bool setSelectedTableToNull = false,
    List<TableData>? tableDataList,
  }) {
    return TablesViewState(
      selectedArea: selectedArea ?? this.selectedArea,
      filterStatus:
          setFilterStatusToNull ? null : (filterStatus ?? this.filterStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTable:
          setSelectedTableToNull ? null : (selectedTable ?? this.selectedTable),
      tableDataList: tableDataList ?? this.tableDataList,
    );
  }

  @override
  List<Object?> get props =>
      [selectedArea, filterStatus, searchQuery, selectedTable, tableDataList];
}

class TablesViewCubit extends Cubit<TablesViewState> {
  TablesViewCubit() : super(const TablesViewState());

  void setTableData(List<TableData> tables) {
    emit(state.copyWith(tableDataList: List.unmodifiable(tables)));
  }

  void selectArea(TableArea area) {
    emit(state.copyWith(selectedArea: area, setSelectedTableToNull: true));
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

  void selectTable(TableData table) {
    emit(state.copyWith(selectedTable: table));
  }

  void clearSelectedTable() {
    emit(state.copyWith(setSelectedTableToNull: true));
  }
}
