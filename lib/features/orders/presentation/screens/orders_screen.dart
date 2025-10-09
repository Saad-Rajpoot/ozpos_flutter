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
  String _searchQuery = '';
  OrderStatus _activeTab = OrderStatus.active;
  final Set<OrderChannel> _selectedChannels = {};

  List<OrderEntity> get _filteredOrders {
    final bloc = context.watch<OrdersManagementBloc>();
    final state = bloc.state;

    if (state is OrdersManagementLoaded) {
      return state.orders.where((order) {
        // Tab filter
        if (order.status != _activeTab) return false;

        // Channel filter
        if (_selectedChannels.isNotEmpty &&
            !_selectedChannels.contains(order.channel)) {
          return false;
        }

        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          return order.id.toLowerCase().contains(query) ||
              order.customerName.toLowerCase().contains(query) ||
              (order.customerPhone?.contains(query) ?? false) ||
              order.queueNumber.contains(query);
        }

        return true;
      }).toList();
    }

    return [];
  }

  Map<String, dynamic> get _stats {
    final bloc = context.watch<OrdersManagementBloc>();
    final state = bloc.state;

    if (state is OrdersManagementLoaded) {
      final orders = state.orders;

      if (orders.isEmpty) {
        return {'active': 0, 'completed': 0, 'cancelled': 0, 'revenue': 0.0};
      }

      final active = orders.where((o) => o.status == OrderStatus.active).length;
      final completed = orders
          .where((o) => o.status == OrderStatus.completed)
          .length;
      final cancelled = orders
          .where((o) => o.status == OrderStatus.cancelled)
          .length;
      final revenue = orders
          .where((o) => o.status == OrderStatus.completed)
          .fold<double>(0.0, (sum, o) => sum + o.total);

      return {
        'active': active,
        'completed': completed,
        'cancelled': cancelled,
        'revenue': revenue,
      };
    }

    return {'active': 0, 'completed': 0, 'cancelled': 0, 'revenue': 0.0};
  }

  @override
  Widget build(BuildContext context) {
    // Clamp text scaling
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
            // Sidebar navigation (only on desktop)
            if (isDesktop) const SidebarNav(activeRoute: AppRouter.orders),

            // Main content
            Expanded(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(child: _buildOrdersContent(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            // Title row
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
                // Search bar
                SizedBox(width: 300, child: _buildSearchBar()),
                const SizedBox(width: 16),

                // Tabs
                _buildTabs(),
                const SizedBox(width: 16),

                // refresh orders
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

            // KPI Cards
            _buildKPICards(context),
            const SizedBox(height: 16),

            // Filter chips
            _buildFilterChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICards(BuildContext context) {
    final stats = _stats;

    return Row(
      children: [
        Expanded(
          child: _buildKPICard(
            label: 'Active Orders',
            value: '${stats['active']}',
            icon: Icons.access_time,
            gradientColors: const [
              OrdersConstants.colorKpiActiveStart,
              OrdersConstants.colorKpiActiveEnd,
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKPICard(
            label: 'Completed',
            value: '${stats['completed']}',
            icon: Icons.check_circle,
            gradientColors: const [
              OrdersConstants.colorKpiCompletedStart,
              OrdersConstants.colorKpiCompletedEnd,
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKPICard(
            label: 'Cancelled',
            value: '${stats['cancelled']}',
            icon: Icons.cancel,
            gradientColors: const [
              OrdersConstants.colorKpiCancelledStart,
              OrdersConstants.colorKpiCancelledEnd,
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKPICard(
            label: 'Revenue',
            value: '\$${stats['revenue'].toStringAsFixed(0)}',
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

  Widget _buildOrdersContent(BuildContext context) {
    return BlocBuilder<OrdersManagementBloc, OrdersManagementState>(
      builder: (context, state) {
        if (state is OrdersManagementLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is OrdersManagementError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.message}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<OrdersManagementBloc>().add(
                      const LoadOrdersEvent(),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is OrdersManagementLoaded) {
          if (_filteredOrders.isEmpty) {
            return _buildEmptyState();
          }

          return _buildOrdersGrid(context, _filteredOrders);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
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

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: OrdersConstants.colorBgSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTab(
            label: 'Active',
            icon: Icons.access_time,
            count: _stats['active'] as int,
            status: OrderStatus.active,
          ),
          const SizedBox(width: 4),
          _buildTab(
            label: 'Completed',
            icon: Icons.check_circle,
            count: _stats['completed'] as int,
            status: OrderStatus.completed,
          ),
          const SizedBox(width: 4),
          _buildTab(
            label: 'Cancelled',
            icon: Icons.cancel,
            count: _stats['cancelled'] as int,
            status: OrderStatus.cancelled,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required int count,
    required OrderStatus status,
  }) {
    final isActive = _activeTab == status;

    return InkWell(
      onTap: () => setState(() => _activeTab = status),
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

  Widget _buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Channel filters
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
            _buildFilterChip(
              label: 'All',
              isSelected: _selectedChannels.isEmpty,
              onTap: () => setState(() => _selectedChannels.clear()),
              gradient: const [Colors.black87, Colors.black87],
            ),
            ...OrderChannel.values.map((channel) {
              return _buildFilterChip(
                label: '${channel.emoji} ${channel.name}',
                isSelected: _selectedChannels.contains(channel),
                onTap: () {
                  setState(() {
                    if (_selectedChannels.contains(channel)) {
                      _selectedChannels.remove(channel);
                    } else {
                      _selectedChannels.add(channel);
                    }
                  });
                },
                gradient: _getChannelGradient(channel),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required List<Color> gradient,
  }) {
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
            color: isSelected
                ? Colors.transparent
                : OrdersConstants.colorBorder,
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

  Widget _buildKPICard({
    required String label,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
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
                    color: Colors.white.withValues(alpha: 0.9),
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
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
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
}
