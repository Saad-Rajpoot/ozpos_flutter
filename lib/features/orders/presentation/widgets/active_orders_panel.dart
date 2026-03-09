import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_radius.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/orders_management_bloc.dart';
import '../bloc/orders_management_state.dart';

/// Active Orders Panel - exact match to reference image
/// Fixed width 360dp on desktop/large, collapsible on compact
/// Shows top 10 orders from history API.
class ActiveOrdersPanel extends StatelessWidget {
  const ActiveOrdersPanel({super.key});

  static const int _topOrdersLimit = 10;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: AppSizes.rightPanelWidth,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          left: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),

          // Search
          _buildSearchBar(context),

          // Content
          Expanded(
            child: Builder(builder: (context) => _buildOrdersList(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = context.watch<OrdersManagementBloc>().state;
    final count = state is OrdersManagementLoaded
        ? state.orders.take(_topOrdersLimit).length
        : 0;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.base,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Active Orders',
            style: AppTypography.heading4.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count Orders',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      color: colorScheme.surface,
      child: Container(
        height: AppSizes.searchFieldHeight,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.search,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Expanded(
              child: Text(
                'Search orders...',
                style: AppTypography.body2.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    return BlocBuilder<OrdersManagementBloc, OrdersManagementState>(
      builder: (context, state) {
        final List<_OrderData> orderDataList;
        if (state is OrdersManagementLoaded) {
          final top = state.orders.take(_topOrdersLimit).toList();
          orderDataList =
              top.map((o) => _orderEntityToOrderData(o)).toList();
        } else {
          orderDataList = const [];
        }

        return Column(
          children: [
            Expanded(
              child: state is OrdersManagementLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      itemCount: orderDataList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.orderCardGap),
                      itemBuilder: (context, index) => _OrderCard(
                        order: orderDataList[index],
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRouter.orders),
                      ),
                    ),
            ),
            // View All Button
            Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderLight, width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRouter.orders),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  child: const Text(
                    'VIEW ALL ORDER HISTORY',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static _OrderData _orderEntityToOrderData(OrderEntity o) {
    final id = o.queueNumber.startsWith('#')
        ? o.queueNumber
        : '#${o.queueNumber}';
    final type = o.channel.name;
    final amount = o.total;
    final time = DateFormat('h:mm a').format(o.createdAt);
    final waiting = _elapsed(o.createdAt);
    final status = o.paymentStatus == PaymentStatus.unpaid
        ? 'UNPAID'
        : o.status == OrderStatus.completed
            ? 'READY'
            : 'PENDING';
    final iconColor = _iconColorForChannel(o.channel);
    final icon = _iconForChannel(o.channel);
    return _OrderData(
      id: id,
      type: type,
      amount: amount,
      time: time,
      waiting: waiting,
      status: status,
      iconColor: iconColor,
      icon: icon,
    );
  }

  static String _elapsed(DateTime from) {
    final diff = DateTime.now().difference(from);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return '0m';
  }

  static Color _iconColorForChannel(OrderChannel channel) {
    switch (channel) {
      case OrderChannel.delivery:
        return AppColors.tileDelivery;
      case OrderChannel.takeaway:
        return AppColors.tileTakeaway;
      case OrderChannel.dinein:
        return AppColors.tileTables;
      default:
        return AppColors.tileTakeaway;
    }
  }

  static IconData _iconForChannel(OrderChannel channel) {
    switch (channel) {
      case OrderChannel.delivery:
        return Icons.delivery_dining;
      case OrderChannel.takeaway:
        return Icons.shopping_bag;
      case OrderChannel.dinein:
        return Icons.table_restaurant;
      default:
        return Icons.shopping_bag;
    }
  }
}

class _OrderData {
  final String id;
  final String type;
  final double amount;
  final String time;
  final String waiting;
  final String status;
  final Color iconColor;
  final IconData icon;

  _OrderData({
    required this.id,
    required this.type,
    required this.amount,
    required this.time,
    required this.waiting,
    required this.status,
    required this.iconColor,
    required this.icon,
  });
}

class _OrderCard extends StatelessWidget {
  final _OrderData order;
  final VoidCallback? onTap;

  const _OrderCard({required this.order, this.onTap});

  Color get _borderColor {
    switch (order.status) {
      case 'PENDING':
        return AppColors.statusPendingText;
      case 'READY':
        return AppColors.statusReadyText;
      case 'UNPAID':
        return AppColors.statusUnpaidText;
      default:
        return AppColors.borderLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.orderCard),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(AppRadius.orderCard),
          border: Border.all(color: _borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: _borderColor.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: order.iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    order.icon,
                    size: AppSizes.iconOrderCard,
                    color: order.iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                // Order ID and Type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Order ${order.id}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          _buildStatusChip(order.status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.type,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Details row
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Amount',
                    '\$${order.amount.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(child: _buildDetailItem('Time', order.time)),
                Expanded(child: _buildDetailItem('Waiting', order.waiting)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'PENDING':
        bgColor = AppColors.statusPendingBg;
        textColor = AppColors.statusPendingText;
        break;
      case 'READY':
        bgColor = AppColors.statusReadyBg;
        textColor = AppColors.statusReadyText;
        break;
      case 'UNPAID':
        bgColor = AppColors.statusUnpaidBg;
        textColor = AppColors.statusUnpaidText;
        break;
      default:
        bgColor = AppColors.bgPrimary;
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
