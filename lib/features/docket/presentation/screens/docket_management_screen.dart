import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/docket_management_bloc.dart';
import '../bloc/docket_management_event.dart';
import '../bloc/docket_management_state.dart';
import '../../domain/entities/docket_management_entities.dart';

/// Standalone screen for managing dockets system-wide
/// Accessible from main navigation for viewing and managing orders/receipts
class DocketManagementScreen extends StatelessWidget {
  const DocketManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Docket Management',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocBuilder<DocketManagementBloc, DocketManagementState>(
              builder: (context, state) {
                if (state is DocketManagementLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DocketManagementError) {
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
                            context.read<DocketManagementBloc>().add(
                              const LoadDocketsEvent(),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is DocketManagementLoaded) {
                  if (state.dockets.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return _buildDocketList(context, state);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: Colors.green.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage Dockets',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'View and manage all orders and receipts',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<DocketManagementBloc, DocketManagementState>(
            builder: (context, state) {
              if (state is DocketManagementLoaded) {
                final totalDockets = state.dockets.length;
                final totalAmount = state.dockets.fold<double>(
                  0,
                  (sum, docket) => sum + docket.totalAmount,
                );
                final pendingCount = state.dockets
                    .where((docket) => docket.status == DocketStatus.pending)
                    .length;

                return Row(
                  children: [
                    _buildStatCard(
                      'Total Orders',
                      totalDockets.toString(),
                      Icons.assignment,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Pending',
                      pendingCount.toString(),
                      Icons.pending,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Total Value',
                      '\$${totalAmount.toStringAsFixed(2)}',
                      Icons.attach_money,
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Dockets Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Orders and receipts will appear here once customers place orders',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocketList(BuildContext context, DocketManagementLoaded state) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: state.dockets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final docket = state.dockets[index];
        return _buildDocketCard(context, docket);
      },
    );
  }

  Widget _buildDocketCard(BuildContext context, DocketEntity docket) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade100, width: 1),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.all(20),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.receipt_long, color: Colors.white, size: 24),
        ),
        title: Text(
          docket.name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                docket.description,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Table: ${docket.tableNumber} • ${docket.customerName}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(docket.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _getStatusColor(docket.status)),
              ),
              child: Text(
                _getStatusText(docket.status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(docket.status),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Text(
              '\$${docket.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),

        children: [
          const Divider(height: 24),
          ...docket.items.map((item) => _buildDocketItem(item)),
        ],
      ),
    );
  }

  Widget _buildDocketItem(DocketItemEntity item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${item.quantity}x ${item.name}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            ),
          ),
          Text(
            '\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DocketStatus status) {
    switch (status) {
      case DocketStatus.pending:
        return Colors.orange.shade600;
      case DocketStatus.preparing:
        return Colors.blue.shade600;
      case DocketStatus.ready:
        return Colors.green.shade600;
      case DocketStatus.served:
        return Colors.purple.shade600;
      case DocketStatus.cancelled:
        return Colors.red.shade600;
    }
  }

  String _getStatusText(DocketStatus status) {
    switch (status) {
      case DocketStatus.pending:
        return 'Pending';
      case DocketStatus.preparing:
        return 'Preparing';
      case DocketStatus.ready:
        return 'Ready';
      case DocketStatus.served:
        return 'Served';
      case DocketStatus.cancelled:
        return 'Cancelled';
    }
  }
}
