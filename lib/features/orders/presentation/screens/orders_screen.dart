import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/sidebar_nav.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/orders_management_bloc.dart';
import '../bloc/orders_management_event.dart';
import '../bloc/orders_management_state.dart';
import '../constants/orders_constants.dart';
import '../widgets/order_card_widget.dart';

/// Standalone screen for managing orders system-wide
/// Accessible from main navigation for viewing all orders
///
/// Note: This screen is wrapped with BlocProvider in AppRouter
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.1);
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scaler),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: Row(
          children: [
            if (isDesktop) const SidebarNav(activeRoute: AppRouter.orders),
            Expanded(
              child: BlocProvider(
                create: (_) => OrdersViewCubit(),
                child: const _OrdersView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersView extends StatelessWidget {
  const _OrdersView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _Header(),
        Expanded(child: _OrdersContent()),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: OrdersConstants.colorBorder)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(OrdersConstants.paddingHeader),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Management',
                        style: OrdersConstants.headingLarge.copyWith(
                          color: OrdersConstants.colorTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track and manage all your orders in real-time',
                        style: OrdersConstants.bodySmall.copyWith(
                          color: OrdersConstants.colorTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 300, child: _SearchBar()),
                const SizedBox(width: 16),
                const _Tabs(),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<OrdersManagementBloc>().add(
                          const LoadOrdersEvent(),
                        );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: OrdersConstants.colorBorder),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _KPICards(),
            const SizedBox(height: 16),
            const _FilterChips(),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) =>
          context.read<OrdersViewCubit>().updateSearchQuery(value.trim()),
      decoration: InputDecoration(
        hintText: 'Search orders...',
        hintStyle: OrdersConstants.bodyMedium.copyWith(
          color: OrdersConstants.colorTextMuted,
        ),
        prefixIcon: const Icon(Icons.search, size: 16),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: OrdersConstants.colorBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: OrdersConstants.colorBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: OrdersConstants.colorKpiActiveStart,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs();

  @override
  Widget build(BuildContext context) {
    final blocState = context.watch<OrdersManagementBloc>().state;
    final stats = _computeStats(blocState);
    final viewState = context.watch<OrdersViewCubit>().state;

    Widget buildTab({
      required String label,
      required IconData icon,
      required int count,
      required OrderStatus status,
    }) {
      final isActive = viewState.activeTab == status;
      return InkWell(
        onTap: () => context.read<OrdersViewCubit>().setActiveTab(status),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive ? OrdersConstants.shadowCard : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive
                    ? OrdersConstants.colorTextPrimary
                    : OrdersConstants.colorTextMuted,
              ),
              const SizedBox(width: 6),
              Text(
                '$label ($count)',
                style: OrdersConstants.bodySmall.copyWith(
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? OrdersConstants.colorTextPrimary
                      : OrdersConstants.colorTextMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: OrdersConstants.colorBgSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTab(
            label: 'Active',
            icon: Icons.access_time,
            count: stats.active,
            status: OrderStatus.active,
          ),
          const SizedBox(width: 4),
          buildTab(
            label: 'Completed',
            icon: Icons.check_circle,
            count: stats.completed,
            status: OrderStatus.completed,
          ),
          const SizedBox(width: 4),
          buildTab(
            label: 'Cancelled',
            icon: Icons.cancel,
            count: stats.cancelled,
            status: OrderStatus.cancelled,
          ),
        ],
      ),
    );
  }
}

class _KPICards extends StatelessWidget {
  const _KPICards();

  @override
  Widget build(BuildContext context) {
    final stats = _computeStats(context.watch<OrdersManagementBloc>().state);

    return Row(
      children: [
        Expanded(
          child: _KPICard(
            label: 'Active Orders',
            value: '${stats.active}',
            icon: Icons.access_time,
            gradientColors: const [
              OrdersConstants.colorKpiActiveStart,
              OrdersConstants.colorKpiActiveEnd,
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KPICard(
            label: 'Completed',
            value: '${stats.completed}',
            icon: Icons.check_circle,
            gradientColors: const [
              OrdersConstants.colorKpiCompletedStart,
              OrdersConstants.colorKpiCompletedEnd,
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KPICard(
            label: 'Cancelled',
            value: '${stats.cancelled}',
            icon: Icons.cancel,
            gradientColors: const [
              OrdersConstants.colorKpiCancelledStart,
              OrdersConstants.colorKpiCancelledEnd,
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KPICard(
            label: 'Revenue',
            value: '\$${stats.revenue.toStringAsFixed(0)}',
            icon: Icons.trending_up,
            gradientColors: const [
              OrdersConstants.colorKpiRevenueStart,
              OrdersConstants.colorKpiRevenueEnd,
            ],
          ),
        ),
      ],
    );
  }
}

class _KPICard extends StatelessWidget {
  const _KPICard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradientColors,
  });

  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(12),
        boxShadow: OrdersConstants.shadowCard,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: OrdersConstants.caption.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    final viewState = context.watch<OrdersViewCubit>().state;
    final viewCubit = context.read<OrdersViewCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'CHANNELS:',
              textAlign: TextAlign.center,
              style: OrdersConstants.caption.copyWith(
                color: OrdersConstants.colorTextMuted,
              ),
            ),
            _ChannelFilterChip(
              label: 'All',
              isSelected: viewState.selectedChannels.isEmpty,
              onTap: viewCubit.clearChannels,
              gradient: const [Colors.black87, Colors.black87],
            ),
            ...OrderChannel.values.map((channel) {
              return _ChannelFilterChip(
                label: '${channel.emoji} ${channel.name}',
                isSelected: viewState.selectedChannels.contains(channel),
                onTap: () => viewCubit.toggleChannel(channel),
                gradient: _getChannelGradient(channel),
              );
            }),
          ],
        ),
      ],
    );
  }
}

class _ChannelFilterChip extends StatelessWidget {
  const _ChannelFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.gradient,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(OrdersConstants.chipRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: gradient) : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(OrdersConstants.chipRadius),
          border: Border.all(
            color:
                isSelected ? Colors.transparent : OrdersConstants.colorBorder,
          ),
          boxShadow: OrdersConstants.shadowCard,
        ),
        child: Text(
          label,
          style: OrdersConstants.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : OrdersConstants.colorTextPrimary,
          ),
        ),
      ),
    );
  }
}

class _OrdersContent extends StatelessWidget {
  const _OrdersContent();

  @override
  Widget build(BuildContext context) {
    final viewState = context.watch<OrdersViewCubit>().state;

    return BlocBuilder<OrdersManagementBloc, OrdersManagementState>(
      buildWhen: (previous, current) {
        // Always rebuild on state type changes (Loading/Error/Loaded)
        if (previous.runtimeType != current.runtimeType) {
          return true;
        }

        // For OrdersManagementLoaded state, only rebuild if orders list changes
        if (previous is OrdersManagementLoaded &&
            current is OrdersManagementLoaded) {
          return previous.orders != current.orders;
        }

        // For OrdersManagementError state, only rebuild if error message changes
        if (previous is OrdersManagementError &&
            current is OrdersManagementError) {
          return previous.message != current.message;
        }

        return false;
      },
      builder: (context, blocState) {
        if (blocState is OrdersManagementLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (blocState is OrdersManagementError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error: ${blocState.message}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<OrdersManagementBloc>().add(
                          const LoadOrdersEvent(),
                        );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (blocState is OrdersManagementLoaded) {
          final filtered = _filterOrders(blocState.orders, viewState);
          if (filtered.isEmpty) {
            return _buildEmptyState();
          }
          return _buildOrdersGrid(context, filtered);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _OrdersStats {
  const _OrdersStats({
    this.active = 0,
    this.completed = 0,
    this.cancelled = 0,
    this.revenue = 0.0,
  });

  final int active;
  final int completed;
  final int cancelled;
  final double revenue;
}

_OrdersStats _computeStats(OrdersManagementState state) {
  if (state is! OrdersManagementLoaded) {
    return const _OrdersStats();
  }

  final orders = state.orders;
  final active = orders.where((o) => o.status == OrderStatus.active).length;
  final completed =
      orders.where((o) => o.status == OrderStatus.completed).length;
  final cancelled =
      orders.where((o) => o.status == OrderStatus.cancelled).length;
  final revenue = orders
      .where((o) => o.status == OrderStatus.completed)
      .fold<double>(0.0, (sum, o) => sum + o.total);

  return _OrdersStats(
    active: active,
    completed: completed,
    cancelled: cancelled,
    revenue: revenue,
  );
}

List<OrderEntity> _filterOrders(
  List<OrderEntity> orders,
  OrdersViewState viewState,
) {
  final query = viewState.searchQuery.toLowerCase();
  return orders.where((order) {
    if (order.status != viewState.activeTab) return false;

    if (viewState.selectedChannels.isNotEmpty &&
        !viewState.selectedChannels.contains(order.channel)) {
      return false;
    }

    if (query.isNotEmpty) {
      final phone = order.customerPhone?.toLowerCase() ?? '';
      final queue = order.queueNumber.toLowerCase();
      return order.id.toLowerCase().contains(query) ||
          order.customerName.toLowerCase().contains(query) ||
          phone.contains(query) ||
          queue.contains(query);
    }

    return true;
  }).toList();
}

Widget _buildOrdersGrid(BuildContext context, List<OrderEntity> orders) {
  final width = MediaQuery.of(context).size.width;
  final crossAxisCount = _getCrossAxisCount(width);

  return GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: OrdersConstants.gapBetweenCards,
      mainAxisSpacing: OrdersConstants.gapBetweenCards,
      childAspectRatio: 0.95,
    ),
    itemCount: orders.length,
    itemBuilder: (context, index) {
      return OrderCardWidget(order: orders[index]);
    },
  );
}

int _getCrossAxisCount(double width) {
  if (width >= OrdersConstants.breakpointDesktop) return 4;
  if (width >= OrdersConstants.breakpointTablet) return 3;
  if (width >= OrdersConstants.breakpointMobile) return 2;
  return 1;
}

Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
            ),
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(
            Icons.shopping_bag,
            size: 40,
            color: OrdersConstants.colorTextMuted,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No orders found',
          style: OrdersConstants.headingSmall.copyWith(
            color: OrdersConstants.colorTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Try adjusting your filters or search terms',
          style: OrdersConstants.bodyMedium.copyWith(
            color: OrdersConstants.colorTextMuted,
          ),
        ),
      ],
    ),
  );
}

List<Color> _getChannelGradient(OrderChannel channel) {
  switch (channel) {
    case OrderChannel.ubereats:
      return [
        OrdersConstants.colorUberEatsStart,
        OrdersConstants.colorUberEatsEnd,
      ];
    case OrderChannel.doordash:
      return [
        OrdersConstants.colorDoorDashStart,
        OrdersConstants.colorDoorDashEnd,
      ];
    case OrderChannel.menulog:
      return [
        OrdersConstants.colorMenulogStart,
        OrdersConstants.colorMenulogEnd,
      ];
    case OrderChannel.website:
      return [
        OrdersConstants.colorWebsiteStart,
        OrdersConstants.colorWebsiteEnd,
      ];
    case OrderChannel.app:
      return [OrdersConstants.colorAppStart, OrdersConstants.colorAppEnd];
    case OrderChannel.qr:
      return [OrdersConstants.colorQrStart, OrdersConstants.colorQrEnd];
    case OrderChannel.dinein:
      return [
        OrdersConstants.colorDineInStart,
        OrdersConstants.colorDineInEnd,
      ];
    case OrderChannel.takeaway:
      return [
        OrdersConstants.colorTakeawayStart,
        OrdersConstants.colorTakeawayEnd,
      ];
  }
}

class OrdersViewState extends Equatable {
  OrdersViewState({
    this.searchQuery = '',
    this.activeTab = OrderStatus.active,
    Set<OrderChannel>? selectedChannels,
  }) : selectedChannels = Set<OrderChannel>.unmodifiable(
            selectedChannels ?? const <OrderChannel>{});

  final String searchQuery;
  final OrderStatus activeTab;
  final Set<OrderChannel> selectedChannels;

  OrdersViewState copyWith({
    String? searchQuery,
    OrderStatus? activeTab,
    Set<OrderChannel>? selectedChannels,
    bool clearSelectedChannels = false,
  }) {
    final updatedChannels = clearSelectedChannels
        ? <OrderChannel>{}
        : Set<OrderChannel>.from(selectedChannels ?? this.selectedChannels);

    return OrdersViewState(
      searchQuery: searchQuery ?? this.searchQuery,
      activeTab: activeTab ?? this.activeTab,
      selectedChannels: updatedChannels,
    );
  }

  @override
  List<Object?> get props => [
        searchQuery,
        activeTab,
        List<OrderChannel>.from(selectedChannels)
          ..sort((a, b) => a.index.compareTo(b.index)),
      ];
}

class OrdersViewCubit extends Cubit<OrdersViewState> {
  OrdersViewCubit() : super(OrdersViewState());

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setActiveTab(OrderStatus status) {
    emit(state.copyWith(activeTab: status));
  }

  void toggleChannel(OrderChannel channel) {
    final updated = Set<OrderChannel>.from(state.selectedChannels);
    if (!updated.add(channel)) {
      updated.remove(channel);
    }
    emit(state.copyWith(selectedChannels: updated));
  }

  void clearChannels() {
    emit(state.copyWith(clearSelectedChannels: true));
  }
}
