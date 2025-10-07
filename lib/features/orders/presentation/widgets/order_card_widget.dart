import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../orders_tokens.dart';

class OrderCardWidget extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onAction;

  const OrderCardWidget({super.key, required this.order, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(OrdersTokens.cardRadius),
        border: Border.all(color: OrdersTokens.colorBorder, width: 2),
        boxShadow: OrdersTokens.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Colored top border/halo
          Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _getChannelGradient()),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(OrdersTokens.cardRadius - 2),
                topRight: Radius.circular(OrdersTokens.cardRadius - 2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(OrdersTokens.paddingCard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header row: channel icon, queue number, status badge
                _buildHeader(),
                const SizedBox(height: 12),

                // Order ID & Channel tags
                _buildOrderInfo(),
                const SizedBox(height: 12),

                // Customer & Time
                _buildCustomerAndTime(),
                const SizedBox(height: 12),

                // Items summary
                _buildItemsSummary(),
                const SizedBox(height: 12),

                // Total bar
                _buildTotalBar(),
                const SizedBox(height: 12),

                // Action buttons
                _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Channel icon
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: _getChannelBgGradient()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              order.channel.emoji,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Queue number badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: OrdersTokens.colorBgSecondary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '#${order.queueNumber}',
            style: OrdersTokens.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: OrdersTokens.colorTextPrimary,
            ),
          ),
        ),

        const Spacer(),

        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: _getStatusGradient()),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _getStatusBorderColor()),
          ),
          child: Text(
            _getStatusLabel(),
            style: OrdersTokens.badge.copyWith(color: _getStatusTextColor()),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: OrdersTokens.colorDivider, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.id,
            style: OrdersTokens.headingSmall.copyWith(
              color: OrdersTokens.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Channel tag
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _getChannelBgGradient()),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _getChannelBorderColor()),
                ),
                child: Text(
                  order.channel.name,
                  style: OrdersTokens.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getChannelTextColor(),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Order type tag
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: OrdersTokens.colorBgSecondary,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: OrdersTokens.colorBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getOrderTypeIcon(),
                      size: 14,
                      color: OrdersTokens.colorTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getOrderTypeLabel(),
                      style: OrdersTokens.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                        color: OrdersTokens.colorTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAndTime() {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: OrdersTokens.colorDivider, width: 2),
        ),
      ),
      child: Column(
        children: [
          if (order.customerName.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: OrdersTokens.colorBgSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: OrdersTokens.colorBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 14,
                    color: OrdersTokens.colorTextMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: OrdersTokens.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: OrdersTokens.colorTextPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              // Elapsed time
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE047)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer,
                        size: 14,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getElapsedTime(),
                        style: OrdersTokens.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Estimated time
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF93C5FD)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Color(0xFF1E40AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(order.estimatedTime),
                        style: OrdersTokens.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E40AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSummary() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF9FAFB), Color(0xFFF3F4F6)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: OrdersTokens.colorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_bag,
                size: 14,
                color: OrdersTokens.colorTextMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${order.items.length} item${order.items.length != 1 ? 's' : ''}',
                style: OrdersTokens.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: OrdersTokens.colorTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            order.items.length <= 2
                ? order.items.map((i) => i.name).join(', ')
                : '${order.items[0].name} +${order.items.length - 1} more',
            style: OrdersTokens.bodySmall.copyWith(
              color: OrdersTokens.colorTextSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF475569)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: OrdersTokens.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFFD1D5DB),
            ),
          ),
          Text(
            '\$${order.total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (order.status == OrderStatus.active) ...[
          _buildActionButton(
            icon: Icons.restaurant,
            color: OrdersTokens.colorActionCooking,
            onTap: () => _showToast(context, 'Cooking'),
          ),
          _buildActionButton(
            icon: Icons.check_circle,
            color: OrdersTokens.colorActionReady,
            filled: true,
            onTap: () => _showToast(context, 'Ready'),
          ),
        ],
        if (order.orderType == OrderType.delivery)
          _buildActionButton(
            icon: Icons.send,
            color: OrdersTokens.colorActionDispatch,
            filled: true,
            onTap: () => _showToast(context, 'Dispatch'),
          ),
        if (order.paymentStatus == PaymentStatus.unpaid)
          _buildActionButton(
            icon: Icons.attach_money,
            color: OrdersTokens.colorActionPay,
            filled: true,
            onTap: () => _showToast(context, 'Pay'),
          ),
        _buildActionButton(
          icon: Icons.edit,
          color: OrdersTokens.colorTextSecondary,
          onTap: () => _showToast(context, 'Edit'),
        ),
        _buildActionButton(
          icon: Icons.cancel,
          color: OrdersTokens.colorActionCancel,
          onTap: () => _showToast(context, 'Cancel'),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    bool filled = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(OrdersTokens.buttonRadiusSm),
      child: Container(
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(OrdersTokens.buttonRadiusSm),
          border: Border.all(
            color: filled ? color.withValues(alpha: 0.5) : color,
            width: 2,
          ),
        ),
        child: Icon(icon, size: 14, color: filled ? Colors.white : color),
      ),
    );
  }

  List<Color> _getChannelGradient() {
    switch (order.channel) {
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

  List<Color> _getChannelBgGradient() {
    switch (order.channel) {
      case OrderChannel.ubereats:
        return [OrdersTokens.colorUberEatsBg, OrdersTokens.colorUberEatsBg];
      case OrderChannel.doordash:
        return [OrdersTokens.colorDoorDashBg, OrdersTokens.colorDoorDashBg];
      case OrderChannel.menulog:
        return [OrdersTokens.colorMenulogBg, OrdersTokens.colorMenulogBg];
      case OrderChannel.website:
        return [OrdersTokens.colorWebsiteBg, OrdersTokens.colorWebsiteBg];
      case OrderChannel.app:
        return [OrdersTokens.colorAppBg, OrdersTokens.colorAppBg];
      case OrderChannel.qr:
        return [OrdersTokens.colorQrBg, OrdersTokens.colorQrBg];
      case OrderChannel.dinein:
        return [OrdersTokens.colorDineInBg, OrdersTokens.colorDineInBg];
      case OrderChannel.takeaway:
        return [OrdersTokens.colorTakeawayBg, OrdersTokens.colorTakeawayBg];
    }
  }

  Color _getChannelTextColor() {
    switch (order.channel) {
      case OrderChannel.ubereats:
        return OrdersTokens.colorUberEatsText;
      case OrderChannel.doordash:
        return OrdersTokens.colorDoorDashText;
      case OrderChannel.menulog:
        return OrdersTokens.colorMenulogText;
      case OrderChannel.website:
        return OrdersTokens.colorWebsiteText;
      case OrderChannel.app:
        return OrdersTokens.colorAppText;
      case OrderChannel.qr:
        return OrdersTokens.colorQrText;
      case OrderChannel.dinein:
        return OrdersTokens.colorDineInText;
      case OrderChannel.takeaway:
        return OrdersTokens.colorTakeawayText;
    }
  }

  Color _getChannelBorderColor() {
    switch (order.channel) {
      case OrderChannel.ubereats:
        return OrdersTokens.colorUberEatsBorder;
      case OrderChannel.doordash:
        return OrdersTokens.colorDoorDashBorder;
      case OrderChannel.menulog:
        return OrdersTokens.colorMenulogBorder;
      case OrderChannel.website:
        return OrdersTokens.colorWebsiteBorder;
      case OrderChannel.app:
        return OrdersTokens.colorAppBorder;
      case OrderChannel.qr:
        return OrdersTokens.colorQrBorder;
      case OrderChannel.dinein:
        return OrdersTokens.colorDineInBorder;
      case OrderChannel.takeaway:
        return OrdersTokens.colorTakeawayBorder;
    }
  }

  List<Color> _getStatusGradient() {
    if (order.status == OrderStatus.cancelled) {
      return [
        OrdersTokens.colorStatusCancelledBg,
        OrdersTokens.colorStatusCancelledBg,
      ];
    }
    if (order.status == OrderStatus.completed) {
      return [
        OrdersTokens.colorStatusCompletedBg,
        OrdersTokens.colorStatusCompletedBg,
      ];
    }
    if (order.paymentStatus == PaymentStatus.unpaid) {
      return [
        OrdersTokens.colorStatusUnpaidBg,
        OrdersTokens.colorStatusUnpaidBg,
      ];
    }
    return [OrdersTokens.colorStatusActiveBg, OrdersTokens.colorStatusActiveBg];
  }

  Color _getStatusTextColor() {
    if (order.status == OrderStatus.cancelled) {
      return OrdersTokens.colorStatusCancelledText;
    }
    if (order.status == OrderStatus.completed) {
      return OrdersTokens.colorStatusCompletedText;
    }
    if (order.paymentStatus == PaymentStatus.unpaid) {
      return OrdersTokens.colorStatusUnpaidText;
    }
    return OrdersTokens.colorStatusActiveText;
  }

  Color _getStatusBorderColor() {
    if (order.status == OrderStatus.cancelled) {
      return OrdersTokens.colorStatusCancelledBorder;
    }
    if (order.status == OrderStatus.completed) {
      return OrdersTokens.colorStatusCompletedBorder;
    }
    if (order.paymentStatus == PaymentStatus.unpaid) {
      return OrdersTokens.colorStatusUnpaidBorder;
    }
    return OrdersTokens.colorStatusActiveBorder;
  }

  String _getStatusLabel() {
    if (order.status == OrderStatus.cancelled) return 'CANCELLED';
    if (order.status == OrderStatus.completed) return 'COMPLETED';
    if (order.paymentStatus == PaymentStatus.unpaid) return 'UNPAID';
    return 'ACTIVE';
  }

  IconData _getOrderTypeIcon() {
    switch (order.orderType) {
      case OrderType.delivery:
        return Icons.delivery_dining;
      case OrderType.takeaway:
        return Icons.shopping_bag;
      case OrderType.dinein:
        return Icons.restaurant;
    }
  }

  String _getOrderTypeLabel() {
    switch (order.orderType) {
      case OrderType.delivery:
        return 'Delivery';
      case OrderType.takeaway:
        return 'Takeaway';
      case OrderType.dinein:
        return 'Dine-In';
    }
  }

  String _getElapsedTime() {
    final diff = DateTime.now().difference(order.createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  void _showToast(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action action for order ${order.id}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
