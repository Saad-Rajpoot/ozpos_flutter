import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../constants/orders_constants.dart';
import '../../../../core/theme/theme_context_ext.dart';

class OrderCardWidget extends StatelessWidget {
  final OrderEntity order;
  /// Optional callback invoked when the user taps Edit (used in Order Management).
  final VoidCallback? onEdit;

  const OrderCardWidget({
    super.key,
    required this.order,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    final cardBorderColor =
        isLight ? OrdersConstants.colorBorder : context.borderLight;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(OrdersConstants.cardRadius),
        border: Border.all(color: cardBorderColor, width: 2),
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

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(OrdersConstants.paddingCard),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header row: channel icon, queue number, status badge
                    _buildHeader(context),
                    const SizedBox(height: 12),

                    // Order ID & Channel tags
                    _buildOrderInfo(context),
                    const SizedBox(height: 12),

                    // Customer & Time
                    _buildCustomerAndTime(context),
                    const SizedBox(height: 12),

                    // Order notes (when present)
                    if (order.specialInstructions != null &&
                        order.specialInstructions!.isNotEmpty)
                      _buildOrderNotes(context),
                    if (order.specialInstructions != null &&
                        order.specialInstructions!.isNotEmpty)
                      const SizedBox(height: 12),

                    // Items summary (collapsible)
                    _OrderItemsSection(order: order),
                    const SizedBox(height: 12),

                    // Total bar
                    _buildTotalBar(context),
                    const SizedBox(height: 12),

                    // Action buttons
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '#${order.id}',
            style: OrdersConstants.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),

        const Spacer(),

        // Payment status chip (PAID / UNPAID)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: order.paymentStatus == PaymentStatus.paid
                ? const Color(0xFFDCFCE7)
                : const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: order.paymentStatus == PaymentStatus.paid
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFEA580C),
            ),
          ),
          child: Text(
            order.paymentStatus == PaymentStatus.paid ? 'PAID' : 'UNPAID',
            style: OrdersConstants.badge.copyWith(
              color: order.paymentStatus == PaymentStatus.paid
                  ? const Color(0xFF166534)
                  : const Color(0xFF9A3412),
            ),
          ),
        ),

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

  Widget _buildOrderInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final showTable =
        order.orderType == OrderType.dinein &&
        (order.tableNumber != null && order.tableNumber!.trim().isNotEmpty);
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.borderLight, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.queueNumber,
            style: OrdersConstants.headingSmall.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Channel tag (e.g. UberEats, Delivery, Dine-In, Pickup)
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getOrderTypeIcon(),
                      size: 14,
                      color: _getChannelTextColor(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.channel.name,
                      style: OrdersConstants.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getChannelTextColor(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Payment method chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: context.borderLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.payment,
                      size: 14,
                      color: OrdersConstants.colorTextMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      (order.paymentMethod == null ||
                              order.paymentMethod!.isEmpty)
                          ? 'Payment'
                          : order.paymentMethod!,
                      style: OrdersConstants.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Source chip (POS / ONLINE / UBEREATS, etc.)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: context.borderLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.public,
                      size: 14,
                      color: OrdersConstants.colorTextMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      (order.source == null || order.source!.isEmpty)
                          ? 'Source'
                          : order.source!,
                      style: OrdersConstants.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Order type tag only when different from channel (e.g. UberEats + Delivery)
              if (order.channel.name != _getOrderTypeLabel()) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: context.borderLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getOrderTypeIcon(),
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getOrderTypeLabel(),
                        style: OrdersConstants.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (showTable) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: context.borderLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.table_restaurant,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Table ${order.tableNumber!.trim()}',
                        style: OrdersConstants.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _buildOrderMeta(context),
        ],
      ),
    );
  }

  Widget _buildOrderMeta(BuildContext context) {
    String fmt(String? value) =>
        (value == null || value.isEmpty) ? '—' : value;

    String fmtDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);
    String fmtTime(DateTime dt) => DateFormat('HH:mm').format(dt);

    final colorScheme = Theme.of(context).colorScheme;

    final items = <Widget>[
      _metaItem(
        context,
        icon: Icons.confirmation_number,
        label: 'Order Number',
        value: fmt(order.orderNumber),
      ),
      _metaItem(
        context,
        icon: Icons.receipt_long,
        label: 'Ref No',
        value: fmt(order.referenceNo),
      ),
      _metaItem(
        context,
        icon: Icons.route,
        label: 'Service Type',
        value: fmt(order.serviceType),
      ),
      _metaItem(
        context,
        icon: _getOrderTypeIcon(),
        label: 'Fulfillment',
        value: _getOrderTypeLabel(),
      ),
      _metaItem(
        context,
        icon: Icons.calendar_today,
        label: 'Order Date',
        value: fmtDate(order.createdAt),
      ),
      _metaItem(
        context,
        icon: Icons.schedule,
        label: 'Order Time',
        value: fmtTime(order.createdAt),
      ),
      _metaItem(
        context,
        icon: Icons.flag,
        label: 'Status',
        value: _getStatusLabel(),
      ),
      _metaItem(
        context,
        icon: Icons.local_fire_department,
        label: 'Prep Status',
        value: fmt(order.preparationStatus),
      ),
      _metaItem(
        context,
        icon: Icons.local_shipping,
        label: 'Delivery Status',
        value: fmt(order.deliveryStatus),
      ),
      if (order.tableNumber != null && order.tableNumber!.trim().isNotEmpty)
        _metaItem(
          context,
          icon: Icons.table_restaurant,
          label: 'Table',
          value: order.tableNumber!.trim(),
        ),
      if (order.customerPhone != null && order.customerPhone!.trim().isNotEmpty)
        _metaItem(
          context,
          icon: Icons.phone,
          label: 'Phone',
          value: order.customerPhone!.trim(),
        ),
      _metaItem(
        context,
        icon: Icons.receipt,
        label: 'Subtotal',
        value: '\$${order.subtotal.toStringAsFixed(2)}',
      ),
      _metaItem(
        context,
        icon: Icons.request_quote,
        label: 'Tax',
        value: '\$${order.tax.toStringAsFixed(2)}',
      ),
    ];

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        initiallyExpanded: false,
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Order information',
              style: OrdersConstants.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.borderLight),
            ),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.8,
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: OrdersConstants.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: OrdersConstants.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAndTime(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.borderLight, width: 2),
        ),
      ),
      child: Column(
        children: [
          if (order.customerName.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.borderLight),
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
                        color: colorScheme.onSurface,
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

  Widget _buildOrderNotes(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.borderLight, width: 2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order notes: ',
            style: OrdersConstants.bodySmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              order.specialInstructions!,
              style: OrdersConstants.bodySmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTotalBar(BuildContext context) {
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
        if (_canEditOrder())
          _buildActionButton(
            icon: Icons.edit,
            color: OrdersConstants.colorTextSecondary,
            onTap: () {
              // Allow edit for Pay Later and local offline orders that are still
              // active (not completed/cancelled). When a callback is provided,
              // we delegate navigation to the caller; otherwise we just show a toast.
              if (onEdit != null && order.status == OrderStatus.active) {
                onEdit!();
              } else {
                _showToast(context, 'Edit');
              }
            },
          ),
        _buildActionButton(
          icon: Icons.cancel,
          color: OrdersConstants.colorActionCancel,
          onTap: () => _showToast(context, 'Cancel'),
        ),
      ],
    );
  }

  bool _canEditOrder() {
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
            color: filled ? color.withOpacity(0.5) : color,
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
      case OrderChannel.delivery:
        return [
          OrdersConstants.colorDeliveryStart,
          OrdersConstants.colorDeliveryEnd,
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
      case OrderChannel.delivery:
        return [
          OrdersConstants.colorDeliveryBg,
          OrdersConstants.colorDeliveryBg,
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
      case OrderChannel.delivery:
        return OrdersConstants.colorDeliveryText;
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
      case OrderChannel.delivery:
        return OrdersConstants.colorDeliveryBorder;
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
    // Prefer the backend-provided display status when available so that
    // we can show values like ACCEPTED / PREPARING / READY instead of
    // the coarse-grained enum labels.
    final backendLabel = order.displayStatus?.trim();
    if (backendLabel != null && backendLabel.isNotEmpty) {
      return backendLabel.toUpperCase();
    }
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
        return 'Pickup';
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

class _OrderItemsSection extends StatefulWidget {
  const _OrderItemsSection({required this.order});

  final OrderEntity order;

  @override
  State<_OrderItemsSection> createState() => _OrderItemsSectionState();
}

class _OrderItemsSectionState extends State<_OrderItemsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final colorScheme = Theme.of(context).colorScheme;
    final itemCount = order.items.length;

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
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: itemCount == 0
                ? null
                : () => setState(() {
                      _expanded = !_expanded;
                    }),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_bag,
                  size: 14,
                  color: OrdersConstants.colorTextMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '$itemCount item${itemCount != 1 ? 's' : ''}',
                  style: OrdersConstants.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: OrdersConstants.colorTextPrimary,
                  ),
                ),
                const Spacer(),
                if (itemCount > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _expanded ? 'Hide items' : 'Show items',
                        style: OrdersConstants.bodySmall.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (_expanded && itemCount > 0) ...[
            const SizedBox(height: 8),
            ...order.items.map(
              (item) => _buildItemDetail(
                context: context,
                item: item,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemDetail({
    required BuildContext context,
    required OrderItemEntity item,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: OrdersConstants.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${item.quantity}x \$${item.price.toStringAsFixed(2)}',
                style: OrdersConstants.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          if (item.modifiers != null && item.modifiers!.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...item.modifiers!.map(
              (line) {
                final colonIndex = line.indexOf(': ');
                final hasHeading = colonIndex > 0;
                final heading = hasHeading ? line.substring(0, colonIndex) : '';
                final rest = hasHeading ? line.substring(colonIndex) : line;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: OrdersConstants.bodySmall.copyWith(
                        fontSize: 11,
                        color: OrdersConstants.colorTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        if (hasHeading)
                          TextSpan(
                            text: heading,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.85),
                            ),
                          ),
                        TextSpan(text: rest),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
          if (item.instructions != null && item.instructions!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions: ',
                    style: OrdersConstants.bodySmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: OrdersConstants.colorTextSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.instructions!,
                      style: OrdersConstants.bodySmall.copyWith(
                        fontSize: 11,
                        color: OrdersConstants.colorTextSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
