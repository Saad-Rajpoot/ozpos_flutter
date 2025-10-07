import 'package:flutter/material.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/sidebar_nav.dart';
import '../../../pos/data/datasources/mock_orders_data.dart';
import '../../../pos/domain/entities/order_entity.dart';
import '../orders_tokens.dart';
import '../widgets/order_card_widget.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final List<OrderEntity> _allOrders = MockOrdersData.getMockOrders();

  String _searchQuery = '';
  OrderStatus _activeTab = OrderStatus.active;
  final Set<OrderChannel> _selectedChannels = {};
  bool _viewModeGrid = true;

  List<OrderEntity> get _filteredOrders {
    return _allOrders.where((order) {
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

  Map<String, dynamic> get _stats {
    final active = _allOrders
        .where((o) => o.status == OrderStatus.active)
        .length;
    final completed = _allOrders
        .where((o) => o.status == OrderStatus.completed)
        .length;
    final cancelled = _allOrders
        .where((o) => o.status == OrderStatus.cancelled)
        .length;
    final revenue = _allOrders
        .where((o) => o.status == OrderStatus.completed)
        .fold<double>(0.0, (sum, o) => sum + o.total);

    return {
      'active': active,
      'completed': completed,
      'cancelled': cancelled,
      'revenue': revenue,
    };
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
                  _buildHeader(),
                  Expanded(child: _buildOrdersGrid()),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: OrdersTokens.colorBorder)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(OrdersTokens.paddingHeader),
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
                        style: OrdersTokens.headingLarge.copyWith(
                          color: OrdersTokens.colorTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track and manage all your orders in real-time',
                        style: OrdersTokens.bodySmall.copyWith(
                          color: OrdersTokens.colorTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // View toggle and refresh
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: OrdersTokens.colorBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _buildToggleButton(
                            icon: Icons.grid_view,
                            isActive: _viewModeGrid,
                            onTap: () => setState(() => _viewModeGrid = true),
                          ),
                          _buildToggleButton(
                            icon: Icons.view_list,
                            isActive: !_viewModeGrid,
                            onTap: () => setState(() => _viewModeGrid = false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => setState(() {}),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: OrdersTokens.colorBorder),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // KPI Cards
            _buildKPICards(),
            const SizedBox(height: 16),

            // Search bar
            _buildSearchBar(),
            const SizedBox(height: 16),

            // Tabs
            _buildTabs(),
            const SizedBox(height: 16),

            // Filter chips
            _buildFilterChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? Colors.white : OrdersTokens.colorTextMuted,
        ),
      ),
    );
  }

  Widget _buildKPICards() {
    return Row(
      children: [
        Expanded(
          child: _buildKPICard(
            label: 'Active Orders',
            value: '${_stats['active']}',
            icon: Icons.access_time,
            gradientColors: const [
              OrdersTokens.colorKpiActiveStart,
              OrdersTokens.colorKpiActiveEnd,
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKPICard(
            label: 'Completed',
            value: '${_stats['completed']}',
            icon: Icons.check_circle,
            gradientColors: const [
              OrdersTokens.colorKpiCompletedStart,
              OrdersTokens.colorKpiCompletedEnd,
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKPICard(
            label: 'Cancelled',
            value: '${_stats['cancelled']}',
            icon: Icons.cancel,
            gradientColors: const [
              OrdersTokens.colorKpiCancelledStart,
              OrdersTokens.colorKpiCancelledEnd,
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKPICard(
            label: 'Revenue',
            value: '\$${_stats['revenue'].toStringAsFixed(0)}',
            icon: Icons.trending_up,
            gradientColors: const [
              OrdersTokens.colorKpiRevenueStart,
              OrdersTokens.colorKpiRevenueEnd,
            ],
          ),
        ),
      ],
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
        boxShadow: OrdersTokens.shadowCard,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: OrdersTokens.caption.copyWith(
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

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Search orders...',
        hintStyle: OrdersTokens.bodyMedium.copyWith(
          color: OrdersTokens.colorTextMuted,
        ),
        prefixIcon: const Icon(Icons.search, size: 16),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: OrdersTokens.colorBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: OrdersTokens.colorBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: OrdersTokens.colorKpiActiveStart,
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
        color: OrdersTokens.colorBgSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTab(
            label: 'Active',
            icon: Icons.access_time,
            count: _stats['active'],
            status: OrderStatus.active,
          ),
          const SizedBox(width: 4),
          _buildTab(
            label: 'Completed',
            icon: Icons.check_circle,
            count: _stats['completed'],
            status: OrderStatus.completed,
          ),
          const SizedBox(width: 4),
          _buildTab(
            label: 'Cancelled',
            icon: Icons.cancel,
            count: _stats['cancelled'],
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
          boxShadow: isActive ? OrdersTokens.shadowCard : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive
                  ? OrdersTokens.colorTextPrimary
                  : OrdersTokens.colorTextMuted,
            ),
            const SizedBox(width: 6),
            Text(
              '$label ($count)',
              style: OrdersTokens.bodySmall.copyWith(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? OrdersTokens.colorTextPrimary
                    : OrdersTokens.colorTextMuted,
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
          children: [
            Text(
              'CHANNELS:',
              style: OrdersTokens.caption.copyWith(
                color: OrdersTokens.colorTextMuted,
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
            }).toList(),
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
      borderRadius: BorderRadius.circular(OrdersTokens.chipRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: gradient) : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(OrdersTokens.chipRadius),
          border: Border.all(
            color: isSelected ? Colors.transparent : OrdersTokens.colorBorder,
          ),
          boxShadow: OrdersTokens.shadowCard,
        ),
        child: Text(
          label,
          style: OrdersTokens.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : OrdersTokens.colorTextPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersGrid() {
    if (_filteredOrders.isEmpty) {
      return _buildEmptyState();
    }

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(width);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: OrdersTokens.gapBetweenCards,
        mainAxisSpacing: OrdersTokens.gapBetweenCards,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        return OrderCardWidget(order: _filteredOrders[index]);
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= OrdersTokens.breakpointDesktop) return 4;
    if (width >= OrdersTokens.breakpointTablet) return 3;
    if (width >= OrdersTokens.breakpointMobile) return 2;
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
              color: OrdersTokens.colorTextMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: OrdersTokens.headingSmall.copyWith(
              color: OrdersTokens.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: OrdersTokens.bodyMedium.copyWith(
              color: OrdersTokens.colorTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getChannelGradient(OrderChannel channel) {
    switch (channel) {
      case OrderChannel.ubereats:
        return [OrdersTokens.colorUberEatsStart, OrdersTokens.colorUberEatsEnd];
      case OrderChannel.doordash:
        return [OrdersTokens.colorDoorDashStart, OrdersTokens.colorDoorDashEnd];
      case OrderChannel.menulog:
        return [OrdersTokens.colorMenulogStart, OrdersTokens.colorMenulogEnd];
      case OrderChannel.website:
        return [OrdersTokens.colorWebsiteStart, OrdersTokens.colorWebsiteEnd];
      case OrderChannel.app:
        return [OrdersTokens.colorAppStart, OrdersTokens.colorAppEnd];
      case OrderChannel.qr:
        return [OrdersTokens.colorQrStart, OrdersTokens.colorQrEnd];
      case OrderChannel.dinein:
        return [OrdersTokens.colorDineInStart, OrdersTokens.colorDineInEnd];
      case OrderChannel.takeaway:
        return [OrdersTokens.colorTakeawayStart, OrdersTokens.colorTakeawayEnd];
    }
  }
}
