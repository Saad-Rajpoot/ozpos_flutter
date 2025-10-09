import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/sidebar_nav.dart';
import '../../domain/entities/delivery_entities.dart';
import '../bloc/delivery_bloc.dart';
import '../bloc/delivery_event.dart';
import '../bloc/delivery_state.dart';
import '../delivery_tokens.dart';
import '../widgets/add_driver_modal.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  String _selectedDateFilter = 'Today';
  String _selectedSourceFilter = 'All Sources';
  String _selectedDriverFilter = 'All Drivers';
  String _selectedOrderTab = 'Ready';
  OrderEntity? _selectedOrder;
  DriverEntity? _selectedDriver;

  @override
  void initState() {
    super.initState();
    context.read<DeliveryBloc>().add(const LoadDeliveryDataEvent());
  }

  List<OrderEntity> get _filteredOrders {
    final state = context.read<DeliveryBloc>().state;
    if (state is! DeliveryLoaded) return [];
    return state.deliveryData.orders.where((order) {
      if (_selectedOrderTab == 'Ready' && order.status != 'ready') return false;
      if (_selectedOrderTab == 'In Progress' &&
          order.status != 'inProgress' &&
          order.status != 'delayed') {
        return false;
      }
      return true;
    }).toList();
  }

  int get _readyCount {
    final state = context.read<DeliveryBloc>().state;
    if (state is! DeliveryLoaded) return 0;
    return state.deliveryData.orders.where((o) => o.status == 'ready').length;
  }

  int get _inProgressCount {
    final state = context.read<DeliveryBloc>().state;
    if (state is! DeliveryLoaded) return 0;
    return state.deliveryData.orders
        .where((o) => o.status == 'inProgress' || o.status == 'delayed')
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 1.0, maxScaleFactor: 1.1);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1280;
    final isTablet = screenWidth >= 901 && screenWidth < 1280;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scaler),
      child: Scaffold(
        backgroundColor: DeliveryTokens.background,
        body: Row(
          children: [
            if (isDesktop || isTablet)
              const SidebarNav(activeRoute: AppRouter.delivery),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildKpiStrip(),
                  _buildFiltersRow(),
                  Expanded(
                    child: isDesktop
                        ? _build3ColumnLayout()
                        : isTablet
                        ? _build2ColumnLayout()
                        : _build1ColumnLayout(),
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
      padding: const EdgeInsets.all(DeliveryTokens.spacingXl),
      decoration: const BoxDecoration(
        color: DeliveryTokens.cardBackground,
        border: Border(bottom: BorderSide(color: DeliveryTokens.borderColor)),
      ),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_shipping, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Delivery Management',
                    style: DeliveryTokens.headingLarge,
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Real-time delivery tracking and driver coordination',
                style: DeliveryTokens.bodySmall,
              ),
            ],
          ),
          const Spacer(),
          _buildHeaderButton('Dark Mode', Icons.dark_mode, false),
          const SizedBox(width: 12),
          _buildHeaderButton('Settings', Icons.settings, false),
          const SizedBox(width: 12),
          _buildHeaderButton('Add Driver', Icons.add, true),
          const SizedBox(width: 12),
          _buildHeaderButton('Live Map', Icons.map, false),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(String label, IconData icon, bool isPrimary) {
    return ElevatedButton.icon(
      onPressed: () {
        if (label == 'Add Driver') {
          showDialog(
            context: context,
            builder: (context) => const AddDriverModal(),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label - Coming soon'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFFF97316) : Colors.white,
        foregroundColor: isPrimary ? Colors.white : DeliveryTokens.textPrimary,
        side: isPrimary
            ? null
            : const BorderSide(color: DeliveryTokens.borderColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
      ),
    );
  }

  Widget _buildKpiStrip() {
    return BlocBuilder<DeliveryBloc, DeliveryState>(
      builder: (context, state) {
        if (state is DeliveryLoading) {
          return Container(
            padding: const EdgeInsets.all(DeliveryTokens.spacingXl),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DeliveryError) {
          return Container(
            padding: const EdgeInsets.all(DeliveryTokens.spacingXl),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load data',
                    style: DeliveryTokens.headingSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message, style: DeliveryTokens.bodySmall),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DeliveryBloc>().add(
                      const LoadDeliveryDataEvent(),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is DeliveryLoaded) {
          final kpis = state.deliveryData.kpiData;

          return Container(
            padding: const EdgeInsets.all(DeliveryTokens.spacingXl),
            child: Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    'Active Drivers',
                    '${kpis.activeDrivers}',
                    Icons.people,
                    DeliveryTokens.kpiActiveDriversStart,
                    DeliveryTokens.kpiActiveDriversEnd,
                  ),
                ),
                const SizedBox(width: DeliveryTokens.spacingLg),
                Expanded(
                  child: _buildKpiCard(
                    'In Progress',
                    '${kpis.inProgress}',
                    Icons.local_shipping,
                    DeliveryTokens.kpiInProgressStart,
                    DeliveryTokens.kpiInProgressEnd,
                  ),
                ),
                const SizedBox(width: DeliveryTokens.spacingLg),
                Expanded(
                  child: _buildKpiCard(
                    'Delayed Orders',
                    '${kpis.delayedOrders}',
                    Icons.access_time,
                    DeliveryTokens.kpiDelayedStart,
                    DeliveryTokens.kpiDelayedEnd,
                  ),
                ),
                const SizedBox(width: DeliveryTokens.spacingLg),
                Expanded(
                  child: _buildKpiCard(
                    'Avg ETA',
                    '${kpis.avgEtaMinutes}m',
                    Icons.schedule,
                    DeliveryTokens.kpiAvgEtaStart,
                    DeliveryTokens.kpiAvgEtaEnd,
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildKpiCard(
    String label,
    String value,
    IconData icon,
    Color startColor,
    Color endColor,
  ) {
    return Container(
      height: DeliveryTokens.kpiHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DeliveryTokens.radiusXl),
        boxShadow: DeliveryTokens.cardShadow,
      ),
      padding: const EdgeInsets.all(DeliveryTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: DeliveryTokens.kpiLabel),
              const Spacer(),
              Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 28),
            ],
          ),
          const Spacer(),
          Text(value, style: DeliveryTokens.kpiValue),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DeliveryTokens.spacingXl,
        vertical: DeliveryTokens.spacingMd,
      ),
      decoration: const BoxDecoration(
        color: DeliveryTokens.cardBackground,
        border: Border(bottom: BorderSide(color: DeliveryTokens.borderColor)),
      ),
      child: Row(
        children: [
          _buildFilterChip(
            'Today',
            _selectedDateFilter == 'Today',
            () => setState(() => _selectedDateFilter = 'Today'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Last 7 days',
            _selectedDateFilter == 'Last 7 days',
            () => setState(() => _selectedDateFilter = 'Last 7 days'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Custom',
            _selectedDateFilter == 'Custom',
            () => setState(() => _selectedDateFilter = 'Custom'),
          ),
          const SizedBox(width: 24),
          _buildDropdownFilter(
            _selectedSourceFilter,
            ['All Sources', 'Website', 'UberEats', 'DoorDash', 'App'],
            (val) => setState(() => _selectedSourceFilter = val!),
          ),
          const SizedBox(width: 12),
          BlocBuilder<DeliveryBloc, DeliveryState>(
            builder: (context, state) {
              if (state is DeliveryLoaded) {
                return _buildDropdownFilter(
                  _selectedDriverFilter,
                  [
                    'All Drivers',
                    ...state.deliveryData.drivers.map((d) => d.name),
                  ],
                  (val) => setState(() => _selectedDriverFilter = val!),
                );
              }
              return _buildDropdownFilter(
                _selectedDriverFilter,
                ['All Drivers'],
                (val) => setState(() => _selectedDriverFilter = val!),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DeliveryTokens.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? DeliveryTokens.textPrimary
              : DeliveryTokens.cardBackground,
          borderRadius: BorderRadius.circular(DeliveryTokens.radiusFull),
          border: Border.all(
            color: isSelected
                ? DeliveryTokens.textPrimary
                : DeliveryTokens.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : DeliveryTokens.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DeliveryTokens.cardBackground,
        borderRadius: BorderRadius.circular(DeliveryTokens.radiusMd),
        border: Border.all(color: DeliveryTokens.borderColor),
      ),
      child: DropdownButton<String>(
        value: value,
        items: options
            .map(
              (opt) => DropdownMenuItem(
                value: opt,
                child: Text(opt, style: DeliveryTokens.bodySmall),
              ),
            )
            .toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
        isDense: true,
      ),
    );
  }

  Widget _build3ColumnLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildMapColumn()),
        Expanded(flex: 3, child: _buildOrdersColumn()),
        SizedBox(width: 380, child: _buildDriversColumn()),
      ],
    );
  }

  Widget _build2ColumnLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildMapColumn()),
        Expanded(flex: 3, child: _buildOrdersColumn()),
      ],
    );
  }

  Widget _build1ColumnLayout() {
    return _buildOrdersColumn();
  }

  Widget _buildMapColumn() {
    return Container(
      margin: const EdgeInsets.all(DeliveryTokens.spacingLg),
      decoration: BoxDecoration(
        color: DeliveryTokens.cardBackground,
        borderRadius: BorderRadius.circular(DeliveryTokens.radiusXl),
        boxShadow: DeliveryTokens.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(DeliveryTokens.spacingLg),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 8),
                const Text('Live Map', style: DeliveryTokens.headingSmall),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.filter_list, size: 18),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen, size: 18),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(DeliveryTokens.radiusXl),
                bottomRight: Radius.circular(DeliveryTokens.radiusXl),
              ),
              child: Stack(
                children: [
                  // Mock map background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFE8F5E9),
                          const Color(0xFFC8E6C9),
                        ],
                      ),
                    ),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _MapGridPainter(),
                    ),
                  ),

                  // Driver markers
                  ...context.read<DeliveryBloc>().state is DeliveryLoaded
                      ? (context.read<DeliveryBloc>().state as DeliveryLoaded)
                            .deliveryData
                            .drivers
                            .map((driver) => _buildDriverMarker(driver))
                      : [],

                  // Selected order route (if any)
                  if (_selectedOrder != null &&
                      _selectedOrder!.assignedDriverId != null)
                    _buildRouteIndicator(_selectedOrder!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverMarker(DriverEntity driver) {
    // Calculate position based on lat/long (simplified for demo)
    final position = _calculateMarkerPosition(
      driver.latitude,
      driver.longitude,
    );
    final statusColor = _getDriverStatusColor(driver.status);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () => setState(() => _selectedDriver = driver),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              driver.name[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteIndicator(OrderEntity order) {
    return Positioned(
      left: 100,
      top: 100,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(8),
          boxShadow: DeliveryTokens.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              'Route to ${order.orderNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Offset _calculateMarkerPosition(double lat, double lng) {
    // Simplified position calculation for demo
    // In a real app, this would use proper map projection
    final x = ((lng + 74) * 200).clamp(50.0, 350.0);
    final y = ((lat - 40.7) * 1000).clamp(50.0, 400.0);
    return Offset(x, y);
  }

  Widget _buildOrdersColumn() {
    return Container(
      margin: const EdgeInsets.all(DeliveryTokens.spacingLg),
      decoration: BoxDecoration(
        color: DeliveryTokens.cardBackground,
        borderRadius: BorderRadius.circular(DeliveryTokens.radiusXl),
        boxShadow: DeliveryTokens.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(DeliveryTokens.spacingLg),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_bag,
                  size: 18,
                  color: Color(0xFFF97316),
                ),
                const SizedBox(width: 8),
                const Text('Orders', style: DeliveryTokens.headingSmall),
                const Spacer(),
                _buildTabChip(
                  'Ready',
                  _readyCount,
                  _selectedOrderTab == 'Ready',
                  () => setState(() => _selectedOrderTab = 'Ready'),
                ),
                const SizedBox(width: 8),
                _buildTabChip(
                  'In Progress',
                  _inProgressCount,
                  _selectedOrderTab == 'In Progress',
                  () => setState(() => _selectedOrderTab = 'In Progress'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<DeliveryBloc, DeliveryState>(
              builder: (context, state) {
                if (state is DeliveryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DeliveryError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 32,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load orders',
                          style: DeliveryTokens.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                if (state is DeliveryLoaded) {
                  if (_filteredOrders.isEmpty) {
                    return const Center(child: Text('No orders found'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(DeliveryTokens.spacingLg),
                    itemCount: _filteredOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildOrderCard(_filteredOrders[index]),
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

  Widget _buildTabChip(
    String label,
    int count,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DeliveryTokens.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? DeliveryTokens.statusInProgress.withValues(alpha: 0.1)
              : DeliveryTokens.dividerColor,
          borderRadius: BorderRadius.circular(DeliveryTokens.radiusFull),
        ),
        child: Text(
          '$label   $count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? DeliveryTokens.statusInProgress
                : DeliveryTokens.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderEntity order) {
    final isSelected = _selectedOrder?.id == order.id;
    final channelColor = _getChannelColor(order.channel);
    final statusColor = _getOrderStatusColor(order.status);

    return InkWell(
      onTap: () => setState(() => _selectedOrder = order),
      borderRadius: BorderRadius.circular(DeliveryTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(DeliveryTokens.cardPadding),
        decoration: BoxDecoration(
          color: DeliveryTokens.cardBackground,
          borderRadius: BorderRadius.circular(DeliveryTokens.radiusLg),
          border: Border.all(
            color: isSelected
                ? DeliveryTokens.statusInProgress
                : DeliveryTokens.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(order.orderNumber, style: DeliveryTokens.headingSmall),
                const SizedBox(width: 8),
                _buildPill(_getChannelLabel(order.channel), channelColor),
                const Spacer(),
                _buildPill(_getOrderStatusLabel(order.status), statusColor),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 16,
                  color: DeliveryTokens.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(order.customerName, style: DeliveryTokens.bodyMedium),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: DeliveryTokens.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(order.address, style: DeliveryTokens.bodySmall),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.restaurant,
                  size: 16,
                  color: DeliveryTokens.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(order.items.join(', '), style: DeliveryTokens.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildEtaCard(
                    'Pickup ETA',
                    '${order.pickupEtaMinutes}m',
                    const Color(0xFFEFF6FF),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEtaCard(
                    'Delivery ETA',
                    '${order.deliveryEtaMinutes}m',
                    const Color(0xFFF0FDF4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Assign Driver',
                    Icons.person_add,
                    true,
                    () => _showAssignDriverModal(order),
                  ),
                ),
                const SizedBox(width: 8),
                _buildIconButton(Icons.bolt, () {}),
                const SizedBox(width: 8),
                _buildIconButton(Icons.more_horiz, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEtaCard(String label, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(DeliveryTokens.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, size: 14),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: DeliveryTokens.labelSmall),
              Text(value, style: DeliveryTokens.labelLarge),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    bool isPrimary,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFFF97316) : Colors.white,
        foregroundColor: isPrimary ? Colors.white : DeliveryTokens.textPrimary,
        side: isPrimary
            ? null
            : const BorderSide(color: DeliveryTokens.borderColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 0,
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(
        backgroundColor: DeliveryTokens.dividerColor,
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildDriversColumn() {
    return Container(
      margin: const EdgeInsets.all(DeliveryTokens.spacingLg),
      decoration: BoxDecoration(
        color: DeliveryTokens.cardBackground,
        borderRadius: BorderRadius.circular(DeliveryTokens.radiusXl),
        boxShadow: DeliveryTokens.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(DeliveryTokens.spacingLg),
            child: Row(
              children: [
                const Icon(Icons.person, size: 18, color: Color(0xFFA855F7)),
                const SizedBox(width: 8),
                const Text('Drivers', style: DeliveryTokens.headingSmall),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.sort, size: 18),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<DeliveryBloc, DeliveryState>(
              builder: (context, state) {
                if (state is DeliveryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DeliveryError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 32,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load drivers',
                          style: DeliveryTokens.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                if (state is DeliveryLoaded) {
                  return ListView.separated(
                    padding: const EdgeInsets.all(DeliveryTokens.spacingLg),
                    itemCount: state.deliveryData.drivers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildDriverCard(state.deliveryData.drivers[index]),
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

  Widget _buildDriverCard(DriverEntity driver) {
    final statusColor = _getDriverStatusColor(driver.status);
    final isSelected = _selectedDriver?.id == driver.id;

    return InkWell(
      onTap: () => setState(() => _selectedDriver = driver),
      borderRadius: BorderRadius.circular(DeliveryTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(DeliveryTokens.cardPadding),
        decoration: BoxDecoration(
          color: DeliveryTokens.cardBackground,
          borderRadius: BorderRadius.circular(DeliveryTokens.radiusLg),
          border: Border.all(
            color: isSelected ? statusColor : DeliveryTokens.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  child: Text(
                    driver.name[0],
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              driver.name,
                              style: DeliveryTokens.headingSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getDriverStatusLabel(driver.status),
                            style: DeliveryTokens.labelSmall.copyWith(
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildPill(driver.role, const Color(0xFF3B82F6)),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: DeliveryTokens.textTertiary,
                          ),
                          const SizedBox(width: 2),
                          Text(driver.zone, style: DeliveryTokens.caption),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Capacity', style: DeliveryTokens.labelSmall),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          DeliveryTokens.radiusSm,
                        ),
                        child: LinearProgressIndicator(
                          value: driver.capacityPercentage,
                          backgroundColor: DeliveryTokens.dividerColor,
                          color: statusColor,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${driver.currentOrders}/${driver.maxCapacity}',
                      style: DeliveryTokens.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(
                        DeliveryTokens.radiusMd,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 12,
                              color: Color(0xFF3B82F6),
                            ),
                            const SizedBox(width: 4),
                            Text('Avg Time', style: DeliveryTokens.labelSmall),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${driver.avgTimeMinutes}m',
                          style: DeliveryTokens.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(
                        DeliveryTokens.radiusMd,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.attach_money,
                              size: 12,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 4),
                            Text('Today', style: DeliveryTokens.labelSmall),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${driver.todayEarnings.toStringAsFixed(0)}',
                          style: DeliveryTokens.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone, size: 14),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: DeliveryTokens.borderColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message, size: 14),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: DeliveryTokens.borderColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DeliveryTokens.radiusSm),
      ),
      child: Text(
        label,
        style: DeliveryTokens.labelSmall.copyWith(color: color),
      ),
    );
  }

  Color _getChannelColor(String channel) {
    switch (channel) {
      case 'website':
        return DeliveryTokens.channelWebsite;
      case 'uberEats':
        return DeliveryTokens.channelUberEats;
      case 'doorDash':
        return DeliveryTokens.channelDoorDash;
      case 'app':
        return DeliveryTokens.channelApp;
      case 'qr':
        return DeliveryTokens.channelQr;
      case 'phone':
        return DeliveryTokens.channelPhone;
      default:
        return DeliveryTokens.textSecondary;
    }
  }

  String _getChannelLabel(String channel) {
    switch (channel) {
      case 'website':
        return 'Website';
      case 'uberEats':
        return 'UberEats';
      case 'doorDash':
        return 'DoorDash';
      case 'app':
        return 'App';
      case 'qr':
        return 'QR';
      case 'phone':
        return 'Phone';
      default:
        return channel;
    }
  }

  Color _getOrderStatusColor(String status) {
    switch (status) {
      case 'ready':
        return DeliveryTokens.statusReady;
      case 'delayed':
        return DeliveryTokens.statusDelayed;
      case 'inProgress':
        return DeliveryTokens.statusInProgress;
      default:
        return DeliveryTokens.textTertiary;
    }
  }

  String _getOrderStatusLabel(String status) {
    switch (status) {
      case 'ready':
        return 'Ready';
      case 'delayed':
        return 'Delayed';
      case 'inProgress':
        return 'In Progress';
      default:
        return status;
    }
  }

  Color _getDriverStatusColor(String status) {
    switch (status) {
      case 'online':
        return DeliveryTokens.statusOnline;
      case 'busy':
        return DeliveryTokens.statusBusy;
      case 'offline':
        return DeliveryTokens.statusOffline;
      default:
        return DeliveryTokens.textTertiary;
    }
  }

  String _getDriverStatusLabel(String status) {
    switch (status) {
      case 'online':
        return 'Online';
      case 'busy':
        return 'Busy';
      case 'offline':
        return 'Offline';
      default:
        return status;
    }
  }

  void _showAssignDriverModal(OrderEntity order) {
    final state = context.read<DeliveryBloc>().state;
    if (state is! DeliveryLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Drivers not loaded yet'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _AssignDriverModal(
        order: order,
        drivers: state.deliveryData.drivers,
        onAssign: (driver) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Assigned ${driver.name} to ${order.orderNumber}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}

class _AssignDriverModal extends StatefulWidget {
  final OrderEntity order;
  final List<DriverEntity> drivers;
  final Function(DriverEntity) onAssign;

  const _AssignDriverModal({
    required this.order,
    required this.drivers,
    required this.onAssign,
  });

  @override
  State<_AssignDriverModal> createState() => _AssignDriverModalState();
}

class _AssignDriverModalState extends State<_AssignDriverModal> {
  String _searchQuery = '';
  DriverEntity? _selectedDriver;

  List<DriverEntity> get _filteredDrivers {
    return widget.drivers.where((driver) {
      if (_searchQuery.isEmpty) return true;
      return driver.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DeliveryTokens.radiusXl),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(DeliveryTokens.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Assign Driver',
                  style: DeliveryTokens.headingMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Order ${widget.order.orderNumber} - ${widget.order.customerName}',
              style: DeliveryTokens.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search drivers...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: DeliveryTokens.dividerColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DeliveryTokens.radiusMd),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.separated(
                itemCount: _filteredDrivers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final driver = _filteredDrivers[index];
                  final isSelected = _selectedDriver?.id == driver.id;
                  final canAssign = driver.isAvailable;

                  return InkWell(
                    onTap: canAssign
                        ? () => setState(() => _selectedDriver = driver)
                        : null,
                    borderRadius: BorderRadius.circular(
                      DeliveryTokens.radiusMd,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? DeliveryTokens.statusInProgress.withValues(
                                alpha: 0.1,
                              )
                            : DeliveryTokens.dividerColor,
                        borderRadius: BorderRadius.circular(
                          DeliveryTokens.radiusMd,
                        ),
                        border: isSelected
                            ? Border.all(
                                color: DeliveryTokens.statusInProgress,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: _getDriverStatusColor(
                              driver.status,
                            ).withValues(alpha: 0.1),
                            child: Text(
                              driver.name[0],
                              style: TextStyle(
                                color: _getDriverStatusColor(driver.status),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driver.name,
                                  style: DeliveryTokens.labelLarge,
                                ),
                                Text(
                                  '${driver.zone} • ${driver.currentOrders}/${driver.maxCapacity} orders',
                                  style: DeliveryTokens.caption,
                                ),
                              ],
                            ),
                          ),
                          if (canAssign)
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: DeliveryTokens.statusInProgress,
                              size: 20,
                            )
                          else
                            const Text(
                              'Full',
                              style: TextStyle(
                                color: DeliveryTokens.statusDelayed,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _selectedDriver != null
                      ? () => widget.onAssign(_selectedDriver!)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Assign Driver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getDriverStatusColor(String status) {
    switch (status) {
      case 'online':
        return DeliveryTokens.statusOnline;
      case 'busy':
        return DeliveryTokens.statusBusy;
      case 'offline':
        return DeliveryTokens.statusOffline;
      default:
        return DeliveryTokens.textTertiary;
    }
  }
}

/// Custom painter for map grid background
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw grid lines
    final gridSize = 40.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw some mock roads/paths
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Diagonal road
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.7),
      roadPaint,
    );

    // Vertical road
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
