import 'package:flutter/material.dart';
import '../core/theme/tokens.dart';
import '../core/navigation/app_router.dart';

/// Active Orders Panel - exact match to reference image
/// Fixed width 360dp on desktop/large, collapsible on compact
class ActiveOrdersPanel extends StatelessWidget {
  const ActiveOrdersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.rightPanelWidth,
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          left: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          // Search
          _buildSearchBar(),

          // Content
          Expanded(
            child: Builder(builder: (context) => _buildOrdersList(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.base,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Active Orders',
            style: AppTypography.heading4.copyWith(
              color: AppColors.textPrimary,
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
            child: const Text(
              '8 Orders',
              style: TextStyle(
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      color: AppColors.bgSecondary,
      child: Container(
        height: AppSizes.searchFieldHeight,
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.search,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
            Expanded(
              child: Text(
                'Search orders...',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    // Mock data matching reference image
    final orders = [
      _OrderData(
        id: '#001',
        type: 'Takeaway',
        amount: 25.50,
        time: '10:30 AM',
        waiting: '5m',
        status: 'PENDING',
        iconColor: AppColors.tileTakeaway,
        icon: Icons.shopping_bag,
      ),
      _OrderData(
        id: '#3',
        type: 'Table',
        amount: 45.00,
        time: '10:25 AM',
        waiting: '2m',
        status: 'READY',
        iconColor: AppColors.tileTables,
        icon: Icons.table_restaurant,
      ),
      _OrderData(
        id: '#3',
        type: 'Table',
        amount: 72.75,
        time: '10:20 AM',
        waiting: '15m',
        status: 'UNPAID',
        iconColor: AppColors.tileTables,
        icon: Icons.table_restaurant,
      ),
      _OrderData(
        id: '#004',
        type: 'Delivery',
        amount: 18.00,
        time: '10:15 AM',
        waiting: '8m',
        status: 'READY',
        iconColor: AppColors.tileDelivery,
        icon: Icons.delivery_dining,
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.base),
            itemCount: orders.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.orderCardGap),
            itemBuilder: (context, index) => _OrderCard(
              order: orders[index],
              onTap: () => Navigator.of(context).pushNamed(AppRouter.orders),
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
                  borderRadius: BorderRadius.circular(AppRadius.button),
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
              color: _borderColor.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
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
                    color: order.iconColor.withValues(alpha: 0.1),
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
