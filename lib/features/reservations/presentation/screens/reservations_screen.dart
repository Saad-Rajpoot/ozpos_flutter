import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/sidebar_nav.dart';
import '../../domain/entities/reservation_entity.dart';
import '../bloc/reservation_management_bloc.dart';
import '../bloc/reservation_management_event.dart';
import '../bloc/reservation_management_state.dart';
import '../widgets/reservation_form_modal.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  String _selectedDateFilter = 'All';
  String _searchQuery = '';
  bool _isListView = true;

  List<ReservationEntity> _getFilteredReservations(
    ReservationManagementState state,
  ) {
    if (state is ReservationManagementLoaded) {
      return state.reservations.where((res) {
        // Date filter
        bool matchesDate = true;
        if (_selectedDateFilter == 'Today') {
          final today = DateTime.now();
          matchesDate = res.timing.startAt.year == today.year &&
              res.timing.startAt.month == today.month &&
              res.timing.startAt.day == today.day;
        } else if (_selectedDateFilter == 'Tomorrow') {
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          matchesDate = res.timing.startAt.year == tomorrow.year &&
              res.timing.startAt.month == tomorrow.month &&
              res.timing.startAt.day == tomorrow.day;
        }

        // Search filter
        bool matchesSearch = true;
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          matchesSearch = res.guest.name.toLowerCase().contains(query) ||
              res.guest.phone.toLowerCase().contains(query) ||
              res.reservationId.toLowerCase().contains(query);
        }

        return matchesDate && matchesSearch;
      }).toList();
    }

    return [];
  }

  int _getBookingsCount(ReservationManagementState state) {
    return _getFilteredReservations(state).length;
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 1.0, maxScaleFactor: 1.1);
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scaler),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: Row(
          children: [
            if (isDesktop)
              const SidebarNav(activeRoute: AppRouter.reservations),
            Expanded(
              child: BlocBuilder<ReservationManagementBloc,
                  ReservationManagementState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      _buildHeader(),
                      _buildToolbar(),
                      Expanded(
                        child: _isListView
                            ? _buildListView(state)
                            : _buildFloorView(),
                      ),
                    ],
                  );
                },
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
      child: Row(
        children: [
          const Icon(Icons.event, size: 24, color: Color(0xFF3B82F6)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reservations',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              BlocBuilder<ReservationManagementBloc,
                  ReservationManagementState>(
                builder: (context, state) {
                  return Text(
                    '${_getBookingsCount(state)} bookings',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          // View toggle
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildViewButton(
                  'List View',
                  Icons.view_list,
                  _isListView,
                  () => setState(() => _isListView = true),
                ),
                _buildViewButton(
                  'Floor View',
                  Icons.grid_view,
                  !_isListView,
                  () => setState(() => _isListView = false),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // New Reservation
          ElevatedButton.icon(
            onPressed: _showNewReservation,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Reservation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const Spacer(),

          // Search
          SizedBox(
            width: 300,
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search by guest name, phone, or ID...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
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
          const SizedBox(width: 16),

          // Date chips
          _buildDateChip(
            'Today',
            _selectedDateFilter == 'Today',
            () => setState(() => _selectedDateFilter = 'Today'),
          ),
          const SizedBox(width: 8),
          _buildDateChip(
            'Tomorrow',
            _selectedDateFilter == 'Tomorrow',
            () => setState(() => _selectedDateFilter = 'Tomorrow'),
          ),
          const SizedBox(width: 8),
          _buildDateChip(
            'All',
            _selectedDateFilter == 'All',
            () => setState(() => _selectedDateFilter = 'All'),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
          border: Border(
            right: label == 'List View'
                ? const BorderSide(color: Color(0xFFE5E7EB))
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildListView(ReservationManagementState state) {
    if (state is ReservationManagementLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ReservationManagementError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.message}',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ReservationManagementBloc>().add(
                      const LoadReservationsEvent(),
                    );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is ReservationManagementLoaded) {
      final reservations = _getFilteredReservations(state);

      if (reservations.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No reservations found',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Table header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'GUEST NAME',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'DATE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'TIME',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'PARTY SIZE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'TABLE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'STATUS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'ACTIONS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),

              // Table rows
              ...reservations.map(
                (reservation) => _buildReservationRow(reservation),
              ),
            ],
          ),
        ),
      );
    }

    // Default case - show loading or empty state
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildReservationRow(ReservationEntity reservation) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          // Guest name
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.guest.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  reservation.guest.phone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Date
          Expanded(
            child: Text(
              dateFormat.format(reservation.timing.startAt),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Time
          Expanded(
            child: Text(
              timeFormat.format(reservation.timing.startAt),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),

          // Party size
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.people, size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(
                  '${reservation.party.size}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          // Table
          Expanded(
            child: Text(
              reservation.tableId,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),

          // Status
          Expanded(child: _buildStatusPill(reservation.status)),

          // Actions
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActionButtons(reservation),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(ReservationStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case ReservationStatus.confirmed:
        backgroundColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        label = 'Confirmed';
        break;
      case ReservationStatus.pending:
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFCA8A04);
        label = 'Pending';
        break;
      case ReservationStatus.seated:
        backgroundColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF2563EB);
        label = 'Seated';
        break;
      case ReservationStatus.cancelled:
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(ReservationEntity reservation) {
    final buttons = <Widget>[];

    // Seat button for pending/confirmed reservations
    if (reservation.status == ReservationStatus.pending ||
        reservation.status == ReservationStatus.confirmed) {
      buttons.add(
        _buildActionButton(
          'Seat',
          const Color(0xFF10B981),
          () => _seatReservation(reservation),
        ),
      );
    }

    // Edit button
    buttons.add(
      IconButton(
        icon: const Icon(Icons.edit, size: 18),
        onPressed: () => _editReservation(reservation),
        tooltip: 'Edit',
      ),
    );

    // Cancel button for non-cancelled reservations
    if (reservation.status != ReservationStatus.cancelled) {
      buttons.add(
        TextButton(
          onPressed: () => _cancelReservation(reservation),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFFEF4444), fontSize: 14),
          ),
        ),
      );
    }

    return buttons;
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }

  Widget _buildFloorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_view, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Floor View',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coming soon',
            style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  void _showNewReservation() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const ReservationFormModal(),
    );

    if (result != null) {
      // In real app, create reservation entity and add to list
      // For now, just show success message
      setState(() {
        // Reload data or add new reservation
      });
    }
  }

  void _seatReservation(ReservationEntity reservation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Seating ${reservation.guest.name} at ${reservation.tableId}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editReservation(ReservationEntity reservation) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ReservationFormModal(reservation: reservation),
    );

    if (result != null) {
      // In real app, update reservation
      setState(() {
        // Update the reservation in the list
      });
    }
  }

  void _cancelReservation(ReservationEntity reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation'),
        content: Text('Cancel reservation for ${reservation.guest.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final index = _getFilteredReservations(
                  context.read<ReservationManagementBloc>().state,
                ).indexWhere(
                  (r) => r.reservationId == reservation.reservationId,
                );
                if (index != -1) {
                  _getFilteredReservations(
                    context.read<ReservationManagementBloc>().state,
                  )[index] = reservation.copyWith(
                    status: ReservationStatus.cancelled,
                  );
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reservation cancelled'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
