import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../constants/orders_constants.dart';

class OrderCardWidget extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onAction;

  const OrderCardWidget({super.key, required this.order, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(OrdersConstants.cardRadius),
        border: Border.all(color: OrdersConstants.colorBorder, width: 2),
        boxShadow: OrdersConstants.shadowCard,
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
                topLeft: Radius.circular(OrdersConstants.cardRadius - 2),
                topRight: Radius.circular(OrdersConstants.cardRadius - 2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(OrdersConstants.paddingCard),
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
            color: OrdersConstants.colorBgSecondary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '#${order.queueNumber}',
            style: OrdersConstants.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: OrdersConstants.colorTextPrimary,
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
            style: OrdersConstants.badge.copyWith(color: _getStatusTextColor()),
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
          bottom: BorderSide(color: OrdersConstants.colorDivider, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.id,
            style: OrdersConstants.headingSmall.copyWith(
              color: OrdersConstants.colorTextPrimary,
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
                  style: OrdersConstants.bodySmall.copyWith(
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
                  color: OrdersConstants.colorBgSecondary,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: OrdersConstants.colorBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getOrderTypeIcon(),
                      size: 14,
                      color: OrdersConstants.colorTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getOrderTypeLabel(),
                      style: OrdersConstants.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                        color: OrdersConstants.colorTextSecondary,
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
          bottom: BorderSide(color: OrdersConstants.colorDivider, width: 2),
        ),
      ),
      child: Column(
        children: [
          if (order.customerName.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: OrdersConstants.colorBgSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: OrdersConstants.colorBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 14,
                    color: OrdersConstants.colorTextMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: OrdersConstants.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: OrdersConstants.colorTextPrimary,
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
                        style: OrdersConstants.bodySmall.copyWith(
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
                        style: OrdersConstants.bodySmall.copyWith(
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
        border: Border.all(color: OrdersConstants.colorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_bag,
                size: 14,
                color: OrdersConstants.colorTextMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${order.items.length} item${order.items.length != 1 ? 's' : ''}',
                style: OrdersConstants.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: OrdersConstants.colorTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            order.items.length <= 2
                ? order.items.map((i) => i.name).join(', ')
                : '${order.items[0].name} +${order.items.length - 1} more',
            style: OrdersConstants.bodySmall.copyWith(
              color: OrdersConstants.colorTextSecondary,
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
            style: OrdersConstants.bodyMedium.copyWith(
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
            color: OrdersConstants.colorActionCooking,
            onTap: () => _showToast(context, 'Cooking'),
          ),
          _buildActionButton(
            icon: Icons.check_circle,
            color: OrdersConstants.colorActionReady,
            filled: true,
            onTap: () => _showToast(context, 'Ready'),
          ),
        ],
        if (order.orderType == OrderType.delivery)
          _buildActionButton(
            icon: Icons.send,
            color: OrdersConstants.colorActionDispatch,
            filled: true,
            onTap: () => _showToast(context, 'Dispatch'),
          ),
        if (order.paymentStatus == PaymentStatus.unpaid)
          _buildActionButton(
            icon: Icons.attach_money,
            color: OrdersConstants.colorActionPay,
            filled: true,
            onTap: () => _showToast(context, 'Pay'),
          ),
        _buildActionButton(
          icon: Icons.edit,
          color: OrdersConstants.colorTextSecondary,
          onTap: () => _showToast(context, 'Edit'),
        ),
        _buildActionButton(
          icon: Icons.cancel,
          color: OrdersConstants.colorActionCancel,
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
      borderRadius: BorderRadius.circular(OrdersConstants.buttonRadiusSm),
      child: Container(
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(OrdersConstants.buttonRadiusSm),
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

  List<Color> _getChannelBgGradient() {
    switch (order.channel) {
      case OrderChannel.ubereats:
        return [
          OrdersConstants.colorUberEatsBg,
          OrdersConstants.colorUberEatsBg,
        ];
      case OrderChannel.doordash:
        return [
          OrdersConstants.colorDoorDashBg,
          OrdersConstants.colorDoorDashBg,
        ];
      case OrderChannel.menulog:
        return [OrdersConstants.colorMenulogBg, OrdersConstants.colorMenulogBg];
      case OrderChannel.website:
        return [OrdersConstants.colorWebsiteBg, OrdersConstants.colorWebsiteBg];
      case OrderChannel.app:
        return [OrdersConstants.colorAppBg, OrdersConstants.colorAppBg];
      case OrderChannel.qr:
        return [OrdersConstants.colorQrBg, OrdersConstants.colorQrBg];
      case OrderChannel.dinein:
        return [OrdersConstants.colorDineInBg, OrdersConstants.colorDineInBg];
      case OrderChannel.takeaway:
        return [
          OrdersConstants.colorTakeawayBg,
          OrdersConstants.colorTakeawayBg,
        ];
    }
  }

  Color _getChannelTextColor() {
    switch (order.channel) {
      case OrderChannel.ubereats:
        return OrdersConstants.colorUberEatsText;
      case OrderChannel.doordash:
        return OrdersConstants.colorDoorDashText;
      case OrderChannel.menulog:
        return OrdersConstants.colorMenulogText;
      case OrderChannel.website:
        return OrdersConstants.colorWebsiteText;
      case OrderChannel.app:
        return OrdersConstants.colorAppText;
      case OrderChannel.qr:
        return OrdersConstants.colorQrText;
      case OrderChannel.dinein:
        return OrdersConstants.colorDineInText;
      case OrderChannel.takeaway:
        return OrdersConstants.colorTakeawayText;
    }
  }

  Color _getChannelBorderColor() {
    switch (order.channel) {
      case OrderChannel.ubereats:
        return OrdersConstants.colorUberEatsBorder;
      case OrderChannel.doordash:
        return OrdersConstants.colorDoorDashBorder;
      case OrderChannel.menulog:
        return OrdersConstants.colorMenulogBorder;
      case OrderChannel.website:
        return OrdersConstants.colorWebsiteBorder;
      case OrderChannel.app:
        return OrdersConstants.colorAppBorder;
      case OrderChannel.qr:
        return OrdersConstants.colorQrBorder;
      case OrderChannel.dinein:
        return OrdersConstants.colorDineInBorder;
      case OrderChannel.takeaway:
        return OrdersConstants.colorTakeawayBorder;
    }
  }

  List<Color> _getStatusGradient() {
    if (order.status == OrderStatus.cancelled) {
      return [
        OrdersConstants.colorStatusCancelledBg,
        OrdersConstants.colorStatusCancelledBg,
      ];
    }
    if (order.status == OrderStatus.completed) {
      return [
        OrdersConstants.colorStatusCompletedBg,
        OrdersConstants.colorStatusCompletedBg,
      ];
    }
    if (order.paymentStatus == PaymentStatus.unpaid) {
      return [
        OrdersConstants.colorStatusUnpaidBg,
        OrdersConstants.colorStatusUnpaidBg,
      ];
    }
    return [
      OrdersConstants.colorStatusActiveBg,
      OrdersConstants.colorStatusActiveBg,
    ];
  }

  Color _getStatusTextColor() {
    if (order.status == OrderStatus.cancelled) {
      return OrdersConstants.colorStatusCancelledText;
    }
    if (order.status == OrderStatus.completed) {
      return OrdersConstants.colorStatusCompletedText;
    }
    if (order.paymentStatus == PaymentStatus.unpaid) {
      return OrdersConstants.colorStatusUnpaidText;
    }
    return OrdersConstants.colorStatusActiveText;
  }

  Color _getStatusBorderColor() {
    if (order.status == OrderStatus.cancelled) {
      return OrdersConstants.colorStatusCancelledBorder;
    }
    if (order.status == OrderStatus.completed) {
      return OrdersConstants.colorStatusCompletedBorder;
    }
    if (order.paymentStatus == PaymentStatus.unpaid) {
      return OrdersConstants.colorStatusUnpaidBorder;
    }
    return OrdersConstants.colorStatusActiveBorder;
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
