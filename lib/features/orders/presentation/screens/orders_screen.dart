import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/widgets/sidebar_nav.dart';
import '../../../../core/theme/theme_context_ext.dart';
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
  StreamSubscription<DatabaseEvent>? _ordersTriggerSubscription;

  @override
  void initState() {
    super.initState();
    _initializeOrdersTriggerListener();
  }

  Future<void> _initializeOrdersTriggerListener() async {
    try {
      // Ensure Firebase is initialized before accessing the database.
      if (Firebase.apps.isEmpty) {
        const options = FirebaseOptions(
          apiKey: 'AIzaSyCCWtm7U2UTX1xY6BjZqxs161TPdvQUdkw',
          appId: '1:712536179289:web:72fd888e2003d17e7b6748',
          messagingSenderId: '712536179289',
          projectId: 'ozpos-a2b71',
          databaseURL: 'https://ozpos-a2b71-default-rtdb.firebaseio.com',
          storageBucket: 'ozpos-a2b71.firebasestorage.app',
        );
        await Firebase.initializeApp(options: options);
      }

      final prefs = await SharedPreferences.getInstance();
      final vendorUuid = prefs.getString(AppConstants.authVendorUuidKey);
      final branchUuid = prefs.getString(AppConstants.authBranchUuidKey);

      if (vendorUuid == null ||
          vendorUuid.isEmpty ||
          branchUuid == null ||
          branchUuid.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            'OrdersScreen: vendor/branch UUID missing, skipping Firebase listener.',
          );
        }
        return;
      }

      final ref = FirebaseDatabase.instance.ref(
        'orders-trigger/$vendorUuid/$branchUuid/last_update',
      );

      var isInitial = true;
      _ordersTriggerSubscription = ref.onValue.listen((event) {
        // Skip the initial snapshot; we only care about subsequent updates.
        if (isInitial) {
          isInitial = false;
          return;
        }

        if (!mounted) return;
        if (event.snapshot.value == null) return;

        if (kDebugMode) {
          debugPrint(
            'OrdersScreen: orders-trigger last_update changed -> refreshing orders silently.',
          );
        }

        // Trigger a silent refresh: fetch latest orders but avoid showing
        // the full-screen loading spinner so the dashboard feels realtime.
        context
            .read<OrdersManagementBloc>()
            .add(const RefreshOrdersSilentlyEvent());
      });
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('OrdersScreen: failed to init Firebase listener: $error');
      }
      // Non-fatal; orders will still work without realtime refresh.
      // Optionally report via Sentry here if desired.
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
    }
  }

  @override
  void dispose() {
    _ordersTriggerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.1);
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scaler),
      child: Scaffold(
        backgroundColor: context.bgPrimary,
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
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    final headerBorderColor =
        isLight ? OrdersConstants.colorBorder : context.borderLight;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: headerBorderColor)),
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
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track and manage all your orders in real-time',
                        style: OrdersConstants.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 300, child: _SearchBar()),
                const SizedBox(width: 16),
                const _Tabs(),
                const SizedBox(width: 16),
                const _ViewToggle(),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<OrdersManagementBloc>().add(
                          const LoadOrdersEvent(),
                        );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    side: BorderSide(color: context.borderLight),
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
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      onChanged: (value) =>
          context.read<OrdersViewCubit>().updateSearchQuery(value.trim()),
      decoration: InputDecoration(
        hintText: 'Search orders...',
        hintStyle: OrdersConstants.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        prefixIcon: const Icon(Icons.search, size: 16),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.borderLight),
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
            color: isActive
                ? Theme.of(context).colorScheme.surface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive ? OrdersConstants.shadowCard : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '$label ($count)',
                style: OrdersConstants.bodySmall.copyWith(
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
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

class _ViewToggle extends StatelessWidget {
  const _ViewToggle();

  @override
  Widget build(BuildContext context) {
    final viewState = context.watch<OrdersViewCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewToggleButton(
            icon: Icons.grid_view_rounded,
            label: 'Grid',
            isSelected: viewState.isGridView,
            onTap: () => context.read<OrdersViewCubit>().setViewMode(true),
          ),
          _ViewToggleButton(
            icon: Icons.view_agenda_rounded,
            label: 'List',
            isSelected: !viewState.isGridView,
            onTap: () => context.read<OrdersViewCubit>().setViewMode(false),
          ),
        ],
      ),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  const _ViewToggleButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: isSelected
          ? colorScheme.primary.withOpacity(0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: OrdersConstants.bodySmall.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersContent extends StatefulWidget {
  const _OrdersContent();

  @override
  State<_OrdersContent> createState() => _OrdersContentState();
}

class _OrdersContentState extends State<_OrdersContent> {
  bool _highlightShown = false;

  @override
  Widget build(BuildContext context) {
    final viewState = context.watch<OrdersViewCubit>().state;
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final highlightOrderId = routeArgs?['highlightOrderId'] as String?;

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
          // If we were asked to highlight a specific order, open its detail
          // dialog once after data loads. Only do this once per screen instance.
          if (highlightOrderId != null && !_highlightShown) {
            _highlightShown = true;
            final target = filtered.firstWhere(
              (o) => o.id == highlightOrderId,
              orElse: () => filtered.first,
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog<void>(
                context: context,
                builder: (ctx) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: 420, maxHeight: 560),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(OrdersConstants.cardRadius),
                      child: OrderCardWidget(order: target),
                    ),
                  ),
                ),
              );
            });
          }
          return viewState.isGridView
              ? _buildOrdersGrid(context, filtered)
              : _buildOrdersList(context, filtered);
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
      childAspectRatio: 0.72,
    ),
    itemCount: orders.length,
    itemBuilder: (context, index) {
      final order = orders[index];
      return OrderCardWidget(
        order: order,
        onEdit: () => _navigateToEditOrder(order),
      );
    },
  );
}

Widget _buildOrdersList(BuildContext context, List<OrderEntity> orders) {
  return ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: orders.length,
    separatorBuilder: (_, __) =>
        const SizedBox(height: OrdersConstants.gapBetweenCards),
    itemBuilder: (context, index) {
      return _OrderListTile(order: orders[index]);
    },
  );
}

/// Compact list-tile card for list view: uses full width and one dense row.
class _OrderListTile extends StatelessWidget {
  const _OrderListTile({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradients = _getChannelGradient(order.channel);
    final statusLabel = _statusLabel(order);
    final statusBg = _statusBg(order);
    final statusColor = _statusColor(order);
    final queue = order.queueNumber.startsWith('#')
        ? order.queueNumber
        : '#${order.queueNumber}';
    final itemCount = order.items.length;
    final elapsed = _elapsed(order.createdAt);
    final timeStr = DateFormat('h:mm a').format(order.createdAt);
    final showTable =
        order.orderType == OrderType.dinein &&
        (order.tableNumber != null && order.tableNumber!.trim().isNotEmpty);

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(OrdersConstants.cardRadius),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        onTap: () => _showOrderDetail(context, order),
        borderRadius: BorderRadius.circular(OrdersConstants.cardRadius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Channel strip
              Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: gradients,
                  ),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(OrdersConstants.cardRadius),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Order id + channel
                      SizedBox(
                        width: 140,
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: gradients,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                order.channel.emoji,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    queue,
                                    style: OrdersConstants.bodySmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    order.channel.name,
                                    style: OrdersConstants.caption.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (showTable) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Table ${order.tableNumber!.trim()}',
                                      style: OrdersConstants.caption.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Customer + items + time
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customerName.isEmpty
                                  ? '—'
                                  : order.customerName,
                              style: OrdersConstants.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  '$itemCount item${itemCount != 1 ? 's' : ''}',
                                  style: OrdersConstants.caption.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  ' · $elapsed',
                                  style: OrdersConstants.caption.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  timeStr,
                                  style: OrdersConstants.caption.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Total + optional Edit
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${order.total.toStringAsFixed(2)}',
                            style: OrdersConstants.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: OrdersConstants.badge.copyWith(
                                    color: statusColor,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                              if (_canEditOrder(order)) ...[
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () => _navigateToEditOrder(order),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 14,
                                  ),
                                  label: const Text(
                                    'Edit',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(OrderEntity o) {
    if (o.status == OrderStatus.cancelled) return 'CANCELLED';
    if (o.status == OrderStatus.completed) return 'COMPLETED';
    if (o.paymentStatus == PaymentStatus.unpaid) return 'UNPAID';
    return 'ACTIVE';
  }

  Color _statusBg(OrderEntity o) {
    if (o.status == OrderStatus.cancelled) {
      return OrdersConstants.colorStatusCancelledBg;
    }
    if (o.status == OrderStatus.completed) {
      return OrdersConstants.colorStatusCompletedBg;
    }
    if (o.paymentStatus == PaymentStatus.unpaid) {
      return OrdersConstants.colorStatusUnpaidBg;
    }
    return OrdersConstants.colorStatusActiveBg;
  }

  Color _statusColor(OrderEntity o) {
    if (o.status == OrderStatus.cancelled) {
      return OrdersConstants.colorStatusCancelledText;
    }
    if (o.status == OrderStatus.completed) {
      return OrdersConstants.colorStatusCompletedText;
    }
    if (o.paymentStatus == PaymentStatus.unpaid) {
      return OrdersConstants.colorStatusUnpaidText;
    }
    return OrdersConstants.colorStatusActiveText;
  }

  String _elapsed(DateTime from) {
    final d = DateTime.now().difference(from);
    if (d.inDays > 0) return '${d.inDays}d ago';
    if (d.inHours > 0) return '${d.inHours}h ago';
    if (d.inMinutes > 0) return '${d.inMinutes}m ago';
    return 'now';
  }

  void _showOrderDetail(BuildContext context, OrderEntity order) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(OrdersConstants.cardRadius),
            child: OrderCardWidget(order: order),
          ),
        ),
      ),
    );
  }
}

void _navigateToEditOrder(OrderEntity order) {
  // Navigate to Menu screen in "edit order" mode. The MenuScreen will
  // reconstruct the cart from this OrderEntity and respect its original
  // service type (dine-in / pickup / delivery).
  String orderTypeString;
  switch (order.orderType) {
    case OrderType.dinein:
      orderTypeString = 'dine-in';
      break;
    case OrderType.takeaway:
      orderTypeString = 'takeaway';
      break;
    case OrderType.delivery:
      orderTypeString = 'delivery';
      break;
  }

  NavigationService.pushNamed(
    AppRouter.menu,
    arguments: <String, dynamic>{
      'orderType': orderTypeString,
      'editOrderId': order.id,
      'editOrderDisplayId': order.queueNumber,
      'editOrder': order,
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
    case OrderChannel.delivery:
      return [
        OrdersConstants.colorDeliveryStart,
        OrdersConstants.colorDeliveryEnd,
      ];
  }
}

bool _canEditOrder(OrderEntity order) {
  if (order.status != OrderStatus.active) return false;
  final method = order.paymentMethod;
  final isPayLater = method == 'pay_later';
  final isLocalOffline =
      order.id.startsWith('offline-') || order.queueNumber == '#OFFLINE';
  // When payment method is unknown (null/empty), treat the order as editable
  // so that cached history and offline-created orders remain editable even
  // when we only have local Drift snapshots.
  final isUnknownMethod = method == null || method.isEmpty;
  return isPayLater || isLocalOffline || isUnknownMethod;
}

class OrdersViewState extends Equatable {
  OrdersViewState({
    this.searchQuery = '',
    this.activeTab = OrderStatus.active,
    this.isGridView = true,
    Set<OrderChannel>? selectedChannels,
  }) : selectedChannels = Set<OrderChannel>.unmodifiable(
            selectedChannels ?? const <OrderChannel>{});

  final String searchQuery;
  final OrderStatus activeTab;
  final bool isGridView;
  final Set<OrderChannel> selectedChannels;

  OrdersViewState copyWith({
    String? searchQuery,
    OrderStatus? activeTab,
    bool? isGridView,
    Set<OrderChannel>? selectedChannels,
    bool clearSelectedChannels = false,
  }) {
    final updatedChannels = clearSelectedChannels
        ? <OrderChannel>{}
        : Set<OrderChannel>.from(selectedChannels ?? this.selectedChannels);

    return OrdersViewState(
      searchQuery: searchQuery ?? this.searchQuery,
      activeTab: activeTab ?? this.activeTab,
      isGridView: isGridView ?? this.isGridView,
      selectedChannels: updatedChannels,
    );
  }

  @override
  List<Object?> get props => [
        searchQuery,
        activeTab,
        isGridView,
        List<OrderChannel>.from(selectedChannels)
          ..sort((a, b) => a.index.compareTo(b.index)),
      ];
}

class OrdersViewCubit extends Cubit<OrdersViewState> {
  /// Persists the last selected view so it survives navigation (same screen session).
  static bool _lastIsGridView = true;

  OrdersViewCubit() : super(OrdersViewState(isGridView: _lastIsGridView));

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setActiveTab(OrderStatus status) {
    emit(state.copyWith(activeTab: status));
  }

  void setViewMode(bool isGridView) {
    _lastIsGridView = isGridView;
    if (state.isGridView == isGridView) return;
    emit(state.copyWith(isGridView: isGridView));
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
