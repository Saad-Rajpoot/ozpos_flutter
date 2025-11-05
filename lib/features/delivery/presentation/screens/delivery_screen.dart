import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/sidebar_nav.dart';
import '../../domain/entities/delivery_entities.dart';
import '../bloc/delivery_bloc.dart';
import '../bloc/delivery_event.dart';
import '../bloc/delivery_state.dart';
import '../constants/delivery_constants.dart';
import '../widgets/add_driver_modal.dart';

enum DeliveryDateFilter { today, last7Days, custom }

enum DeliveryOrderTab { ready, inProgress }

class DeliveryViewState extends Equatable {
  const DeliveryViewState({
    this.selectedDateFilter = DeliveryDateFilter.today,
    this.sourceFilter = 'All Sources',
    this.driverFilter = 'All Drivers',
    this.selectedOrderTab = DeliveryOrderTab.ready,
    this.selectedOrder,
    this.selectedDriver,
  });

  final DeliveryDateFilter selectedDateFilter;
  final String sourceFilter;
  final String driverFilter;
  final DeliveryOrderTab selectedOrderTab;
  final OrderEntity? selectedOrder;
  final DriverEntity? selectedDriver;

  DeliveryViewState copyWith({
    DeliveryDateFilter? selectedDateFilter,
    String? sourceFilter,
    String? driverFilter,
    DeliveryOrderTab? selectedOrderTab,
    OrderEntity? selectedOrder,
    bool clearSelectedOrder = false,
    DriverEntity? selectedDriver,
    bool clearSelectedDriver = false,
  }) {
    return DeliveryViewState(
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      sourceFilter: sourceFilter ?? this.sourceFilter,
      driverFilter: driverFilter ?? this.driverFilter,
      selectedOrderTab: selectedOrderTab ?? this.selectedOrderTab,
      selectedOrder:
          clearSelectedOrder ? null : (selectedOrder ?? this.selectedOrder),
      selectedDriver:
          clearSelectedDriver ? null : (selectedDriver ?? this.selectedDriver),
    );
  }

  @override
  List<Object?> get props => [
        selectedDateFilter,
        sourceFilter,
        driverFilter,
        selectedOrderTab,
        selectedOrder,
        selectedDriver,
      ];
}

class DeliveryViewCubit extends Cubit<DeliveryViewState> {
  DeliveryViewCubit() : super(const DeliveryViewState());

  void setDateFilter(DeliveryDateFilter filter) {
    emit(state.copyWith(selectedDateFilter: filter));
  }

  void setSourceFilter(String filter) {
    emit(state.copyWith(sourceFilter: filter));
  }

  void setDriverFilter(String filter) {
    emit(state.copyWith(driverFilter: filter));
  }

  void setOrderTab(DeliveryOrderTab tab) {
    emit(state.copyWith(selectedOrderTab: tab));
  }

  void selectOrder(OrderEntity? order) {
    emit(state.copyWith(selectedOrder: order));
  }

  void selectDriver(DriverEntity? driver) {
    emit(state.copyWith(selectedDriver: driver));
  }
}

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  late final DeliveryViewCubit _viewCubit;

  @override
  void initState() {
    super.initState();
    _viewCubit = DeliveryViewCubit();
    context.read<DeliveryBloc>().add(const LoadDeliveryDataEvent());
  }

  @override
  void dispose() {
    _viewCubit.close();
    super.dispose();
  }

  List<OrderEntity> _filterOrders(
    List<OrderEntity> orders,
    DeliveryOrderTab selectedTab,
  ) {
    switch (selectedTab) {
      case DeliveryOrderTab.ready:
        return orders.where((order) => order.status == 'ready').toList();
      case DeliveryOrderTab.inProgress:
        return orders
            .where(
              (order) =>
                  order.status == 'inProgress' || order.status == 'delayed',
            )
            .toList();
    }
  }

  int _readyCount(List<OrderEntity> orders) {
    return orders.where((order) => order.status == 'ready').length;
  }

  int _inProgressCount(List<OrderEntity> orders) {
    return orders
        .where(
          (order) => order.status == 'inProgress' || order.status == 'delayed',
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeliveryViewCubit>.value(
      value: _viewCubit,
      child: BlocBuilder<DeliveryViewCubit, DeliveryViewState>(
        buildWhen: (previous, current) {
          // Only rebuild if relevant view state changes
          return previous.selectedDateFilter != current.selectedDateFilter ||
              previous.sourceFilter != current.sourceFilter ||
              previous.driverFilter != current.driverFilter ||
              previous.selectedOrderTab != current.selectedOrderTab ||
              previous.selectedOrder != current.selectedOrder ||
              previous.selectedDriver != current.selectedDriver;
        },
        builder: (context, viewState) {
          return BlocBuilder<DeliveryBloc, DeliveryState>(
            buildWhen: (previous, current) {
              // Always rebuild on state type changes
              if (previous.runtimeType != current.runtimeType) {
                return true;
              }

              // For DeliveryLoaded state, only rebuild if delivery data changes
              if (previous is DeliveryLoaded && current is DeliveryLoaded) {
                return previous.deliveryData != current.deliveryData;
              }

              // For DeliveryError state, only rebuild if error message changes
              if (previous is DeliveryError && current is DeliveryError) {
                return previous.message != current.message;
              }

              return false;
            },
            builder: (context, deliveryState) {
              final deliveryData = deliveryState is DeliveryLoaded
                  ? deliveryState.deliveryData
                  : null;
              final orders = deliveryData?.orders ?? const <OrderEntity>[];
              final drivers = deliveryData?.drivers ?? const <DriverEntity>[];
              final filteredOrders =
                  _filterOrders(orders, viewState.selectedOrderTab);
              final readyCount = _readyCount(orders);
              final inProgressCount = _inProgressCount(orders);

              final scaler = MediaQuery.textScalerOf(context)
                  .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.1);
              final screenWidth = MediaQuery.of(context).size.width;
              final isDesktop = screenWidth >= 1280;
              final isTablet = screenWidth >= 901 && screenWidth < 1280;

              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: scaler),
                child: Scaffold(
                  backgroundColor: DeliveryConstants.background,
                  body: Row(
                    children: [
                      if (isDesktop || isTablet)
                        const SidebarNav(activeRoute: AppRouter.delivery),
                      Expanded(
                        child: Column(
                          children: [
                            _buildHeader(),
                            _buildKpiStrip(),
                            _buildFiltersRow(context, viewState, drivers),
                            Expanded(
                              child: isDesktop
                                  ? _build3ColumnLayout(
                                      context: context,
                                      viewState: viewState,
                                      deliveryState: deliveryState,
                                      filteredOrders: filteredOrders,
                                      readyCount: readyCount,
                                      inProgressCount: inProgressCount,
                                      drivers: drivers,
                                    )
                                  : isTablet
                                      ? _build2ColumnLayout(
                                          context: context,
                                          viewState: viewState,
                                          deliveryState: deliveryState,
                                          filteredOrders: filteredOrders,
                                          readyCount: readyCount,
                                          inProgressCount: inProgressCount,
                                          drivers: drivers,
                                        )
                                      : _build1ColumnLayout(
                                          context: context,
                                          viewState: viewState,
                                          deliveryState: deliveryState,
                                          filteredOrders: filteredOrders,
                                          readyCount: readyCount,
                                          inProgressCount: inProgressCount,
                                        ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(DeliveryConstants.spacingXl),
      decoration: const BoxDecoration(
        color: DeliveryConstants.cardBackground,
        border: Border(
          bottom: BorderSide(color: DeliveryConstants.borderColor),
        ),
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
                    style: DeliveryConstants.headingLarge,
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Real-time delivery tracking and driver coordination',
                style: DeliveryConstants.bodySmall,
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
        foregroundColor:
            isPrimary ? Colors.white : DeliveryConstants.textPrimary,
        side: isPrimary
            ? null
            : const BorderSide(color: DeliveryConstants.borderColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
      ),
    );
  }

  Widget _buildKpiStrip() {
    return BlocBuilder<DeliveryBloc, DeliveryState>(
      buildWhen: (previous, current) {
        // Always rebuild on state type changes
        if (previous.runtimeType != current.runtimeType) {
          return true;
        }

        // For DeliveryLoaded state, only rebuild if KPI data changes
        if (previous is DeliveryLoaded && current is DeliveryLoaded) {
          return previous.deliveryData.kpiData != current.deliveryData.kpiData;
        }

        // For DeliveryError state, only rebuild if error message changes
        if (previous is DeliveryError && current is DeliveryError) {
          return previous.message != current.message;
        }

        return false;
      },
      builder: (context, state) {
        if (state is DeliveryLoading) {
          return Container(
            padding: const EdgeInsets.all(DeliveryConstants.spacingXl),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DeliveryError) {
          return Container(
            padding: const EdgeInsets.all(DeliveryConstants.spacingXl),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load data',
                    style: DeliveryConstants.headingSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message, style: DeliveryConstants.bodySmall),
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
            padding: const EdgeInsets.all(DeliveryConstants.spacingXl),
            child: Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    'Active Drivers',
                    '${kpis.activeDrivers}',
                    Icons.people,
                    DeliveryConstants.kpiActiveDriversStart,
                    DeliveryConstants.kpiActiveDriversEnd,
                  ),
                ),
                const SizedBox(width: DeliveryConstants.spacingLg),
                Expanded(
                  child: _buildKpiCard(
                    'In Progress',
                    '${kpis.inProgress}',
                    Icons.local_shipping,
                    DeliveryConstants.kpiInProgressStart,
                    DeliveryConstants.kpiInProgressEnd,
                  ),
                ),
                const SizedBox(width: DeliveryConstants.spacingLg),
                Expanded(
                  child: _buildKpiCard(
                    'Delayed Orders',
                    '${kpis.delayedOrders}',
                    Icons.access_time,
                    DeliveryConstants.kpiDelayedStart,
                    DeliveryConstants.kpiDelayedEnd,
                  ),
                ),
                const SizedBox(width: DeliveryConstants.spacingLg),
                Expanded(
                  child: _buildKpiCard(
                    'Avg ETA',
                    '${kpis.avgEtaMinutes}m',
                    Icons.schedule,
                    DeliveryConstants.kpiAvgEtaStart,
                    DeliveryConstants.kpiAvgEtaEnd,
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
      height: DeliveryConstants.kpiHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DeliveryConstants.radiusXl),
        boxShadow: DeliveryConstants.cardShadow,
      ),
      padding: const EdgeInsets.all(DeliveryConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: DeliveryConstants.kpiLabel),
              const Spacer(),
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 28),
            ],
          ),
          const Spacer(),
          Text(value, style: DeliveryConstants.kpiValue),
        ],
      ),
    );
  }

  Widget _buildFiltersRow(
    BuildContext context,
    DeliveryViewState viewState,
    List<DriverEntity> drivers,
  ) {
    final viewCubit = context.read<DeliveryViewCubit>();
    final sourceOptions = const [
      'All Sources',
      'Website',
      'UberEats',
      'DoorDash',
      'App',
    ];
    final driverOptions = [
      'All Drivers',
      ...drivers.map((driver) => driver.name),
    ];
    final driverValue = driverOptions.contains(viewState.driverFilter)
        ? viewState.driverFilter
        : driverOptions.first;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DeliveryConstants.spacingXl,
        vertical: DeliveryConstants.spacingMd,
      ),
      decoration: const BoxDecoration(
        color: DeliveryConstants.cardBackground,
        border: Border(
          bottom: BorderSide(color: DeliveryConstants.borderColor),
        ),
      ),
      child: Row(
        children: [
          _buildFilterChip(
            'Today',
            viewState.selectedDateFilter == DeliveryDateFilter.today,
            () => viewCubit.setDateFilter(DeliveryDateFilter.today),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Last 7 days',
            viewState.selectedDateFilter == DeliveryDateFilter.last7Days,
            () => viewCubit.setDateFilter(DeliveryDateFilter.last7Days),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Custom',
            viewState.selectedDateFilter == DeliveryDateFilter.custom,
            () => viewCubit.setDateFilter(DeliveryDateFilter.custom),
          ),
          const SizedBox(width: 24),
          _buildDropdownFilter(
            viewState.sourceFilter,
            sourceOptions,
            (val) {
              if (val != null) {
                viewCubit.setSourceFilter(val);
              }
            },
          ),
          const SizedBox(width: 12),
          _buildDropdownFilter(
            driverValue,
            driverOptions,
            (val) {
              if (val != null) {
                viewCubit.setDriverFilter(val);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DeliveryConstants.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? DeliveryConstants.textPrimary
              : DeliveryConstants.cardBackground,
          borderRadius: BorderRadius.circular(DeliveryConstants.radiusFull),
          border: Border.all(
            color: isSelected
                ? DeliveryConstants.textPrimary
                : DeliveryConstants.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : DeliveryConstants.textSecondary,
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
        color: DeliveryConstants.cardBackground,
        borderRadius: BorderRadius.circular(DeliveryConstants.radiusMd),
        border: Border.all(color: DeliveryConstants.borderColor),
      ),
      child: DropdownButton<String>(
        value: value,
        items: options
            .map(
              (opt) => DropdownMenuItem(
                value: opt,
                child: Text(opt, style: DeliveryConstants.bodySmall),
              ),
            )
            .toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
        isDense: true,
      ),
    );
  }

  Widget _build3ColumnLayout({
    required BuildContext context,
    required DeliveryViewState viewState,
    required DeliveryState deliveryState,
    required List<OrderEntity> filteredOrders,
    required int readyCount,
    required int inProgressCount,
    required List<DriverEntity> drivers,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildMapColumn(context, viewState, drivers),
        ),
        Expanded(
          flex: 3,
          child: _buildOrdersColumn(
            context: context,
            deliveryState: deliveryState,
            viewState: viewState,
            filteredOrders: filteredOrders,
            readyCount: readyCount,
            inProgressCount: inProgressCount,
          ),
        ),
        SizedBox(
          width: 380,
          child: _buildDriversColumn(
            context,
            viewState,
            deliveryState,
            drivers,
          ),
        ),
      ],
    );
  }

  Widget _build2ColumnLayout({
    required BuildContext context,
    required DeliveryViewState viewState,
    required DeliveryState deliveryState,
    required List<OrderEntity> filteredOrders,
    required int readyCount,
    required int inProgressCount,
    required List<DriverEntity> drivers,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildMapColumn(context, viewState, drivers),
        ),
        Expanded(
          flex: 3,
          child: _buildOrdersColumn(
            context: context,
            deliveryState: deliveryState,
            viewState: viewState,
            filteredOrders: filteredOrders,
            readyCount: readyCount,
            inProgressCount: inProgressCount,
          ),
        ),
      ],
    );
  }

  Widget _build1ColumnLayout({
    required BuildContext context,
    required DeliveryViewState viewState,
    required DeliveryState deliveryState,
    required List<OrderEntity> filteredOrders,
    required int readyCount,
    required int inProgressCount,
  }) {
    return _buildOrdersColumn(
      context: context,
      deliveryState: deliveryState,
      viewState: viewState,
      filteredOrders: filteredOrders,
      readyCount: readyCount,
      inProgressCount: inProgressCount,
    );
  }

  Widget _buildMapColumn(
    BuildContext context,
    DeliveryViewState viewState,
    List<DriverEntity> drivers,
  ) {
    return Container(
      margin: const EdgeInsets.all(DeliveryConstants.spacingLg),
      decoration: BoxDecoration(
        color: DeliveryConstants.cardBackground,
        borderRadius: BorderRadius.circular(DeliveryConstants.radiusXl),
        boxShadow: DeliveryConstants.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(DeliveryConstants.spacingLg),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 8),
                const Text('Live Map', style: DeliveryConstants.headingSmall),
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
                bottomLeft: Radius.circular(DeliveryConstants.radiusXl),
                bottomRight: Radius.circular(DeliveryConstants.radiusXl),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE8F5E9),
                          Color(0xFFC8E6C9),
                        ],
                      ),
                    ),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _MapGridPainter(),
                    ),
                  ),
                  ...drivers.map(
                    (driver) => _buildDriverMarker(
                      context,
                      driver,
                      viewState,
                    ),
                  ),
                  if (viewState.selectedOrder != null &&
                      viewState.selectedOrder!.assignedDriverId != null)
                    _buildRouteIndicator(viewState.selectedOrder!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverMarker(
    BuildContext context,
    DriverEntity driver,
    DeliveryViewState viewState,
  ) {
    final position = _calculateMarkerPosition(
      driver.latitude,
      driver.longitude,
    );
    final statusColor = _getDriverStatusColor(driver.status);
    final isSelected = viewState.selectedDriver?.id == driver.id;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () => context.read<DeliveryViewCubit>().selectDriver(driver),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.amber : Colors.white,
              width: isSelected ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
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
          boxShadow: DeliveryConstants.cardShadow,
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

  Widget _buildOrdersColumn({
    required BuildContext context,
    required DeliveryState deliveryState,
    required DeliveryViewState viewState,
    required List<OrderEntity> filteredOrders,
    required int readyCount,
    required int inProgressCount,
  }) {
    return Container(
      margin: const EdgeInsets.all(DeliveryConstants.spacingLg),
      decoration: BoxDecoration(
        color: DeliveryConstants.cardBackground,
        borderRadius: BorderRadius.circular(DeliveryConstants.radiusXl),
        boxShadow: DeliveryConstants.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(DeliveryConstants.spacingLg),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_bag,
                  size: 18,
                  color: Color(0xFFF97316),
                ),
                const SizedBox(width: 8),
                const Text('Orders', style: DeliveryConstants.headingSmall),
                const Spacer(),
                _buildTabChip(
                  'Ready',
                  readyCount,
                  viewState.selectedOrderTab == DeliveryOrderTab.ready,
                  () => context
                      .read<DeliveryViewCubit>()
                      .setOrderTab(DeliveryOrderTab.ready),
                ),
                const SizedBox(width: 8),
                _buildTabChip(
                  'In Progress',
                  inProgressCount,
                  viewState.selectedOrderTab == DeliveryOrderTab.inProgress,
                  () => context
                      .read<DeliveryViewCubit>()
                      .setOrderTab(DeliveryOrderTab.inProgress),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: () {
              if (deliveryState is DeliveryLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (deliveryState is DeliveryError) {
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
                        style: DeliveryConstants.bodySmall,
                      ),
                    ],
                  ),
                );
              }

              if (deliveryState is DeliveryLoaded) {
                if (filteredOrders.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(DeliveryConstants.spacingLg),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildOrderCard(
                    context,
                    filteredOrders[index],
                    viewState,
                  ),
                );
              }

              return const SizedBox.shrink();
            }(),
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
      borderRadius: BorderRadius.circular(DeliveryConstants.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? DeliveryConstants.statusInProgress.withOpacity(0.1)
              : DeliveryConstants.dividerColor,
          borderRadius: BorderRadius.circular(DeliveryConstants.radiusFull),
        ),
        child: Text(
          '$label   $count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? DeliveryConstants.statusInProgress
                : DeliveryConstants.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderEntity order,
    DeliveryViewState viewState,
  ) {
    final isSelected = viewState.selectedOrder?.id == order.id;
    final channelColor = _getChannelColor(order.channel);
    final statusColor = _getOrderStatusColor(order.status);

    return InkWell(
      onTap: () => context.read<DeliveryViewCubit>().selectOrder(order),
      borderRadius: BorderRadius.circular(DeliveryConstants.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(DeliveryConstants.cardPadding),
        decoration: BoxDecoration(
          color: DeliveryConstants.cardBackground,
          borderRadius: BorderRadius.circular(DeliveryConstants.radiusLg),
          border: Border.all(
            color: isSelected
                ? DeliveryConstants.statusInProgress
                : DeliveryConstants.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(order.orderNumber, style: DeliveryConstants.headingSmall),
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
                  color: DeliveryConstants.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(order.customerName, style: DeliveryConstants.bodyMedium),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: DeliveryConstants.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.address,
                    style: DeliveryConstants.bodySmall,
                  ),
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
                  color: DeliveryConstants.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  order.items.join(', '),
                  style: DeliveryConstants.bodySmall,
                ),
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
        borderRadius: BorderRadius.circular(DeliveryConstants.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, size: 14),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: DeliveryConstants.labelSmall),
              Text(value, style: DeliveryConstants.labelLarge),
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
        foregroundColor:
            isPrimary ? Colors.white : DeliveryConstants.textPrimary,
        side: isPrimary
            ? null
            : const BorderSide(color: DeliveryConstants.borderColor),
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
        backgroundColor: DeliveryConstants.dividerColor,
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildDriversColumn(
    BuildContext context,
    DeliveryViewState viewState,
    DeliveryState deliveryState,
    List<DriverEntity> drivers,
  ) {
    return Container(
      margin: const EdgeInsets.all(DeliveryConstants.spacingLg),
      decoration: BoxDecoration(
        color: DeliveryConstants.cardBackground,
        borderRadius: BorderRadius.circular(DeliveryConstants.radiusXl),
        boxShadow: DeliveryConstants.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(DeliveryConstants.spacingLg),
            child: Row(
              children: [
                const Icon(Icons.person, size: 18, color: Color(0xFFA855F7)),
                const SizedBox(width: 8),
                const Text('Drivers', style: DeliveryConstants.headingSmall),
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
            child: () {
              if (deliveryState is DeliveryLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (deliveryState is DeliveryError) {
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
                        style: DeliveryConstants.bodySmall,
                      ),
                    ],
                  ),
                );
              }

              if (deliveryState is DeliveryLoaded) {
                return ListView.separated(
                  padding: const EdgeInsets.all(DeliveryConstants.spacingLg),
                  itemCount: drivers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildDriverCard(
                    context,
                    drivers[index],
                    viewState,
                  ),
                );
              }

              return const SizedBox.shrink();
            }(),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(
    BuildContext context,
    DriverEntity driver,
    DeliveryViewState viewState,
  ) {
    final statusColor = _getDriverStatusColor(driver.status);
    final isSelected = viewState.selectedDriver?.id == driver.id;

    return InkWell(
      onTap: () => context.read<DeliveryViewCubit>().selectDriver(driver),
      borderRadius: BorderRadius.circular(DeliveryConstants.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(DeliveryConstants.cardPadding),
        decoration: BoxDecoration(
          color: DeliveryConstants.cardBackground,
          borderRadius: BorderRadius.circular(DeliveryConstants.radiusLg),
          border: Border.all(
            color: isSelected ? statusColor : DeliveryConstants.borderColor,
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
                  backgroundColor: statusColor.withOpacity(0.1),
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
                              style: DeliveryConstants.headingSmall,
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
                            style: DeliveryConstants.labelSmall.copyWith(
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
                            color: DeliveryConstants.textTertiary,
                          ),
                          const SizedBox(width: 2),
                          Text(driver.zone, style: DeliveryConstants.caption),
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
                Text('Order Capacity', style: DeliveryConstants.labelSmall),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          DeliveryConstants.radiusSm,
                        ),
                        child: LinearProgressIndicator(
                          value: driver.capacityPercentage,
                          backgroundColor: DeliveryConstants.dividerColor,
                          color: statusColor,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${driver.currentOrders}/${driver.maxCapacity}',
                      style: DeliveryConstants.labelMedium,
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
                        DeliveryConstants.radiusMd,
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
                            Text(
                              'Avg Time',
                              style: DeliveryConstants.labelSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${driver.avgTimeMinutes}m',
                          style: DeliveryConstants.labelLarge,
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
                        DeliveryConstants.radiusMd,
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
                            Text('Today', style: DeliveryConstants.labelSmall),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${driver.todayEarnings.toStringAsFixed(0)}',
                          style: DeliveryConstants.labelLarge,
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
                      side: const BorderSide(
                        color: DeliveryConstants.borderColor,
                      ),
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
                      side: const BorderSide(
                        color: DeliveryConstants.borderColor,
                      ),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DeliveryConstants.radiusSm),
      ),
      child: Text(
        label,
        style: DeliveryConstants.labelSmall.copyWith(color: color),
      ),
    );
  }

  Color _getChannelColor(String channel) {
    switch (channel) {
      case 'website':
        return DeliveryConstants.channelWebsite;
      case 'uberEats':
        return DeliveryConstants.channelUberEats;
      case 'doorDash':
        return DeliveryConstants.channelDoorDash;
      case 'app':
        return DeliveryConstants.channelApp;
      case 'qr':
        return DeliveryConstants.channelQr;
      case 'phone':
        return DeliveryConstants.channelPhone;
      default:
        return DeliveryConstants.textSecondary;
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
        return DeliveryConstants.statusReady;
      case 'delayed':
        return DeliveryConstants.statusDelayed;
      case 'inProgress':
        return DeliveryConstants.statusInProgress;
      default:
        return DeliveryConstants.textTertiary;
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

  Color _getDriverStatusColor(String status) {
    switch (status) {
      case 'online':
        return DeliveryConstants.statusOnline;
      case 'busy':
        return DeliveryConstants.statusBusy;
      case 'offline':
        return DeliveryConstants.statusOffline;
      default:
        return DeliveryConstants.textTertiary;
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
  const _AssignDriverModal({
    required this.order,
    required this.drivers,
    required this.onAssign,
  });

  final OrderEntity order;
  final List<DriverEntity> drivers;
  final ValueChanged<DriverEntity> onAssign;

  @override
  State<_AssignDriverModal> createState() => _AssignDriverModalState();
}

class _AssignDriverModalState extends State<_AssignDriverModal> {
  late final ValueNotifier<_AssignDriverModalViewState> _stateNotifier;

  @override
  void initState() {
    super.initState();
    _stateNotifier = ValueNotifier(const _AssignDriverModalViewState());
  }

  @override
  void dispose() {
    _stateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_AssignDriverModalViewState>(
      valueListenable: _stateNotifier,
      builder: (context, modalState, _) {
        final filteredDrivers = widget.drivers.where((driver) {
          if (modalState.searchQuery.isEmpty) return true;
          return driver.name
              .toLowerCase()
              .contains(modalState.searchQuery.toLowerCase());
        }).toList();

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DeliveryConstants.radiusXl),
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(DeliveryConstants.spacingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Assign Driver',
                      style: DeliveryConstants.headingMedium,
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
                  style: DeliveryConstants.bodySmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) => _stateNotifier.value =
                      modalState.copyWith(searchQuery: value),
                  decoration: InputDecoration(
                    hintText: 'Search drivers...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: DeliveryConstants.dividerColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        DeliveryConstants.radiusMd,
                      ),
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
                    itemCount: filteredDrivers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final driver = filteredDrivers[index];
                      final isSelected =
                          modalState.selectedDriver?.id == driver.id;
                      final canAssign = driver.isAvailable;

                      return InkWell(
                        onTap: canAssign
                            ? () => _stateNotifier.value =
                                modalState.copyWith(selectedDriver: driver)
                            : null,
                        borderRadius: BorderRadius.circular(
                          DeliveryConstants.radiusMd,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? DeliveryConstants.statusInProgress
                                    .withOpacity(0.1)
                                : DeliveryConstants.dividerColor,
                            borderRadius: BorderRadius.circular(
                              DeliveryConstants.radiusMd,
                            ),
                            border: isSelected
                                ? Border.all(
                                    color: DeliveryConstants.statusInProgress,
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
                                ).withOpacity(0.1),
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
                                      style: DeliveryConstants.labelLarge,
                                    ),
                                    Text(
                                      '${driver.zone} • ${driver.currentOrders}/${driver.maxCapacity} orders',
                                      style: DeliveryConstants.caption,
                                    ),
                                  ],
                                ),
                              ),
                              if (canAssign)
                                Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: DeliveryConstants.statusInProgress,
                                  size: 20,
                                )
                              else
                                const Text(
                                  'Full',
                                  style: TextStyle(
                                    color: DeliveryConstants.statusDelayed,
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
                      onPressed: modalState.selectedDriver != null
                          ? () => widget.onAssign(modalState.selectedDriver!)
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
      },
    );
  }

  Color _getDriverStatusColor(String status) {
    switch (status) {
      case 'online':
        return DeliveryConstants.statusOnline;
      case 'busy':
        return DeliveryConstants.statusBusy;
      case 'offline':
        return DeliveryConstants.statusOffline;
      default:
        return DeliveryConstants.textTertiary;
    }
  }
}

/// Custom painter for map grid background
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
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
      ..color = Colors.white.withOpacity(0.5)
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

class _AssignDriverModalViewState extends Equatable {
  const _AssignDriverModalViewState({
    this.searchQuery = '',
    this.selectedDriver,
  });

  final String searchQuery;
  final DriverEntity? selectedDriver;

  _AssignDriverModalViewState copyWith({
    String? searchQuery,
    DriverEntity? selectedDriver,
    bool clearSelectedDriver = false,
  }) {
    return _AssignDriverModalViewState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDriver:
          clearSelectedDriver ? null : (selectedDriver ?? this.selectedDriver),
    );
  }

  @override
  List<Object?> get props => [searchQuery, selectedDriver];
}
