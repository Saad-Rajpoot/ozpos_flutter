import 'package:equatable/equatable.dart';
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
              child: BlocProvider(
                create: (_) => ReservationsViewCubit(),
                child:
                    BlocBuilder<ReservationsViewCubit, ReservationsViewState>(
                  builder: (context, viewState) {
                    return BlocBuilder<ReservationManagementBloc,
                        ReservationManagementState>(
                      builder: (context, dataState) {
                        final filtered =
                            _filterReservations(dataState, viewState);
                        return Column(
                          children: [
                            _Header(bookingsCount: filtered.length),
                            _Toolbar(viewState: viewState),
                            Expanded(
                              child: viewState.isListView
                                  ? _ListViewContent(
                                      dataState: dataState,
                                      filteredReservations: filtered,
                                    )
                                  : const _FloorViewContent(),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    await showDialog(
      context: context,
      builder: (context) => ReservationFormModal(reservation: reservation),
    );
  }

  void _cancelReservation(ReservationEntity reservation) {
    final reservationsBloc = context.read<ReservationManagementBloc>();
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Reservation'),
        content: Text('Cancel reservation for ${reservation.guest.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              reservationsBloc.add(const LoadReservationsEvent());
              messenger.showSnackBar(
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

class _Header extends StatelessWidget {
  const _Header({required this.bookingsCount});

  final int bookingsCount;

  @override
  Widget build(BuildContext context) {
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
              Text(
                '$bookingsCount bookings',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.viewState});

  final ReservationsViewState viewState;

  @override
  Widget build(BuildContext context) {
    final viewCubit = context.read<ReservationsViewCubit>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _ViewButton(
                  label: 'List View',
                  icon: Icons.view_list,
                  isSelected: viewState.isListView,
                  onTap: () => viewCubit.setListView(true),
                ),
                _ViewButton(
                  label: 'Floor View',
                  icon: Icons.grid_view,
                  isSelected: !viewState.isListView,
                  onTap: () => viewCubit.setListView(false),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => const ReservationFormModal(),
              );
              if (!context.mounted) return;
              context
                  .read<ReservationManagementBloc>()
                  .add(const LoadReservationsEvent());
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Reservation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 300,
            child: TextField(
              onChanged: viewCubit.updateSearchQuery,
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
          _DateChip(
            label: 'Today',
            isSelected:
                viewState.selectedDateFilter == ReservationsDateFilter.today,
            onTap: () => viewCubit.setDateFilter(ReservationsDateFilter.today),
          ),
          const SizedBox(width: 8),
          _DateChip(
            label: 'Tomorrow',
            isSelected:
                viewState.selectedDateFilter == ReservationsDateFilter.tomorrow,
            onTap: () =>
                viewCubit.setDateFilter(ReservationsDateFilter.tomorrow),
          ),
          const SizedBox(width: 8),
          _DateChip(
            label: 'All',
            isSelected:
                viewState.selectedDateFilter == ReservationsDateFilter.all,
            onTap: () => viewCubit.setDateFilter(ReservationsDateFilter.all),
          ),
        ],
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  const _ViewButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
}

class _ListViewContent extends StatelessWidget {
  const _ListViewContent({
    required this.dataState,
    required this.filteredReservations,
  });

  final ReservationManagementState dataState;
  final List<ReservationEntity> filteredReservations;

  @override
  Widget build(BuildContext context) {
    final hostState =
        context.findAncestorStateOfType<_ReservationsScreenState>();

    if (dataState is ReservationManagementLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dataState is ReservationManagementError) {
      final errorState = dataState as ReservationManagementError;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error: ${errorState.message}',
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

    if (dataState is ReservationManagementLoaded) {
      if (filteredReservations.isEmpty) {
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
              ...filteredReservations.map(
                (reservation) => _ReservationRow(
                  reservation: reservation,
                  onSeat: hostState?._seatReservation,
                  onEdit: hostState?._editReservation,
                  onCancel: hostState?._cancelReservation,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}

class _ReservationRow extends StatelessWidget {
  const _ReservationRow({
    required this.reservation,
    required this.onSeat,
    required this.onEdit,
    required this.onCancel,
  });

  final ReservationEntity reservation;
  final void Function(ReservationEntity)? onSeat;
  final void Function(ReservationEntity)? onEdit;
  final void Function(ReservationEntity)? onCancel;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MMM dd, yyyy');

    final actionButtons = <Widget>[];
    if ((reservation.status == ReservationStatus.pending ||
            reservation.status == ReservationStatus.confirmed) &&
        onSeat != null) {
      actionButtons.add(
        _ActionButton(
          label: 'Seat',
          color: const Color(0xFF10B981),
          onPressed: () => onSeat!(reservation),
        ),
      );
    }

    actionButtons.add(
      IconButton(
        icon: const Icon(Icons.edit, size: 18),
        onPressed: onEdit == null ? null : () => onEdit!(reservation),
        tooltip: 'Edit',
      ),
    );

    if (reservation.status != ReservationStatus.cancelled && onCancel != null) {
      actionButtons.add(
        TextButton(
          onPressed: () => onCancel!(reservation),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFFEF4444), fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
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
          Expanded(
            child: Text(
              dateFormat.format(reservation.timing.startAt),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              timeFormat.format(reservation.timing.startAt),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
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
          Expanded(
            child: Text(
              reservation.tableId,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: _StatusPill(status: reservation.status)),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actionButtons,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ReservationStatus status;

  @override
  Widget build(BuildContext context) {
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
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
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
}

class _FloorViewContent extends StatelessWidget {
  const _FloorViewContent();

  @override
  Widget build(BuildContext context) {
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
}

List<ReservationEntity> _filterReservations(
  ReservationManagementState dataState,
  ReservationsViewState viewState,
) {
  if (dataState is! ReservationManagementLoaded) return const [];

  return dataState.reservations.where((res) {
    bool matchesDate = true;
    final start = res.timing.startAt;
    final now = DateTime.now();

    switch (viewState.selectedDateFilter) {
      case ReservationsDateFilter.today:
        matchesDate = start.year == now.year &&
            start.month == now.month &&
            start.day == now.day;
        break;
      case ReservationsDateFilter.tomorrow:
        final tomorrow = now.add(const Duration(days: 1));
        matchesDate = start.year == tomorrow.year &&
            start.month == tomorrow.month &&
            start.day == tomorrow.day;
        break;
      case ReservationsDateFilter.all:
        matchesDate = true;
        break;
    }

    bool matchesSearch = true;
    if (viewState.searchQuery.isNotEmpty) {
      final query = viewState.searchQuery.toLowerCase();
      matchesSearch = res.guest.name.toLowerCase().contains(query) ||
          res.guest.phone.toLowerCase().contains(query) ||
          res.reservationId.toLowerCase().contains(query);
    }

    return matchesDate && matchesSearch;
  }).toList();
}

enum ReservationsDateFilter { today, tomorrow, all }

class ReservationsViewState extends Equatable {
  const ReservationsViewState({
    this.isListView = true,
    this.selectedDateFilter = ReservationsDateFilter.all,
    this.searchQuery = '',
  });

  final bool isListView;
  final ReservationsDateFilter selectedDateFilter;
  final String searchQuery;

  ReservationsViewState copyWith({
    bool? isListView,
    ReservationsDateFilter? selectedDateFilter,
    String? searchQuery,
  }) {
    return ReservationsViewState(
      isListView: isListView ?? this.isListView,
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [isListView, selectedDateFilter, searchQuery];
}

class ReservationsViewCubit extends Cubit<ReservationsViewState> {
  ReservationsViewCubit() : super(const ReservationsViewState());

  void setListView(bool isListView) {
    emit(state.copyWith(isListView: isListView));
  }

  void setDateFilter(ReservationsDateFilter filter) {
    emit(state.copyWith(selectedDateFilter: filter));
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
