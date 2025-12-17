import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/customer_display_entity.dart';

class CustomerDisplayApprovedView extends StatelessWidget {
  const CustomerDisplayApprovedView({super.key, required this.content});

  final CustomerDisplayEntity content;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: r'$');
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 12),
                              blurRadius: 28,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF16A34A),
                          size: 140,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Payment Approved!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Thank you for your order',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Order #${content.orderNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _ApprovedInfoCard(
                        amount: currency.format(content.totals.total),
                      ),
                      const SizedBox(height: 24),
                      _ApprovedLoyalty(loyaltyPoints: content.loyalty.pointsEarned),
                      const SizedBox(height: 32),
                      const Text(
                        'Please collect your receipt',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ApprovedInfoCard extends StatelessWidget {
  const _ApprovedInfoCard({required this.amount});

  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Amount Charged',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovedLoyalty extends StatelessWidget {
  const _ApprovedLoyalty({required this.loyaltyPoints});

  final int loyaltyPoints;

  @override
  Widget build(BuildContext context) {
    if (loyaltyPoints <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, color: Color(0xFFFACC15), size: 32),
          const SizedBox(width: 12),
          Text(
            '+$loyaltyPoints loyalty points added',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
