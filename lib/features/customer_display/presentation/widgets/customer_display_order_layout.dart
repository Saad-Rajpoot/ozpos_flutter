import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/customer_display_cart_item_entity.dart';
import '../../domain/entities/customer_display_entity.dart';
import '../../domain/entities/customer_display_loyalty_entity.dart';
import '../../domain/entities/customer_display_totals_entity.dart';
import '../../domain/entities/customer_display_mode.dart';

class CustomerDisplayOrderLayout extends StatelessWidget {
  const CustomerDisplayOrderLayout({
    super.key,
    required this.content,
    required this.rightPanel,
  });

  final CustomerDisplayEntity content;
  final Widget rightPanel;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 1000;

    final orderPanel = Expanded(
      flex: 3,
      child: Container(
        color: const Color(0xFFF3F4F6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Your Order',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Please review your items',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Order #${content.orderNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...content.cartItems
                          .map((item) => _CartItemCard(item: item)),
                      const SizedBox(height: 20),
                      _TotalsCard(totals: content.totals),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final paymentPanel = Expanded(flex: 2, child: rightPanel);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isNarrow
            ? Column(
                children: [
                  Expanded(child: orderPanel),
                  const SizedBox(height: 16),
                  SizedBox(height: 420, child: rightPanel),
                ],
              )
            : Row(
                children: [orderPanel, const SizedBox(width: 16), paymentPanel],
              ),
      ),
    );
  }
}

class CustomerDisplayOrderPanel extends StatelessWidget {
  const CustomerDisplayOrderPanel({super.key, required this.content});

  final CustomerDisplayEntity content;

  @override
  Widget build(BuildContext context) {
    return CustomerDisplayOrderLayout(
      content: content,
      rightPanel: CustomerDisplayOrderSummary(content: content),
    );
  }
}

class CustomerDisplayOrderSummary extends StatelessWidget {
  const CustomerDisplayOrderSummary({super.key, required this.content});

  final CustomerDisplayEntity content;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: r'$');
    return _GradientPanel(
      colors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      children: [
        const Text(
          'Total Due',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          currency.format(content.totals.total),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 80,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 6),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _InfoCard(
          backgroundColor: Colors.white24,
          borderColor: Colors.white24,
          children: [
            Text('⏳', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text(
              'Please wait...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Cashier is processing your order',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _LoyaltyCard(loyalty: content.loyalty),
      ],
    );
  }
}

class CustomerDisplayPaymentPanel extends StatelessWidget {
  const CustomerDisplayPaymentPanel({
    super.key,
    required this.content,
    required this.mode,
  });

  final CustomerDisplayEntity content;
  final CustomerDisplayMode mode;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: r'$');
    final isCard = mode == CustomerDisplayMode.paymentCard;
    final colors = isCard
        ? const [Color(0xFF4C1D95), Color(0xFF6D28D9)]
        : const [Color(0xFF166534), Color(0xFF15803D)];
    final emoji = isCard ? '💳' : '💵';
    final title = isCard
        ? 'Please Tap, Insert or Swipe Your Card'
        : 'Please Hand Cash to Cashier';
    final subtitle = isCard ? 'Waiting for card...' : 'Amount Due';

    return _GradientPanel(
      colors: colors,
      children: [
        const Text(
          'Total Due',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          currency.format(content.totals.total),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 72,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 6),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _InfoCard(
          backgroundColor: Colors.white.withOpacity(0.15),
          borderColor: Colors.white24,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isCard
                  ? subtitle
                  : '$subtitle: ${currency.format(content.totals.total)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _LoyaltyCard(loyalty: content.loyalty),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item});

  final CustomerDisplayCartItemEntity item;
  static final NumberFormat _currency = NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final priceText = _currency.format(item.lineTotal);
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: item.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: '  x${item.quantity}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                priceText,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (item.modifiers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: item.modifiers.map((modifier) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          modifier,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.totals});

  final CustomerDisplayTotalsEntity totals;
  static final NumberFormat _currency = NumberFormat.currency(symbol: r'$');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _totalRow('Subtotal', _currency.format(totals.subtotal)),
          if (totals.hasDiscount)
            _totalRow(
              'Discount',
              '-${_currency.format(totals.discount)} 🎉',
              valueColor: const Color(0xFF16a34a),
            ),
          _totalRow('Tax (10%)', _currency.format(totals.tax)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(thickness: 2),
          ),
          _totalRow(
            'TOTAL',
            _currency.format(totals.total),
            isEmphasis: true,
          ),
          if (totals.hasDiscount) const SizedBox(height: 16),
          if (totals.hasDiscount)
            const Text(
              'You saved today – thank you!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF16a34a),
              ),
            ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value,
      {bool isEmphasis = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isEmphasis ? 26 : 20,
                fontWeight: isEmphasis ? FontWeight.w800 : FontWeight.w600,
                color: isEmphasis
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isEmphasis ? 36 : 22,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoyaltyCard extends StatelessWidget {
  const _LoyaltyCard({required this.loyalty});

  final CustomerDisplayLoyaltyEntity loyalty;

  @override
  Widget build(BuildContext context) {
    if (!loyalty.showLoyalty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.star, color: Color(0xFFFACC15), size: 32),
              SizedBox(width: 12),
              Text(
                'Loyalty Rewards',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (loyalty.hasPointsToEarn)
            Text(
              '+${loyalty.pointsEarned} points on this order',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          if (loyalty.hasBalance)
            Text(
              'Current balance: ${loyalty.currentBalance} pts',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
          const SizedBox(height: 10),
          const Text(
            'Join free at checkout!',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientPanel extends StatelessWidget {
  const _GradientPanel({required this.children, required this.colors});

  final List<Widget> children;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.children,
    required this.backgroundColor,
    required this.borderColor,
  });

  final List<Widget> children;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
